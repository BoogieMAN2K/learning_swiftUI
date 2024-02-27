//
//  News.swift
//  Learning SwiftUI
//
//  Created by Victor Gil Alejandria on 02/02/2024.
//
import SwiftUI
import Combine

struct NewsView: View {
    @MainActor @State private var news: [ArticleItem] = []
    @State private var isDisplayingError: Bool = false
    @State private var networkRequest = NetworkRequest.instance
    @State private var cancellables = Set<AnyCancellable>()
    @State private var searchText = ""
    @State private var displayToolbar: Bool = true
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.recentNews) var recentNews

    var body: some View {
        NavigationStack {
            List(news) { newsArticle in
                NavigationLink(destination: WebView(url: newsArticle.newsURL ?? "").navigationBarTitleDisplayMode(.inline)) {
                    NewsItemView(item: newsArticle)
                        .ignoresSafeArea()
                }
            }
            .alert(isPresented: $isDisplayingError, content: {
                Alert(
                    title: Text("Alert"),
                    message: Text("Failed to load news."),
                    dismissButton: .default(Text("OK"))
                )
            })
            .onAppear {
                if !ProcessInfo.isOnPreview() {
                    loadNews()
                }
                displayToolbar = true
            }
            .navigationBarTitle("News")
        }
        .onChange(of: searchText) {
            loadNews()
        }
        .refreshable {
            loadNews()
        }
        .listStyle(.grouped)
        .toolbar(displayToolbar ? .visible : .hidden)
        .searchable(text: $searchText, placement: .automatic, prompt: "Search for news here")
    }

    @MainActor
    private func loadNews() {
        Task {
            networkRequest.getNews(searchTerm: searchText)
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
}

struct NewsView_Previews: PreviewProvider {
    static var previews: some View {
        NewsView()
    }
}
