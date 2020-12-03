//
//  ImageOverlayView.swift
//  Image Multi Search
//
//  Created by Alexandros Lykesas on 2/12/20.
//

import UIKit
import Agrume

enum OverlayViewActions {
    case close
    case share
}

protocol ImageOverlayViewDelegate: AnyObject {
    func overlayView(_ overlayView: ImageOverlayView, didSelectAction action: OverlayViewActions)
}

class ImageOverlayView: AgrumeOverlayView {

    @IBOutlet weak var topNavigationBar: UINavigationBar!
    @IBOutlet weak var bottomNavigationBar: UINavigationBar!
    @IBOutlet weak var text: UILabel!

    weak var delegate: ImageOverlayViewDelegate?
    private var resultItem: ResultItem?

    func configure() {
        makeClearMavigationBar(navigationBar: topNavigationBar)
        makeClearMavigationBar(navigationBar: bottomNavigationBar)

        backgroundColor = .clear
    }

    func configText(with resultItem: ResultItem) {
        self.resultItem = resultItem
        text.text = resultItem.title
    }

    func makeClearMavigationBar(navigationBar: UINavigationBar) {
        navigationBar.isTranslucent = true
        navigationBar.shadowImage = UIImage()
        navigationBar.setBackgroundImage(UIImage(), for: .default)
    }

    class func instanceFromNib() -> ImageOverlayView {
        return UINib(nibName: "ImageOverlayView", bundle: nil)
            .instantiate(withOwner: nil, options: nil)[0] as? ImageOverlayView ?? ImageOverlayView()
    }

    @IBAction func tappedClose(_ sender: UIBarButtonItem) {
        delegate?.overlayView(self, didSelectAction: .close)
    }

    @IBAction func tappedShare(_ sender: UIBarButtonItem) {
        delegate?.overlayView(self, didSelectAction: .share)
    }

    @IBAction func tappedOpenLink(_ sender: UIBarButtonItem) {
        if let url = resultItem?.image.contextLinkURL {
            UIApplication.shared.open(url)
        }
    }

    func createAgrumePhotoLibraryHelper(from viewController: UIViewController) -> AgrumePhotoLibraryHelper {
        let helper = AgrumePhotoLibraryHelper(saveButtonTitle: "Save Photo",
                                              cancelButtonTitle: "Cancel") { error in
            guard error == nil else {
                viewController.showAlertOK(titleToShow: "Photo", textToShow: "Saving the photo to your library failed")
                return
            }
            viewController.showAlertOK(titleToShow: "Photo", textToShow: "Your photo has been saved to your library")
        }
        return helper
    }
}
