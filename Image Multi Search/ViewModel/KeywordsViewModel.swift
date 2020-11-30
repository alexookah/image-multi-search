//
//  KeywordsViewModel.swift
//  image Multi Search
//
//  Created by Alexandros Lykesas on 30/11/20.
//

import Foundation
import Combine

class KeywordsViewModel {

    var words = [
        "boho interior design",
        "animal photography portait",
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
        words.forEach({ word in keywords.append(Keyword(text: word)) })
        keywords.append(Keyword(text: ""))
    }
}
