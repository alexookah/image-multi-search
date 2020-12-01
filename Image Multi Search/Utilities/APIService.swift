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

    let baseURLString = "https://www.googleapis.com/customsearch/v1"

    private var apikey: String {
        guard let filePath = Bundle.main.path(forResource: "GoogleCustomSearch-Info", ofType: "plist") else {
          fatalError("Couldn't find file 'GoogleCustomSearch-Info.plist'.")
        }

        let plist = NSDictionary(contentsOfFile: filePath)
        guard let value = plist?.object(forKey: "API_KEY") as? String else {
          fatalError("Couldn't find key 'API_KEY' in 'CustomGoogleSearch-Info.plist'.")
        }
        return value
    }

    private let searchEngine = "017901247231445677654:zwad8gw42fj"
    private let searchType = "image"

    func createURL(queryText: String) -> URLComponents {
        let pagingParameters = [
            "key": apikey,
            "cx": searchEngine,
            "searchType": searchType,
            "q": queryText,
            "ImgSize": "IMG_SIZE_MEDIUM"
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

    // not anymore used
    func getSearchResults<T: Decodable>(queryText: String,
                                        completion: @escaping (Result<T, APIServiceError>) -> Void) {
        guard let url = createURL(queryText: queryText).url else { return completion(.failure(.invalidURL)) }

        urlSession.dataTask(with: url) { (result) in
            switch result {
            case .success(let (response, data)):
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode, 200..<299 ~= statusCode else {
                    completion(.failure(.invalidResponse))
                    return
                }
                do {
                    let values = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(values))
                } catch {
                    completion(.failure(.decodeError))
                }
            case .failure(let error):
                completion(.failure(.other(error)))
            }
        }.resume()
    }

}
