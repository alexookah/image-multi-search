//
//  UserDefaults.swift
//  Image Multi Search
//
//  Created by Alexandros Lykesas on 1/12/20.
//

import Foundation

enum UserDefaultsKeys: String {
    case keywords
}

extension UserDefaults {

    // Save KeywordsList Data
    func setKeywordsList(value: [String]) {
        set(value, forKey: UserDefaultsKeys.keywords.rawValue)
    }

    // Retrieve KeywordsList Data
    func getKeywordsList() -> [String]? {
        return stringArray(forKey: UserDefaultsKeys.keywords.rawValue)
    }

}
