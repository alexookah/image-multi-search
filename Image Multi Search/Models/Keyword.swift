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
    case typing
    case loading
    case success
    case noItems
    case failed
}

class Keyword {

    let uuId = UUID()

    var text: String {
        get { textPublisher.value }
        set { textPublisher.value = newValue }
    }

    var searchResult: SearchResult?
    var apiStatus: SearchResultStatus = .none

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

    // Observe the keyword changes in order to have ready the search results for the next screen
    // using some Combine operators debounce, filter and removeDuplicates
    func observeTextChanges() {
        textPublisher
            .handleEvents(receiveOutput: { value in
                self.searchResultStatusPublisher.send(value.isEmpty ? .none : .typing)
            })
            .debounce(for: .seconds(1.0), scheduler: DispatchQueue.main)
            .filter({ !$0.isEmpty })
            .removeDuplicates { prev, current in // do not make the same api request
                if prev == current {
                    self.searchResultStatusPublisher.send(self.apiStatus)
                }
                if prev == current && self.apiStatus == .failed {
                    return false // same keyword allow to continue, because the apiStatus failed
                } else {
                    return prev == current
                }

            }
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
                    switch error {
                    case .decodeError:
                        self?.apiStatus = .noItems
                        self?.searchResultStatusPublisher.send(.noItems)
                    default:
                        self?.apiStatus = .failed
                        self?.searchResultStatusPublisher.send(.failed)
                    }
                case .finished:
                    print("finished:")
                    self?.apiStatus = .success
                    self?.searchResultStatusPublisher.send(.success)
                    self?.searchResult?.sectionTitle = text
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
