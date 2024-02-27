//
//  NewsDetailView.swift
//  Learning SwiftUI
//
//  Created by Victor Gil Alejandria on 07/02/2024.
//

import SwiftUI

struct NewsDetailView: View {

    @State var article: ArticleItem

    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .trailing) {
                if let imageURL = article.imageURL {
                    RemoteImage(imageURL: imageURL)
                        .frame(height: 100)
                    LinearGradient(gradient: Gradient(colors:[.gray, .white, .gray]), startPoint: .top, endPoint: .bottom)
                        .edgesIgnoringSafeArea(.all)
                        .opacity(0.8)
                }
                VStack(alignment: .trailing) {
                    Spacer()
                    Text(article.title ?? "")
                        .fontWeight(.semibold)
                        .dynamicTypeSize(.medium)
                        .lineLimit(4)
                    Text(formatDateToString(article.date ?? Date.distantPast))
                        .fontWeight(.light)
                        .dynamicTypeSize(.xSmall)
                        .italic()
                }
                .padding([.leading, .trailing], 20)
            }
            .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            .frame(height: 100)
            Text(article.summary ?? "")
            Spacer()
        }
        .padding()
    }
}
