//
//  SectionFooter.swift
//  Image Multi Search
//
//  Created by Alexandros Lykesas on 2/12/20.
//

import UIKit

protocol SearchResultsVCDelegate: AnyObject {
    func showMoreResults(keyword: Keyword)
}

class SectionFooter: UICollectionReusableView {

    static let reuseIdentifier = "SectionFooter"

    weak var searchResultsVCDelegate: SearchResultsVCDelegate?

    var keyword: Keyword?

    @IBAction func viewMoreTapped(_ sender: UIButton) {
        guard let keyword = keyword else { return }
        searchResultsVCDelegate?.showMoreResults(keyword: keyword)
    }

    static func nib() -> UINib {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }
}
