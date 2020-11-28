//
//  ResultItem.swift
//  PhotoViewerApp
//
//  Created by Alexandros Lykesas on 28/11/20.
//

struct ResultItem: Decodable, Hashable {
    let title: String
    let image: ResultImage
    let link: String
}
