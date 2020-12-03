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

    let startIndexPublisher = CurrentValueSubject<Int, Never>(0)
    weak var onNewItemsReceivedDelegate: PagingItemsReceivedDelegate?

    var subscriptions = Set<AnyCancellable>()

    init(text: String) {
        self.text = text
        observeTextChanges()
        observeStartIndexValues()
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
                    return false // same keyword was re-entered, allow to continue, because the apiStatus failed
                } else {
                    return prev == current
                }

            }
            .receive(on: RunLoop.main)
            .sink { value in
                print("new query: ", value)
                self.searchResult?.items = []
                self.getSearchResultWith(text: value, startIndex: self.startIndexPublisher.value)
            }
            .store(in: &subscriptions)
    }

    func getSearchResultWith(text: String, startIndex: Int) {
        guard let url = APIService.shared.createURL(queryText: text, startIndex: startIndex).url else { return }

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
                }
            }, receiveValue: { [weak self] searchResult in
                self?.handleSearchResults(searchResult)
            })
            .store(in: &self.subscriptions)
    }

    func observeStartIndexValues() {
        startIndexPublisher
            .filter({ $0 != 0 })
            .filter({ $0 < 300 }) // filter 300 items for each search
            .sink(receiveValue: { startIndexValue in
                print("lets make a new request: ", startIndexValue)
                self.getSearchResultWith(text: self.text, startIndex: startIndexValue)
            })
            .store(in: &self.subscriptions)
    }

    // Handle new searchResults, append in searchResultItems for next results
    private func handleSearchResults(_ newSearchResult: SearchResult) {
        if searchResult == nil {
            searchResult = newSearchResult
        } else {
            searchResult?.items.append(contentsOf: newSearchResult.items)
            onNewItemsReceivedDelegate?.newItemsReceived(newSearchResult)
        }
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
