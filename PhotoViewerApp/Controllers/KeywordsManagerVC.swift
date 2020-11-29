//
//  KeywordsManager.swift
//  PhotoViewerApp
//
//  Created by Alexandros Lykesas on 26/11/20.
//

import UIKit

class KeywordsManagerVC: UIViewController {

    var searchResults: [SearchResult] = []
    var keywords = [
        "boho interior design",
        "animal photography portait",
        "illustration",
        "ui design",
        "fashion photography",
        "flat lay photography",
        "minimalist typography",
        "library",
        "plants"
    ]

    @IBOutlet weak var leftButton: UIBarButtonItem!
    @IBOutlet weak var rightButton: UIBarButtonItem!

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        searchImages()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? SearchResultsVC {
            viewController.searchResults = searchResults
        }
    }

    func searchImages() {
        keywords.forEach({ keyword in
            APIService.shared.getSearchResults(query: keyword) { (result: Result<SearchResult, APIServiceError>) in
                switch result {
                case .success(let searchResult):
                    self.searchResults.append(searchResult)
                    print(searchResult)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        })
    }

    @IBAction func rightButtonClicked(_ sender: UIBarButtonItem) {

        if tableView.isEditing {
            self.removeRows(indexPathsToRemove: tableView.indexPathsForSelectedRows ?? [])
        } else {
            let newIndexPath = IndexPath(row: keywords.count, section: 0)
            keywords.append("new search added")
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        }
    }

    @IBAction func leftButtonClicked(_ sender: UIBarButtonItem) {
        tableView.isEditing = !tableView.isEditing

        // Update left button icon
        let leftNewButton = UIBarButtonItem(barButtonSystemItem: tableView.isEditing ? .done : .edit, target: self,
                                        action: #selector(leftButtonClicked(_:)))
        navigationItem.setLeftBarButton(leftNewButton, animated: true)

        // Update right button icon
        let rightNewButton = UIBarButtonItem(barButtonSystemItem: tableView.isEditing ? .trash : .add, target: self,
                                        action: #selector(rightButtonClicked(_:)))
        navigationItem.setRightBarButton(rightNewButton, animated: true)
    }

}

// MARK: UITableViewDataSource

extension KeywordsManagerVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keywords.count
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = keywords[sourceIndexPath.row]
        keywords.remove(at: sourceIndexPath.row)
        keywords.insert(movedObject, at: destinationIndexPath.row)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: KeywordCell.reuseIdentifier,
                                                       for: indexPath) as? KeywordCell else { return UITableViewCell() }

        cell.textField.text = keywords[indexPath.row]
        return cell
    }

}

// MARK: UITableViewDelegate

extension KeywordsManagerVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return UISwipeActionsConfiguration(actions: [
            makeDeleteContextualAction(forRowAt: indexPath)
        ])
    }

    // MARK: - Contextual Actions
    private func makeDeleteContextualAction(forRowAt indexPath: IndexPath) -> UIContextualAction {
        return UIContextualAction(style: .destructive, title: "Delete") { (_, _, completion) in

            self.removeRows(indexPathsToRemove: [indexPath])
            completion(true)
        }
    }

    func removeRows(indexPathsToRemove: [IndexPath]) {
        indexPathsToRemove.sorted(by: >).forEach({ self.keywords.remove(at: $0.row) })
        self.tableView.deleteRows(at: indexPathsToRemove, with: .fade)
    }
}
