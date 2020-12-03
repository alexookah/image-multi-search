//
//  ResultItem.swift
//  PhotoViewerApp
//
//  Created by Alexandros Lykesas on 28/11/20.
//

import UIKit

struct ResultItem: Decodable, Hashable {

    let uuid = UUID()
    private enum CodingKeys: String, CodingKey { case title, displayLink, image, link }

    let title: String
    let displayLink: String
    let image: ResultImage
    let link: String

    var imageUrl: URL? {
        URL(string: link)
    }
}
