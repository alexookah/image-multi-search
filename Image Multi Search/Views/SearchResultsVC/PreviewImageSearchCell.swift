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
    @IBOutlet weak var title: UILabel!

    func configWith(resultItem: ResultItem) {
        title.text = resultItem.title
        guard let imageURl = resultItem.imageUrl else { return }
        activityIndicator.startAnimating()

        let request = ImageRequest(url: imageURl, processors: [
            ImageProcessors.Resize(size: image.bounds.size) // resize image for performance improvements
        ])

        let options = ImageLoadingOptions(
            transition: .fadeIn(duration: 0.33),
            failureImage: UIImage(systemName: "exclamationmark.triangle"),
            contentModes: .init(success: .scaleAspectFill, failure: .center, placeholder: .center),
            tintColors: .init(success: .none, failure: .red, placeholder: .none)
        )

        Nuke.loadImage(with: request, options: options, into: image) { [weak self] _ in
            self?.activityIndicator.stopAnimating()
        }
    }

    static func nib() -> UINib {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }

}
