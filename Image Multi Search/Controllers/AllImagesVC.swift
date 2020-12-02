//
//  AllImagesVC.swift
//  Image Multi Search
//
//  Created by Alexandros Lykesas on 2/12/20.
//

import UIKit

class AllImagesVC: UICollectionViewController {

    var keyword: Keyword!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = keyword.text.uppercased()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        collectionView.register(ImageCell.nib(), forCellWithReuseIdentifier: ImageCell.reuseIdentifier)

        if let layout = collectionView?.collectionViewLayout as? CustomFlowLayout {
          layout.layoutDelegate = self
        }

        collectionView?.contentInset = UIEdgeInsets(top: 23, left: 8, bottom: 10, right: 8)
    }
}

// MARK: UICollectionViewDataSource

extension AllImagesVC {

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return keyword.searchResult?.items.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.reuseIdentifier,
                                                          for: indexPath) as? ImageCell,
            let resultItem = keyword.searchResult?.items[indexPath.item]
        else { return UICollectionViewCell() }

        cell.configWith(resultItem: resultItem)
        return cell
    }
}

// MARK: CustomFlowLayoutDelegate

extension AllImagesVC: CustomFlowLayoutDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        sizeForImageAtIndexPath indexPath: IndexPath, desiredWidth: CGFloat) -> CGSize {
        guard let searchResult = keyword.searchResult else { return CGSize(width: desiredWidth, height: 90) }

        let image = searchResult.items[indexPath.item].image

        let ratio = desiredWidth / image.width
        let scaledHeight = image.height * ratio

        return CGSize(width: desiredWidth, height: scaledHeight)
    }
}
