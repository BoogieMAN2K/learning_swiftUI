//
//  ContentView.swift
//  Learning SwiftUI
//
//  Created by Victor Gil Alejandria on 02/02/2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NewsView().tabItem {
                Label("Your news", systemImage: "newspaper")
            }
            NewsBySourcesView().tabItem {
                Label("By sources", systemImage: "list.dash")
            }
            SettingsView().tabItem {
                Label("Settings", systemImage: "gearshape")
            }
        }
        .environmentObject(RecentNews())
    }
}

#Preview {
    ContentView()
}
