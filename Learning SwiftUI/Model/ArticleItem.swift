//
//  ArticleItem.swift
//  Learning SwiftUI
//
//  Created by Victor Gil Alejandria on 06/02/2024.
//
import SwiftUI

struct ArticleItem: Identifiable {
    let id: UUID = UUID()
    var title: String?
    var date: Date?
    var summary: String?
    var imageURL: String?
    var newsURL: String?
    var source: String?

    init(title: String? = "", date: Date? = .distantPast, summary: String? = "", imageURL: String? = "", newsURL: String? = "", source: String? = "") {
        self.title = title
        self.date = date
        self.summary = summary
        self.imageURL = imageURL
        self.newsURL = newsURL
        self.source = source
    }
}
