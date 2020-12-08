//
//  SearchResult.swift
//  PhotoViewerApp
//
//  Created by Alexandros Lykesas on 26/11/20.
//

struct SearchResult: Decodable, Hashable {
    var results: [ResultItem]
    let total: Int
    let totalPages: Int

    private enum CodingKeys: String, CodingKey {
        case results, total, totalPages = "total_pages"
    }
}
