//
//  FlowAppApp.swift
//  FlowApp
//
//  Created by James Turner on 1/17/24.
//

import SwiftUI

@main
struct FlowAppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView(model: ContentModel())
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
