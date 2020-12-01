//
//  SectionHeader.swift
//  Image Multi Search
//
//  Created by Alexandros Lykesas on 2/12/20.
//

import UIKit

class SectionHeader: UICollectionReusableView {

    static let reuseIdentifier = "SectionHeader"

    @IBOutlet weak var seperator: UIView!

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!

    func configWith(keyword: Keyword) {
        title.text = keyword.searchResult?.sectionTitle?.uppercased()
        let totalResults = keyword.searchResult?.searchInformation.formattedTotalResults

        if let totalResults = totalResults {
            subtitle.text = "total results: " + totalResults.replacingOccurrences(of: ",", with: ".")
        } else {
            subtitle.isHidden = true
        }
    }

    static func nib() -> UINib {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }

}
