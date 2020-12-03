//
//  AllImagesVC.swift
//  Image Multi Search
//
//  Created by Alexandros Lykesas on 2/12/20.
//

import UIKit
import Nuke
import Agrume

protocol PagingItemsReceivedDelegate: AnyObject {
    func newItemsReceived()
}

class AllImagesVC: UICollectionViewController {

    var keyword: Keyword!

    private var agrume: Agrume?

    let preheater = ImagePreheater()

    override func viewDidLoad() {
        super.viewDidLoad()

        keyword.onNewItemsReceivedDelegate = self

        navigationItem.title = keyword.text.uppercased()

        // Register cell classes
        collectionView.register(ImageCell.nib(), forCellWithReuseIdentifier: ImageCell.reuseIdentifier)

        if let layout = collectionView?.collectionViewLayout as? CustomFlowLayout {
            layout.layoutDelegate = self
        }

        collectionView.contentInset = UIEdgeInsets(top: 23, left: 8, bottom: 10, right: 8)
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

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let searchResultItems = keyword.searchResult?.items else { return }

        let allUrls = keyword.searchResult?.items.compactMap { $0.imageUrl } ?? []

        let agrumeBackground: Background = .blurred(.regular)

        let overlayView = ImageOverlayView.instanceFromNib()
        overlayView.configure()
        overlayView.configText(with: searchResultItems[indexPath.item])
        overlayView.delegate = self

        agrume = Agrume(urls: allUrls, startIndex: indexPath.item,
                            background: agrumeBackground, overlayView: overlayView)

        let helper = overlayView.createAgrumePhotoLibraryHelper(from: self)
        agrume?.onLongPress = helper.makeSaveToLibraryLongPressGesture

        agrume?.show(from: self)

        agrume?.didScroll = { [unowned self] index in
            DispatchQueue.main.async {
                self.collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: [], animated: false)
                self.collectionView.setNeedsLayout()
                overlayView.configText(with: searchResultItems[index])
            }
        }
        agrume?.willDismiss = {
            collectionView.setNeedsLayout()
        }
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == collectionView.numberOfItems(inSection: indexPath.section) - 1,
           let totalItems = keyword.searchResult?.items.count {
            keyword.startIndexPublisher.send(totalItems)
        }
    }
}

extension AllImagesVC: PagingItemsReceivedDelegate {

    func newItemsReceived() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}

extension AllImagesVC: ImageOverlayViewDelegate {

    // Action buttons from AgrumeOverlay
    func overlayView(_ overlayView: ImageOverlayView, didSelectAction action: OverlayViewActions) {
        switch action {
        case .close:
            agrume?.dismiss()
        case .share:
            guard let currentIndex = agrume?.currentIndex else { return }

            agrume?.image(forIndex: currentIndex, completion: { [weak self] image in
                guard let image = image else { return }
                let uiActivityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
                self?.agrume?.present(uiActivityVC, animated: true)
            })
        }
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

        if let cell = collectionView.cellForItem(at: indexPath) as? ImageCell {
            cell.layoutIfNeeded()
        }

        return CGSize(width: desiredWidth, height: scaledHeight)
    }
}

// MARK: UICollectionViewDataSourcePrefetching

extension AllImagesVC: UICollectionViewDataSourcePrefetching {

    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let urls = indexPaths.compactMap { keyword.searchResult?.items[$0.row].imageUrl }
        preheater.startPreheating(with: urls)
        print("prefetchItemsAt: \(stringForIndexPaths(indexPaths))")
    }

    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        let urls = indexPaths.compactMap { keyword.searchResult?.items[$0.row].imageUrl }
        preheater.stopPreheating(with: urls)
        print("cancelPrefetchingForItemsAt: \(stringForIndexPaths(indexPaths))")
    }

    private func stringForIndexPaths(_ indexPaths: [IndexPath]) -> String {
        guard indexPaths.count > 0 else {
            return "[]"
        }
        let items = indexPaths
            .map { return "\(($0 as NSIndexPath).item)" }
            .joined(separator: " ")
        return "[\(items)]"
    }
}
