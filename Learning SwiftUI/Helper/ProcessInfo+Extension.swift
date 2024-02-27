//
//  ProcessInfo+Extension.swift
//  Learning SwiftUI
//
//  Created by Victor Gil Alejandria on 06/02/2024.
//
import SwiftUI

extension ProcessInfo {
   static func isOnPreview() -> Bool {
       return processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
   }
}
