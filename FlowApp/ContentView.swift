//
//  ContentView.swift
//  FlowApp
//
//  Created by James Turner on 1/17/24.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var model : ContentModel
    
    var timeFormatter = {
        var fmt = DateFormatter()
        fmt.dateFormat = "MM/dd HH:mm"
        fmt.timeZone = TimeZone.current
        return fmt
    }()
    
    
    var body: some View {
        VStack {
            HStack {
                Text("DATE/TIME")
                    .frame(maxWidth: 200, alignment: .leading)
                Spacer()
                Text("LOCATION")
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                Text("MAG")
                    .frame(maxWidth: 100, alignment: .leading)
            }
            ScrollView([.vertical], showsIndicators: true) {
                ForEach(Array(model.quakes.enumerated()), id: \.element.id) { index, quake in
                    let color = quake.properties.mag >= 5 ? Color.red : Color("NormalText")
                    HStack {
                        Text(timeFormatter.string(from: Date(timeIntervalSince1970: Double(quake.properties.time / 1000))))
                            .foregroundStyle(color)
                            .frame(maxWidth: 200, alignment: .leading)
                        Spacer()
                        Text(quake.placeString)
                            .foregroundStyle(color)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Spacer()
                        Text(quake.magnitudeString)
                            .foregroundStyle(color)
                            .frame(maxWidth: 100, alignment: .leading)
                    }.background {
                        index % 2 == 0 ? Color("RowHighlight") : Color("RowNormal")
                    }

                }
            }
            Spacer()
        }.padding(10.0)
            .background() {
                Color("ScreenBackground")
            }

            
    }
}

#Preview {
    ContentView(model: ContentModel()).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
