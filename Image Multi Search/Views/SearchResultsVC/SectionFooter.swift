//
//  SectionFooter.swift
//  Image Multi Search
//
//  Created by Alexandros Lykesas on 2/12/20.
//

import UIKit

class SectionFooter: UICollectionReusableView {

    static let reuseIdentifier = "SectionFooter"

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    static func nib() -> UINib {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }
}
