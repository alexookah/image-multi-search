//
//  PreviewImageSearchCell.swift
//  PhotoViewerApp
//
//  Created by Alexandros Lykesas on 28/11/20.
//

import UIKit
import Nuke

class PreviewImageSearchCell: UICollectionViewCell {

    static let reuseIdentifier: String = "PreviewImageSearchCell"

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var image: UIImageView!

    var resultItem: ResultItem!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configWith(resultItem: ResultItem) {
        self.resultItem = resultItem
        guard let imageURl = URL(string: resultItem.link) else { return }
        activityIndicator.startAnimating()

        let request = ImageRequest(url: imageURl, processors: [
            ImageProcessors.Resize(size: image.bounds.size)
        ])

        Nuke.loadImage(with: request, into: image) { [weak self] _ in
            self?.activityIndicator.stopAnimating()
        }
    }
}
