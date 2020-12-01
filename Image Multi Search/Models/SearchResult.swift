//
//  SearchResult.swift
//  PhotoViewerApp
//
//  Created by Alexandros Lykesas on 26/11/20.
//

struct SearchResult: Decodable, Hashable {
    let items: [ResultItem]
    let searchInformation: SearchInformation

    // custom defined values
    var sectionTitle: String?
    var sectionSubtitle: String?

}

struct SearchInformation: Decodable, Hashable {
    var formattedSearchTime: String
    var formattedTotalResults: String
}
