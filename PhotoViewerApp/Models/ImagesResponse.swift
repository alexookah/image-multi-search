//
//  ImagesResponse.swift
//  PhotoViewerApp
//
//  Created by Alexandros Lykesas on 26/11/20.
//

struct ImagesResponse: Codable {
    let items: [Item]
}

struct Item: Codable {
    let title: String
    let image: Image
    let link: String
}

struct Image: Codable {
    let width: Int
    let height: Int
    
    let thumbnailLink: String
    
    let thumbnailWidth: Int
    let thumbnailHeight: Int
}
