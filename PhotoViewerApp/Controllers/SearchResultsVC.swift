//
//  SearchResultsVC.swift
//  PhotoViewerApp
//
//  Created by Alexandros Lykesas on 28/11/20.
//

import UIKit

class SearchResultsVC: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    var dataSource: UICollectionViewDiffableDataSource<SearchResult, ResultItem>?

    var searchResults: [SearchResult] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.collectionViewLayout = createCompositionalLayout()

        let nib = UINib(nibName: PreviewImageSearchCell.reuseIdentifier, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: PreviewImageSearchCell.reuseIdentifier)

        createDataSource()
        loadData()
    }

    func createDataSource() {
        dataSource = UICollectionViewDiffableDataSource
        <SearchResult, ResultItem>(collectionView: collectionView) { collectionView, indexPath, searchResult in

            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PreviewImageSearchCell.reuseIdentifier,
                                                          for: indexPath) as? PreviewImageSearchCell
            cell?.configWith(resultItem: searchResult)
            return cell
        }
    }

    func loadData() {

        var snapshot = NSDiffableDataSourceSnapshot<SearchResult, ResultItem>()
        snapshot.appendSections(self.searchResults)

        for searchResult in self.searchResults {
            snapshot.appendItems(searchResult.items, toSection: searchResult)
        }

        dataSource?.apply(snapshot)
    }

    func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in
            let searchResult = self.searchResults[sectionIndex]
            return self.createImageResultsSection(using: searchResult)
        }

        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 20
        layout.configuration = config
        return layout
    }

    func createImageResultsSection(using section: SearchResult) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .fractionalHeight(1))

        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        layoutItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)

        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.90),
                                                     heightDimension: .estimated(350))
        let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: layoutGroupSize, subitems: [layoutItem])

        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        layoutSection.orthogonalScrollingBehavior = .groupPagingCentered
        return layoutSection
    }

}
