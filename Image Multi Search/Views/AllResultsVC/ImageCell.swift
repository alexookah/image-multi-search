//
//  ImageCell.swift
//  Image Multi Search
//
//  Created by Alexandros Lykesas on 2/12/20.
//

import UIKit
import Nuke

class ImageCell: UICollectionViewCell {

    static let reuseIdentifier: String = "ImageCell"

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var title: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configWith(resultItem: ResultItem) {
        title.text = resultItem.description ?? resultItem.altDescription
        guard let imageURl = resultItem.urls.imageReguralUrl else { return }
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
