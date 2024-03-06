//
//  WebView.swift
//  Learning SwiftUI
//
//  Created by Victor Gil Alejandria on 14/02/2024.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: String

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        guard let localURL = URL(string: url) else {
            webView.load(URLRequest(url: URL(string: "https://www.google.com")!))
            webView.navigationDelegate = context.coordinator
            return webView
        }
        webView.load(URLRequest(url: localURL))
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {

    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView

        init(parent: WebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {}
    }

}

struct WebViewPreviews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

#Preview {
    WebView(url: "https://newsapi.org/v2/top-headlines?language=en&apiKey=e9e7be2679554d3a80ce999c98ec41c7")
}
