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
    private let session: URLSession
    private let defaultURL = "https://newsapi.org/v2/top-headlines?language=en&apiKey=e9e7be2679554d3a80ce999c98ec41c7"

    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        session = URLSession(configuration: configuration)
    }

    func getNews(searchTerm: String) -> AnyPublisher<News, Error> {
        guard let url = makeURL(for: searchTerm) else {
            return Fail(error: PalError.invalidURL).eraseToAnyPublisher()
        }

        return session.dataTaskPublisher(for: url)
            .tryMap { data, response in
                return try JSONDecoder().decode(News.self, from: data)
            }
            .mapError { PalError.networkError(description: $0.localizedDescription) }
            .eraseToAnyPublisher()
    }

    @MainActor
    func getImage(from urlString: String) -> AnyPublisher<UIImage?, Error> {
        guard let url = URL(string: urlString) else {
            return Fail(error: PalError.invalidURL).eraseToAnyPublisher()
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
                    throw PalError.invalidImageData
                }
                let response = URLResponse(url: url, mimeType: "image/png", expectedContentLength: data.count, textEncodingName: nil)
                let cachedResponse = CachedURLResponse(response: response, data: data)
                self.imageCache.storeCachedResponse(cachedResponse, for: URLRequest(url: url))
                return image
            }
            .mapError { PalError.networkError(description: $0.localizedDescription) }
            .eraseToAnyPublisher()
    }

    private func makeURL(for searchTerm: String) -> URL? {
        var urlString = defaultURL
        if searchTerm.count > 3, let encodedSearchTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            urlString = "https://newsapi.org/v2/everything?q=\(encodedSearchTerm)&language=en&apiKey=e9e7be2679554d3a80ce999c98ec41c7"
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

enum PalError: Error {
    case invalidURL
    case invalidImageData
    case networkError(description: String)
}
