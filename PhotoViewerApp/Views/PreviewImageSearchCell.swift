//
//  PreviewImageSearchCell.swift
//  PhotoViewerApp
//
//  Created by Alexandros Lykesas on 28/11/20.
//

import UIKit

class PreviewImageSearchCell: UICollectionViewCell {

    static let reuseIdentifier: String = "PreviewImageSearchCell"

    @IBOutlet weak var image: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configWith(resultItem: ResultItem) {
        image.downloadImage(from: resultItem.image.thumbnailLink)
    }

}
