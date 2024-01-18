//
//  QuakeDataFetcher.swift
//  FlowApp
//
//  Created by James Turner on 1/17/24.
//

import Foundation
import Combine
import Logging

class QuakeDataFetcher {
    
    private var logger = Logger(label: "FlowApp")
    
    private var myQueue = DispatchQueue(label: "FetcherQueue")

    private var lastQuakeDate: String?
    private var lastQuakeId = ""
    
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
                    logger.info("ERROR: \(error.localizedDescription)")
                    return
                }
                guard let response else {
                    logger.info("NO RESPONSE")
                    return
                }
                guard let resp = response as? HTTPURLResponse,
                      resp.statusCode == 200 else {
                    logger.info("BAD RESPONSE")
                    return
                }
                guard let data else {
                    logger.info("NO DATA")
                    return
                }
                
                do {
                    let newObjs = try JSONDecoder().decode(QueryResponse.self, from: data).features.filter { quake in
                        quake.id != lastQuakeId
                    }
                    guard !newObjs.isEmpty else {
                        logger.info("NO NEW QUAKES RETURNED")
                        return
                    }
                    if newObjs.count > 0 {
                        logger.info("RETRIEVED \(newObjs.count) NEW QUAKES")
                        let lastQuake = newObjs.max(by: { d1, d2 in
                            return d1.properties.time < d2.properties.time
                        })
                        guard let lastQuake else {
                            return
                        }
                        lastQuakeDate = Date(timeIntervalSince1970: Double(lastQuake.properties.time / 1000)).formatted(.iso8601)
                        newQuakes = newObjs
                        lastQuakeId = lastQuake.id
                    }
                } catch {
                    logger.info("CAN'T DECODE JSON: \(error.localizedDescription)")
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
