//
//  KeywordsViewModel.swift
//  image Multi Search
//
//  Created by Alexandros Lykesas on 30/11/20.
//

import Foundation
import Combine

class KeywordsViewModel {

    let demoSeachWords = [
        "boho interior design",
        "animal photography portrait",
        "illustration",
        "ui design",
        "fashion photography",
        "flat lay photography",
        "minimalist typography",
        "library",
        "plants"
    ]

    var keywords: [Keyword] = []

    init() {
        // load previously searched keywords from userDefaults
        if let previouslyUsedKeywords = UserDefaults.standard.getKeywordsList() {
            generateKeywords(words: previouslyUsedKeywords)
        } else {
            generateKeywords(words: demoSeachWords)
        }
        //
        keywords.append(Keyword(text: ""))
    }

    func generateKeywords(words: [String]) {
        words.forEach({ word in keywords.append(Keyword(text: word)) })
    }
}
