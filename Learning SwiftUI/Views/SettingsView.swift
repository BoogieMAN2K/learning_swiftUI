//
//  SettingsView.swift
//  Learning SwiftUI
//
//  Created by Victor Gil Alejandria on 28/02/2024.
//

import SwiftUI

struct SettingsView: View {
    @State private var useSystemDefault = UserDefaults.standard.value(forKey: "isSystemDefaultLanguage") as? Bool ?? true
    @State private var selectedLanguage: Language = Language(rawValue: UserDefaults.standard.string(forKey: "selectedLanguage") ?? "") ?? .english
    @Environment(\.recentNews) var recentNews

    enum Language: String, CaseIterable, Identifiable {
        case english = "en"
        case french = "fr"
        case german = "de"
        var id: Self { self }
    }

    var body: some View {
        List {
            Section(header: Text("Language")) {
                Toggle(isOn: $useSystemDefault) {
                    Text("Use system default")
                }
                .onChange(of: useSystemDefault) {
                    recentNews.ignoreCache = true
                    UserDefaults.standard.setValue(useSystemDefault, forKey: "isSystemDefaultLanguage")
                }

                if !useSystemDefault {
                    Picker("Language", selection: $selectedLanguage) {
                        Text("English").tag(Language.english)
                        Text("French").tag(Language.french)
                        Text("German").tag(Language.german)
                    }
                    .onChange(of: selectedLanguage) {
                        recentNews.ignoreCache = true
                        UserDefaults.standard.setValue(selectedLanguage.rawValue, forKey: "selectedLanguage")
                    }
                }
            }
        }
        .listStyle(.grouped)
    }
}

#Preview {
    SettingsView()
}
