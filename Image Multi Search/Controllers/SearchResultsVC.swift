//
//  SearchResultsVC.swift
//  PhotoViewerApp
//
//  Created by Alexandros Lykesas on 28/11/20.
//

import UIKit
import Nuke

class SearchResultsVC: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    var dataSource: UICollectionViewDiffableDataSource<Keyword, ResultItem>?

    var keywordsViewModel: KeywordsViewModel!

    let preheater = ImagePreheater()

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.collectionViewLayout = createCompositionalLayout()

        collectionView.register(SectionHeader.nib(),
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: SectionHeader.reuseIdentifier)

        collectionView.register(PreviewImageSearchCell.nib(),
                                forCellWithReuseIdentifier: PreviewImageSearchCell.reuseIdentifier)

        collectionView.register(SectionFooter.nib(),
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: SectionFooter.reuseIdentifier)

        createDataSource()
        createHeaderAndFooter()
//        createFooter()

        loadData()
    }

    func createDataSource() {
        dataSource = UICollectionViewDiffableDataSource
        <Keyword, ResultItem>(collectionView: collectionView) { collectionView, indexPath, searchResult in

            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PreviewImageSearchCell.reuseIdentifier,
                                                          for: indexPath) as? PreviewImageSearchCell
            cell?.configWith(resultItem: searchResult)
            return cell
        }
    }

    func createHeaderAndFooter() {
        dataSource?.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            if kind == UICollectionView.elementKindSectionHeader {
                guard let header = collectionView
                        .dequeueReusableSupplementaryView(ofKind: kind,
                                                          withReuseIdentifier: SectionHeader.reuseIdentifier,
                                                          for: indexPath) as? SectionHeader  else { return nil }

                guard
                    let firstKeyword = self?.dataSource?.itemIdentifier(for: indexPath),
                    let keyword = self?.dataSource?.snapshot().sectionIdentifier(containingItem: firstKeyword),
                    let searchResult = keyword.searchResult, searchResult.items.count > 0
                else { return header }

                header.configWith(keyword: keyword)
                return header
            } else {
                guard let footer = collectionView
                        .dequeueReusableSupplementaryView(ofKind: kind,
                                                          withReuseIdentifier: SectionFooter.reuseIdentifier,
                                                          for: indexPath) as? SectionFooter
                else { return nil }

                return footer
            }
        }
    }

    func loadData() {

        var snapshot = NSDiffableDataSourceSnapshot<Keyword, ResultItem>()
        snapshot.appendSections(keywordsViewModel.keywords)

        for keyword in keywordsViewModel.keywords {
            guard let searchResultItems = keyword.searchResult?.items else { continue }
            snapshot.appendItems(searchResultItems, toSection: keyword)
        }

        dataSource?.apply(snapshot)
    }

    func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in
            guard let searchResultItems = self.keywordsViewModel.keywords[sectionIndex].searchResult?.items,
                  !searchResultItems.isEmpty else { return nil}
            return self.createImageResultsSection(using: self.keywordsViewModel.keywords[sectionIndex])
        }

        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 20
        layout.configuration = config
        return layout
    }

    func createImageResultsSection(using section: Keyword) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .fractionalHeight(1))

        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        layoutItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)

        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.90),
                                                     heightDimension: .estimated(350))
        let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: layoutGroupSize, subitems: [layoutItem])

        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        layoutSection.orthogonalScrollingBehavior = .groupPagingCentered

        let layoutSectionHeader = createSectionHeaderLayout()
        let layoutSectionFooter = createSectionFooterLayout()
        layoutSection.boundarySupplementaryItems = [layoutSectionHeader, layoutSectionFooter]

        return layoutSection
    }

    func createSectionHeaderLayout() -> NSCollectionLayoutBoundarySupplementaryItem {
        let layoutSectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.93),
                                                             heightDimension: .estimated(80))
        let layout = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: layoutSectionHeaderSize,
                                                                 elementKind: UICollectionView.elementKindSectionHeader,
                                                                 alignment: .top)
        return layout
    }

    func createSectionFooterLayout() -> NSCollectionLayoutBoundarySupplementaryItem {
        let layoutSectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.93),
                                                             heightDimension: .estimated(40))
        let layout = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: layoutSectionHeaderSize,
                                                                 elementKind: UICollectionView.elementKindSectionFooter,
                                                                 alignment: .bottom)
        return layout
    }

}

// MARK: UICollectionViewDataSourcePrefetching

extension SearchResultsVC: UICollectionViewDataSourcePrefetching {

    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let urls = indexPaths.compactMap { keywordsViewModel.keywords[$0.section].searchResult?.items[$0.row].imageUrl }
        preheater.startPreheating(with: urls)
        print("prefetchItemsAt: \(stringForIndexPaths(indexPaths))")
    }

    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        let urls = indexPaths.compactMap { keywordsViewModel.keywords[$0.section].searchResult?.items[$0.row].imageUrl }
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
