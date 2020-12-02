//
//  PopupVC.swift
//  Image Multi Search
//
//  Created by Alexandros Lykesas on 2/12/20.
//

import UIKit

class PopupVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func didTapOnBackground(_ sender: UITapGestureRecognizer) {
        dismissVC()
    }

    @IBAction func didTapOnOkay(_ sender: UIButton) {
        dismissVC()
    }

    func dismissVC() {
        dismiss(animated: true, completion: nil)
    }

}
