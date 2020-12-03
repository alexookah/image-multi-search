//
//  CustomFlowLayout.swift
//  Image Multi Search
//
//  Created by Alexandros Lykesas on 2/12/20.
//

import UIKit

protocol CustomFlowLayoutDelegate: AnyObject {

    // Calculate the image height preserving the aspect's fit ratio image
    func collectionView(_ collectionView: UICollectionView,
                        sizeForImageAtIndexPath indexPath: IndexPath, desiredWidth: CGFloat) -> CGSize
}

class CustomFlowLayout: UICollectionViewFlowLayout {

    weak var layoutDelegate: CustomFlowLayoutDelegate?

    private var numberOfColumns: Int {
        return Orientation.isLandscape ? 3 : 2
    }
    private let cellPadding: CGFloat = 4
    private let labelHeight: CGFloat = 16 + 8 + 8

    private var cache: [UICollectionViewLayoutAttributes] = []

    private var contentHeight: CGFloat = 0

    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else { return 0 }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }

    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }

    override func invalidateLayout() {
        super.invalidateLayout()
        cache = []
    }

    override func prepare() {
        guard let collectionView = collectionView else { return }

        let columnWidth = contentWidth / CGFloat(numberOfColumns)
        var xOffset: [CGFloat] = []
        for column in 0..<numberOfColumns {
            xOffset.append(CGFloat(column) * columnWidth)
        }
        var column = 0
        var yOffset: [CGFloat] = .init(repeating: 0, count: numberOfColumns)

        for item in 0..<collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)

            let imageSize = layoutDelegate?.collectionView(collectionView, sizeForImageAtIndexPath: indexPath,
                                                           desiredWidth: columnWidth) ?? CGSize(width: columnWidth,
                                                                                                height: 90)
            let height = cellPadding * 2 + imageSize.height + labelHeight
            let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)

            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)

            contentHeight = max(contentHeight, frame.maxY)
            yOffset[column] = yOffset[column] + height

            column = column < (numberOfColumns - 1) ? (column + 1) : 0
        }
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes: [UICollectionViewLayoutAttributes] = []

        if cache.isEmpty {
            self.prepare()
        }

        // Loop through the cache and look for items in the rect
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
}
