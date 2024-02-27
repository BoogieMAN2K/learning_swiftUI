//
//  NewsItemView.swift
//  Learning SwiftUI
//
//  Created by Victor Gil Alejandria on 06/02/2024.
//
import SwiftUI
import Combine

struct NewsItemView: View {
    @State var item: ArticleItem

    var body: some View {
        HStack {
            if let imageURL = item.imageURL {
                RemoteImage(imageURL: imageURL)
                    .scaledToFit()
                    .frame(width: 100)
            }
            VStack(alignment: .leading) {
                Text(item.title ?? "")
                    .fontWeight(.semibold)
                    .dynamicTypeSize(.medium)
                    .lineLimit(4)
                Text(formatDateToString(item.date ?? Date.distantPast))
                    .fontWeight(.light)
                    .dynamicTypeSize(.xSmall)
                    .italic()
            }
        }
    }
}

struct RemoteImage: View {
    var imageURL: String
    @StateObject var imageLoader = ImageLoader()

    var body: some View {
        return NewsImage(image: imageLoader.image)
            .onAppear { imageLoader.load(from: imageURL) }
    }
}

struct NewsImage: View {
    var image: Image?

    var body: some View {
        image?.resizable() ?? Image("PlaceholderNews").resizable()
    }
}

@MainActor
final class ImageLoader: ObservableObject {
    @Published var image: Image? = nil
    var cancellable = Set<AnyCancellable>()

    func load(from urlString: String) {
        NetworkRequest.instance.getImage(from: urlString)
            .receive(on: RunLoop.main)
            .sink { error in

            } receiveValue: { uiImage in
                if let uiImage = uiImage {
                    self.image = Image(uiImage: uiImage)
                }
            }
            .store(in: &cancellable)
    }
}
