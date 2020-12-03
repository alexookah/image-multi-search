//
//  SearchResult.swift
//  PhotoViewerApp
//
//  Created by Alexandros Lykesas on 26/11/20.
//

struct SearchResult: Decodable, Hashable {
    var items: [ResultItem]
    let searchInformation: SearchInformation
}

struct SearchInformation: Decodable, Hashable {
    var formattedSearchTime: String
    var formattedTotalResults: String
}
