//
//  Orientation.swift
//  Image Multi Search
//
//  Created by Alexandros Lykesas on 2/12/20.
//

import UIKit

struct Orientation {

    // indicate current device is in the LandScape orientation
    static var isLandscape: Bool {
        return UIDevice.current.orientation.isValidInterfaceOrientation
            ? UIDevice.current.orientation.isLandscape
            : (UIApplication.shared.windows.first?.windowScene?.interfaceOrientation.isLandscape)!
    }

    // indicate current device is in the Portrait orientation
    static var isPortrait: Bool {
        return UIDevice.current.orientation.isValidInterfaceOrientation
            ? UIDevice.current.orientation.isPortrait
            : (UIApplication.shared.windows.first?.windowScene?.interfaceOrientation.isPortrait)!
    }
}
