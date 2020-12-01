//
//  KeywordsManager.swift
//  PhotoViewerApp
//
//  Created by Alexandros Lykesas on 26/11/20.
//

import UIKit

class KeywordsManagerVC: UIViewController {

    let keywordsViewModel = KeywordsViewModel()

    @IBOutlet weak var leftButton: UIBarButtonItem!
    @IBOutlet weak var rightButton: UIBarButtonItem!

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? SearchResultsVC {
            viewController.keywordsViewModel = keywordsViewModel
        }
    }

    // save current text list in userDefaults omitting empty values
    @IBAction func searchButtonClicked(_ sender: Any) {
        UserDefaults.standard.setKeywordsList(value: keywordsViewModel.keywords.map({ $0.text }).filter { !$0.isEmpty })
    }

    @IBAction func rightButtonClicked(_ sender: UIBarButtonItem) {

        if tableView.isEditing {
            removeRows(indexPathsToRemove: tableView.indexPathsForSelectedRows ?? [])
        } else {
            addRow()
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
        return keywordsViewModel.keywords.count
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = keywordsViewModel.keywords[sourceIndexPath.row]
        keywordsViewModel.keywords.remove(at: sourceIndexPath.row)
        keywordsViewModel.keywords.insert(movedObject, at: destinationIndexPath.row)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: KeywordCell.reuseIdentifier,
                                                       for: indexPath) as? KeywordCell else { return UITableViewCell() }

        let keyword = keywordsViewModel.keywords[indexPath.row]
        cell.config(keyword: keyword, keywordsViewModel: keywordsViewModel)
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

    private func removeRows(indexPathsToRemove: [IndexPath]) {
        indexPathsToRemove.sorted(by: >).forEach({ self.keywordsViewModel.keywords.remove(at: $0.row) })
        self.tableView.deleteRows(at: indexPathsToRemove, with: .fade)
    }

    private func addRow() {
        let newIndexPath = IndexPath(row: keywordsViewModel.keywords.count, section: 0)
        keywordsViewModel.keywords.append(Keyword(text: ""))
        tableView.insertRows(at: [newIndexPath], with: .automatic)
    }
}
