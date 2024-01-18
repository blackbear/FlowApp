//
//  QuakeDataFetcher.swift
//  FlowApp
//
//  Created by James Turner on 1/17/24.
//

import Foundation
import Combine

class QuakeDataFetcher {
    
    private var myQueue = DispatchQueue(label: "FetcherQueue")

    private var lastQuakeDate: String?
    
    // Number of seconds to wait between last success and next call
    private let timeBetweenRequests = 5.0
    
    private let quakeURL = "https://earthquake.usgs.gov/fdsnws/event/1/query?format=geojson"
    static var shared = QuakeDataFetcher()
    
    
    @Published var newQuakes = [EarthquakeData]()
    
    private func getQuakeURL() -> URL? {
        if let lastQuakeDate {
            return URL(string: "\(quakeURL)&starttime=\(lastQuakeDate)")
        } else {
            return URL(string: quakeURL)
        }
    }
    
    private func fetchQuakeData() {
        let session = URLSession.shared
        if let url = getQuakeURL() {
            let urlRequest = URLRequest(url: url)
            session.dataTask(with: urlRequest) { [self] data, response, error in
                defer {
                    self.myQueue.asyncAfter(deadline: .now() + self.timeBetweenRequests) {
                        self.fetchQuakeData()
                    }
                }
                if let error {
                    print("ERROR: \(error.localizedDescription)")
                    return
                }
                guard let response else {
                    print("NO RESPONSE")
                    return
                }
                guard let resp = response as? HTTPURLResponse,
                      resp.statusCode == 200 else {
                    print("BAD RESPONSE")
                    return
                }
                guard let data else {
                    print("NO DATA")
                    return
                }
                
                do {
                    let newObjs = try JSONDecoder().decode(QueryResponse.self, from: data)
                    if newObjs.features.count > 0 {
                        newQuakes = newObjs.features
                        let lastQuake = newQuakes.max(by: { d1, d2 in
                            return d1.properties.time < d2.properties.time
                        })
                        lastQuakeDate = Date(timeIntervalSince1970: Double(lastQuake!.properties.time / 1000)).formatted(.iso8601)
                    }
                } catch {
                    print("CAN'T DECODE JSON: \(error.localizedDescription)")
                    return
                }
            }.resume()
        }
    }
    
    private init() {
        myQueue.async {
            self.fetchQuakeData()
        }
    }
}
