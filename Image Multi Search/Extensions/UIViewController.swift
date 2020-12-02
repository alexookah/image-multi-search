//
//  UIViewController.swift
//  Image Multi Search
//
//  Created by Alexandros Lykesas on 2/12/20.
//

import UIKit

extension UIViewController {

    func showAlertOK(titleToShow: String, textToShow: String) {
        let alertController = UIAlertController(title: titleToShow, message: textToShow, preferredStyle: .alert)

        let defaultAction = UIAlertAction(title: "ΟΚ", style: .default, handler: nil)

        alertController.addAction(defaultAction)

        self.present(alertController, animated: true, completion: nil)
    }
}
