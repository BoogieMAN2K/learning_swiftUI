//
//  SettingsView.swift
//  Learning SwiftUI
//
//  Created by Victor Gil Alejandria on 28/02/2024.
//

import SwiftUI

struct SettingsView: View {
    @State private var useApplicationDefault = UserDefaults.standard.value(forKey: "isApplicationDefaultLanguage") as? Bool ?? true
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
                Toggle(isOn: $useApplicationDefault) {
                    Text("Use application default")
                }
                .onChange(of: useApplicationDefault) {
                    recentNews.ignoreCache = true
                    UserDefaults.standard.setValue(useApplicationDefault, forKey: "isApplicationDefaultLanguage")
                    UserDefaults.standard.setValue(Language.english.rawValue, forKey: "selectedLanguage")
                }

                if !useApplicationDefault {
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
