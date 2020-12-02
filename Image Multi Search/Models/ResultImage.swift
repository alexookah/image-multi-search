//
//  ResultImage.swift
//  PhotoViewerApp
//
//  Created by Alexandros Lykesas on 28/11/20.
//

import UIKit

struct ResultImage: Decodable, Hashable {
    let width: CGFloat
    let height: CGFloat

    let thumbnailLink: String

    let thumbnailWidth: Int
    let thumbnailHeight: Int
}
