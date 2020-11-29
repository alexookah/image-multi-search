//
//  KeywordsManager.swift
//  PhotoViewerApp
//
//  Created by Alexandros Lykesas on 26/11/20.
//

import UIKit

class KeywordsManagerVC: UIViewController {

    var searchResults: [SearchResult] = []
    let keywords = [
        "boho interior design",
        "animal photography portait",
        "illustration",
        "ui design",
        "fashion photography",
        "flat lay photography",
        "minimalist typography",
        "library",
        "plants"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        searchImages()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? SearchResultsVC {
            viewController.searchResults = searchResults
        }
    }

    func searchImages() {
        keywords.forEach({ keyword in
            APIService.shared.getSearchResults(query: keyword) { (result: Result<SearchResult, APIServiceError>) in
                switch result {
                case .success(let searchResult):
                    self.searchResults.append(searchResult)
                    print(searchResult)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        })
    }

}
