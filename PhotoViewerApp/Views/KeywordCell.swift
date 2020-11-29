//
//  KeywordCell.swift
//  PhotoViewerApp
//
//  Created by Alexandros Lykesas on 29/11/20.
//

import UIKit

class KeywordCell: UITableViewCell {

    static let reuseIdentifier: String = "KeywordCell"

    @IBOutlet weak var textField: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
