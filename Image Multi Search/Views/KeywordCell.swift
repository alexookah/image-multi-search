//
//  KeywordCell.swift
//  PhotoViewerApp
//
//  Created by Alexandros Lykesas on 29/11/20.
//

import UIKit
import Combine

class KeywordCell: UITableViewCell {

    static let reuseIdentifier: String = "KeywordCell"

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var statusImage: UIImageView!

    var cancellables = Set<AnyCancellable>()

    override func prepareForReuse() {
        super.prepareForReuse()
        cancellables.forEach { $0.cancel() }
    }

    func config(keyword: Keyword, keywordsViewModel: KeywordsViewModel) {
        textField.text = keyword.text

        observeTextFieldChanges(keyword: keyword)
        observeSearchResultStatus(keyword: keyword)
    }

    func observeTextFieldChanges(keyword: Keyword) {
        let textFieldPublisher = NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: textField)
            .map({ ($0.object as? UITextField)?.text })

        textFieldPublisher
            .receive(on: RunLoop.main)
            .sink(receiveValue: { value in
                keyword.text = value ?? ""
                print("keyword textfield changed to: \(value ?? "")")
            })
            .store(in: &cancellables)
    }

    func observeSearchResultStatus(keyword: Keyword) {
        keyword.searchResultStatusPublisher
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { value in
                print("search result status: ", value)
                switch value {
                case .none:
                    self.activityIndicator.stopAnimating()
                    self.statusImage.isHidden = true
                case .typing:
                    self.activityIndicator.stopAnimating()
                    self.statusImage.image = UIImage(systemName: "ellipsis")
                case .loading:
                    self.showOrHideActivityIndicator(shouldShow: true)
                    self.activityIndicator.startAnimating()
                case .success:
                    self.showOrHideActivityIndicator(shouldShow: false)
                    self.statusImage.image = UIImage(systemName: "checkmark.circle")
                case .failed:
                    self.showOrHideActivityIndicator(shouldShow: false)
                    self.statusImage.image = UIImage(systemName: "xmark.circle")
                }

            }
            .store(in: &cancellables)
    }

    func showOrHideActivityIndicator(shouldShow: Bool) {
        statusImage.isHidden = shouldShow
        shouldShow ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }

}
