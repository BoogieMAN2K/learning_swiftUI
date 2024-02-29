//
//  NetworkRequest.swift
//  Learning SwiftUI
//
//  Created by Victor Gil Alejandria on 02/02/2024.
//
import Foundation
import UIKit
import Combine

class NetworkRequest {
    static let instance = NetworkRequest()
    private let imageCache = URLCache.shared
    private var session = URLSession(configuration: URLSessionConfiguration.default)
    private let baseURL: String = "https://newsapi.org/v2"
    private let apiKey: String = "e9e7be2679554d3a80ce999c98ec41c7"
    private var defaultURL: String = ""

    @MainActor
    func getNews(searchTerm: String = "", ignoreCache: Bool = false) -> AnyPublisher<News, Error> {
        guard let url = makeURL(for: searchTerm) else {
            return Fail(error: NewsError.invalidURL).eraseToAnyPublisher()
        }

        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = ignoreCache ? .reloadIgnoringLocalAndRemoteCacheData : .reloadRevalidatingCacheData
        session = URLSession(configuration: configuration)
        return session.dataTaskPublisher(for: url)
            .tryMap { data, response in
                return try JSONDecoder().decode(News.self, from: data)
            }
            .mapError { NewsError.networkError(description: $0.localizedDescription) }
            .eraseToAnyPublisher()
    }

    @MainActor
    func getImage(from urlString: String) -> AnyPublisher<UIImage?, Error> {
        guard let url = URL(string: urlString) else {
            return Fail(error: NewsError.invalidURL).eraseToAnyPublisher()
        }

        if let cachedResponse = imageCache.cachedResponse(for: URLRequest(url: url)),
           let image = UIImage(data: cachedResponse.data) {
            return Just(image)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        return session.dataTaskPublisher(for: url)
            .tryMap { data, _ in
                guard let image = UIImage(data: data) else {
                    throw NewsError.invalidImageData
                }
                let response = URLResponse(url: url, mimeType: "image/png", expectedContentLength: data.count, textEncodingName: nil)
                let cachedResponse = CachedURLResponse(response: response, data: data)
                self.imageCache.storeCachedResponse(cachedResponse, for: URLRequest(url: url))
                return image
            }
            .mapError { NewsError.networkError(description: $0.localizedDescription) }
            .eraseToAnyPublisher()
    }

    private func makeURL(for searchTerm: String) -> URL? {
        let language: String = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "en"
        defaultURL = "\(baseURL)/top-headlines?language=\(language)&apiKey=\(apiKey)"
        var urlString = defaultURL
        if searchTerm.count > 3, let encodedSearchTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            urlString = "\(baseURL)/everything?q=\(encodedSearchTerm)&language=\(language)&apiKey=\(apiKey)"
        }
        return URL(string: urlString)
    }

    func getDomain(from url: String) -> String? {
        if let url = URL(string: url), let host = url.host {
            return host
        }
        return nil
    }
}

enum NewsError: Error {
    case invalidURL
    case invalidImageData
    case networkError(description: String)
}
