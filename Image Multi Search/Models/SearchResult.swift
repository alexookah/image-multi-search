//
//  SearchResult.swift
//  PhotoViewerApp
//
//  Created by Alexandros Lykesas on 26/11/20.
//

struct SearchResult: Decodable, Hashable {
    let items: [ResultItem]
}
