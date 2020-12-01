//
//  Keyword.swift
//  image Multi Search
//
//  Created by Alexandros Lykesas on 30/11/20.
//

import UIKit
import Combine

enum SearchResultStatus {
    case none
    case loading
    case success
    case failed
}

class Keyword {

    let uuId = UUID()

    var text: String {
        get { textPublisher.value }
        set { textPublisher.value = newValue }
    }

    var searchResult: SearchResult?

    let textPublisher = CurrentValueSubject<String, Never>("")
    let searchResultStatusPublisher = CurrentValueSubject<SearchResultStatus, Never>(.none)

    var subscriptions = Set<AnyCancellable>()

    init(text: String) {
        self.text = text
        observeTextChanges()
    }

    deinit {
        subscriptions.forEach { $0.cancel() }
    }

    func observeTextChanges() {
        textPublisher
            .handleEvents(receiveOutput: { value in
                if value.isEmpty {
                    self.searchResultStatusPublisher.send(.none)
                } else {
                    self.searchResultStatusPublisher.send(.loading)
                }
            })
            .debounce(for: .seconds(1.0), scheduler: DispatchQueue.main)
            .filter({ !$0.isEmpty })
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { value in
                print("new query: ", value)
                self.getSearchResultWith(text: value)
            }
            .store(in: &subscriptions)
    }

    func getSearchResultWith(text: String) {
        guard let url = APIService.shared.createURL(queryText: text).url else { return }

        searchResultStatusPublisher.send(.loading)

        APIService.shared.request(url: url)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("ERROR:", error)
                    self?.searchResultStatusPublisher.send(.failed)
                case .finished:
                    print("finished:")
                    self?.searchResultStatusPublisher.send(.success)
                }
            }, receiveValue: { [weak self] searchResult in
                self?.searchResult = searchResult
            })
            .store(in: &subscriptions)
    }

}

// MARK: Hashable functions
extension Keyword: Hashable {

    static func == (lhs: Keyword, rhs: Keyword) -> Bool {
        lhs.uuId == rhs.uuId
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(uuId)
    }
}