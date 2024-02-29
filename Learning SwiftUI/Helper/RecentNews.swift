//
//  RecentNews.swift
//  Learning SwiftUI
//
//  Created by Victor Gil Alejandria on 19/02/2024.
//
import SwiftUI

class RecentNews: ObservableObject {
    var newsList: [ArticleItem] = []
    var ignoreCache: Bool = false
}

struct RecentNewsEnvironmentKey: EnvironmentKey {
    static var defaultValue: RecentNews = RecentNews()
}

extension EnvironmentValues {
    var recentNews: RecentNews {
        get { self[RecentNewsEnvironmentKey.self] }
        set { self[RecentNewsEnvironmentKey.self] = newValue }
    }
}

struct SetRecentNews: ViewModifier {
    let value: RecentNews

    func body(content: Content) -> some View {
        content.environment(\.recentNews, value)
    }
}
