//
//  ResultImage.swift
//  PhotoViewerApp
//
//  Created by Alexandros Lykesas on 28/11/20.
//

import UIKit

struct ImageUrls: Decodable, Hashable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String

    var imageReguralUrl: URL? {
        URL(string: regular)
    }
}
