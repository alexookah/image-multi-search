//
//  APIService.swift
//  PhotoViewerApp
//
//  Created by Alexandros Lykesas on 26/11/20.
//

import UIKit
import Combine

enum APIServiceError: Error {
    case invalidURL
    case invalidResponse
    case sessionFailed(error: URLError)
    case decodeError
    case other(Error)
}

class APIService {

    static let shared = APIService()

    private let urlSession = URLSession.shared

    let baseURLString = "https://api.unsplash.com/search/photos"

    private var apiKey: String {
        guard let filePath = Bundle.main.path(forResource: "UnsplashCustomSearch-Info", ofType: "plist") else {
          fatalError("Couldn't find file 'UnsplashCustomSearch-Info.plist'.")
        }

        let plist = NSDictionary(contentsOfFile: filePath)
        guard let value = plist?.object(forKey: "API_KEY") as? String else {
          fatalError("Couldn't find key 'API_KEY' in 'UnsplashCustomSearch-Info.plist'.")
        }
        return value
    }

    func createURL(queryText: String, pageNumber: Int) -> URLComponents {
        let pagingParameters = [
            "client_id": apiKey,
            "query": queryText,
            "page": String(pageNumber)
        ]

        // Build up the URL
        var urlComponents = URLComponents(string: baseURLString)!
        urlComponents.queryItems = pagingParameters.map { (key, value) in
            URLQueryItem(name: key, value: value)
        }
        return urlComponents
    }

    func request<T: Decodable>(url: URL) -> AnyPublisher<T, APIServiceError> {
        return URLSession.shared.dataTaskPublisher(for: url)
            .retry(2)
            .map(\.data)
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError({ error in
                switch error {
                case is Swift.DecodingError:
                    return .decodeError
                case let urlError as URLError:
                    return .sessionFailed(error: urlError)
                default:
                    return .other(error)
                }
            })
            .eraseToAnyPublisher()
    }
}
