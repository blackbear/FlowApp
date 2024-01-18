//
//  ContentModel.swift
//  FlowApp
//
//  Created by James Turner on 1/17/24.
//

import Foundation
import Combine

struct QueryResponse : Codable {
    var features: [EarthquakeData]
}

struct EarthquakeProperties : Codable {
    var mag: Float
    var place: String?
    var time: Int64
}

struct EarthquakeData : Identifiable, Codable {
    var id: String
    var properties: EarthquakeProperties
    
    var magnitudeString: String {
        get {
            return String.init(format: "%0.2f", properties.mag)
        }
    }
    var placeString: String {
        get {
            return properties.place ?? "UNKNOWN"
        }
    }
}

class ContentModel : ObservableObject {
    @Published var quakes = [EarthquakeData]()
    var subscriptions = Set<AnyCancellable>()
    
    init() {
        QuakeDataFetcher.shared.$newQuakes
            .receive(on: DispatchQueue.main)
            .sink { newQuakes in
                self.addQuakes(newQuakes)
            }.store(in: &subscriptions)
    }
    
    private func addQuakes(_ quakes : [EarthquakeData]) {
        var combinedQuakes = [EarthquakeData]()
        combinedQuakes.append(contentsOf: quakes)
        combinedQuakes.append(contentsOf: self.quakes)
        self.quakes = combinedQuakes.sorted(by: { d1, d2 in
            d1.properties.time > d2.properties.time
        }).suffix(20)
    }
}
