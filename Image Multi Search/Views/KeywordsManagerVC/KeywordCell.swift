//
//  KeywordCell.swift
//  PhotoViewerApp
//
//  Created by Alexandros Lykesas on 29/11/20.
//

import UIKit
import Combine

protocol TapCellDelegate: AnyObject {
    func addTappedAction()
}

class KeywordCell: UITableViewCell {

    static let reuseIdentifier: String = "KeywordCell"

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var statusImage: UIImageView!

    weak var tapCellDelegate: TapCellDelegate?

    var cancellables = Set<AnyCancellable>()

    override func prepareForReuse() {
        super.prepareForReuse()
        cancellables.forEach { $0.cancel() }
    }

    var keyword: Keyword?

    func config(keyword: Keyword) {
        self.keyword = keyword
        textField.text = keyword.text

        addGestureRecognizerInStatusImage()
        observeSearchResultStatus(keyword: keyword)
    }

    @IBAction func textFieldDidChange(_ sender: UITextField) {
        guard let newText = sender.text else { return }
        self.keyword?.text = newText
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

                case .loading:
                    self.activityIndicator.startAnimating()
                    self.statusImage.isHidden = true

                case .typing:
                    self.setStatusImage(systemName: "ellipsis")
                case .success:
                    self.setStatusImage(systemName: "checkmark.circle")
                case .noItems:
                    self.setStatusImage(systemName: "xmark.circle")
                case .failed:
                    self.setStatusImage(systemName: "exclamationmark.triangle")
                }
            }
            .store(in: &cancellables)
        }

    func setStatusImage(systemName: String) {
        statusImage.isHidden = false
        activityIndicator.stopAnimating()
        statusImage.image = UIImage(systemName: systemName)
    }

    func addGestureRecognizerInStatusImage() {
        statusImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:))))
    }

    @objc func imageTapped(_ sender: UITapGestureRecognizer) {
        tapCellDelegate?.addTappedAction()
    }

}
