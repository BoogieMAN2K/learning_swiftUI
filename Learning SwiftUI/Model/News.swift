//
//  News.swift
//  Learning SwiftUI
//
//  Created by Victor Gil Alejandria on 02/02/2024.
//
import SwiftUI

class News: Decodable {
    let status: String
    let totalResults: Int
    let articles: [Article]
}

class Article: Decodable {
    let source: Source?
    let author: String?
    let title: String?
    let description: String?
    let url: String?
    let urlToImage: String?
    let publishedAt: String?
    let content: String?
}

class Source: Decodable {
    let id: String?
    let name: String?
}
