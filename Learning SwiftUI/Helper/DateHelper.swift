//
//  DateHelper.swift
//  Learning SwiftUI
//
//  Created by Victor Gil Alejandria on 05/02/2024.
//
import Foundation

func formatDateToString(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: date)
}

func formatStringToDate(_ date: String) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"

    if let date = dateFormatter.date(from: "2024-01-31T21:28:35Z") {
        return date
    } else {
        return Date.distantPast
    }
}
