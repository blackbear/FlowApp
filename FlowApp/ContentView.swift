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
    
    
    var body: some View {
        VStack {
            ForEach(model.quakes, id: \.id) { quake in
                HStack {
                    Text(Date(timeIntervalSince1970: Double(quake.properties.time / 1000)).formatted())
                        .frame(maxWidth: 200, alignment: .leading)
                    Spacer()
                    Text(quake.placeString)
                        .foregroundStyle(quake.properties.mag >= 5 ? Color.red : Color.black)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer()
                    Text(quake.magnitudeString)
                        .frame(maxWidth: 100, alignment: .leading)
                }
            }
            
            Spacer()
        }.padding(10.0)
            .background() {
                Color.white
            }

            
    }
}

#Preview {
    ContentView(model: ContentModel()).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
