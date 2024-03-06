//
//  NewsBySources.swift
//  Learning SwiftUI
//
//  Created by Victor Gil Alejandria on 15/02/2024.
//
import SwiftUI
import Combine

struct NewsBySourcesView: View {
    @MainActor @State private var news: [ArticleItem] = []
    @State private var isDisplayingError: Bool = false
    @State private var networkRequest = NetworkRequest.instance
    @State private var cancellables = Set<AnyCancellable>()
    @State private var displayToolbar: Bool = true
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.recentNews) var recentNews
    @State private var selectedSection: String?
    @State private var selectedNew: ArticleItem?

    var body: some View {
        NavigationSplitView {
            List(loadSections(articles: news), selection: $selectedSection) {
                NavigationLink($0.title ?? "", value: $0.title ?? "")
            }
            .navigationTitle("Sources")
        } content: {
            List(sectionNews(), selection: $selectedNew) {
                NavigationLink($0.title ?? "", value: $0)
            }
        } detail: {
            WebView(url: newsURLString())
                .navigationBarTitleDisplayMode(.inline)
                .onAppear {
                    print("News URL: \(newsURLString())")
                }
        }
        .onAppear {
            loadNews()
            if recentNews.ignoreCache {
                recentNews.ignoreCache.toggle()
            }
        }
    }

    @MainActor
    private func sectionNews() -> [ArticleItem] {
        news.filter { $0.newsURL?.contains(selectedSection ?? "") ?? false }
    }

    private func newsURLString() -> String {
        selectedNew?.newsURL ?? ""
    }

    @MainActor
    private func loadSections(articles: [ArticleItem]) -> [ArticleSection] {
        var newsSections: [ArticleSection] = []
        articles.forEach { article in
            newsSections.append(ArticleSection(title: article.source))
        }

        return newsSections
    }

    @MainActor
    private func loadNews() {
        networkRequest.getNews(ignoreCache: recentNews.ignoreCache)
            .sink { completion in
                if case let .failure(error) = completion {
                    print("Failed to load news: \(error.localizedDescription)")
                    isDisplayingError = true
                }
            } receiveValue: { newsResponse in
                // Some articles are coming with the title '[Removed]' so we need to filter those.
                news = newsResponse.articles.filter { $0.title != "[Removed]" }.map {
                    ArticleItem(title: $0.title ?? "",
                                date: formatStringToDate($0.publishedAt ?? ""),
                                summary: $0.description ?? "",
                                imageURL: $0.urlToImage ?? "",
                                newsURL: $0.url,
                                source: networkRequest.getDomain(from: $0.url ?? ""))
                }

                self.recentNews.newsList = news
            }
            .store(in: &cancellables)
    }

}

#Preview {
    NewsBySourcesView()
}
