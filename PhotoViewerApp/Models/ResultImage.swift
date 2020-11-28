//
//  ResultImage.swift
//  PhotoViewerApp
//
//  Created by Alexandros Lykesas on 28/11/20.
//

import Foundation

struct ResultImage: Decodable, Hashable {
    let width: Int
    let height: Int
    
    let thumbnailLink: String
    
    let thumbnailWidth: Int
    let thumbnailHeight: Int
}
