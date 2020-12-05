//
//  ResultItem.swift
//  PhotoViewerApp
//
//  Created by Alexandros Lykesas on 28/11/20.
//

import UIKit

struct ResultItem: Decodable, Hashable {

    let uuid = UUID()

    let description: String?
    let altDescription: String?

    let width: CGFloat
    let height: CGFloat

    let urls: ImageUrls

    let link: ImageLink

    private enum CodingKeys: String, CodingKey {
        case description, altDescription = "alt_description", width, height, urls, link
    }
}

struct ImageLink: Decodable, Hashable {
    let html: String

    var htmlUrl: URL? {
        URL(string: html)
    }
}
