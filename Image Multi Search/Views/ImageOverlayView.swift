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
    case openLink
}

protocol ImageOverlayViewDelegate: class {
    func overlayView(_ overlayView: ImageOverlayView, didSelectAction action: OverlayViewActions)
}

class ImageOverlayView: AgrumeOverlayView {

    @IBOutlet weak var topNavigationBar: UINavigationBar!
    @IBOutlet weak var bottomNavigationBar: UINavigationBar!

    weak var delegate: ImageOverlayViewDelegate?

    func configure() {
        makeClearMavigationBar(navigationBar: topNavigationBar)
        makeClearMavigationBar(navigationBar: bottomNavigationBar)

        backgroundColor = .clear
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
        delegate?.overlayView(self, didSelectAction: .openLink)
    }

    func createAgrumePhotoLibraryHelper(from vc: UIViewController) -> AgrumePhotoLibraryHelper {
        let helper = AgrumePhotoLibraryHelper(saveButtonTitle: "Save Photo",
                                              cancelButtonTitle: "Cancel") { error in
            guard error == nil else {
                vc.showAlertOK(titleToShow: "Photo", textToShow: "Saving the photo to your library failed")
                return
            }
            vc.showAlertOK(titleToShow: "Photo", textToShow: "Your photo has been saved to your library")
        }
        return helper
    }
}
