//
//  APIService.swift
//  PhotoViewerApp
//
//  Created by Alexandros Lykesas on 26/11/20.
//

import UIKit

enum APIServiceError: Error {
    case apiError
    case invalidURL
    case invalidResponse
    case decodeError
}

class APIService {

    static let shared = APIService()

    private let urlSession = URLSession.shared

    let baseURLString = "https://www.googleapis.com/customsearch/v1"

    private let apikey = "AIzaSyCrZtIBCbM3VEuFpcYYuVyO3SBzKGSPoIw"
    private let searchEngine = "017901247231445677654:zwad8gw42fj"
    private let searchType = "image"

    func getSearchResults<T: Decodable>(query: String,
                                        completion: @escaping (Result<T, APIServiceError>) -> Void) {

        let pagingParameters = [
            "key": apikey,
            "cx": searchEngine,
            "searchType": searchType,
            "q": query,
            "ImgSize": "IMG_SIZE_MEDIUM"
        ]

        // Build up the URL
        var urlComponents = URLComponents(string: baseURLString)!
        urlComponents.queryItems = pagingParameters.map { (key, value) in
            URLQueryItem(name: key, value: value)
        }

        guard let url = urlComponents.url else {
            completion(.failure(.invalidURL))
            return
        }

        // Generate and execute the request
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
                print(error)
                completion(.failure(.apiError))
            }
        }.resume()
    }

}
