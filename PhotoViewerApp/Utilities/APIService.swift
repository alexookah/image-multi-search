//
//  APIService.swift
//  PhotoViewerApp
//
//  Created by Alexandros Lykesas on 26/11/20.
//

import UIKit

class APIService {

    static let shared = APIService()

    private let urlSession = URLSession.shared

    let baseURLString = "https://www.googleapis.com/customsearch/v1"

    private let apikey = "AIzaSyCrZtIBCbM3VEuFpcYYuVyO3SBzKGSPoIw"
    private let searchEngine = "017901247231445677654:zwad8gw42fj"
    private let searchType = "image"

    enum APIServiceError: Error {
        case apiError
        case invalidURL
        case invalidResponse
        case decodeError
    }

    func getSearchResults<T: Decodable>(query: String,
                                        completion: @escaping (Result<T, APIServiceError>) -> Void) {

        let pagingParameters = [
            "key": apikey,
            "cx": searchEngine,
            "searchType": searchType,
            "q": query
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

    func downloadImage(from url: URL, completion: @escaping (Result<UIImage, APIServiceError>) -> Void) {

        // Generate and execute the request
        urlSession.dataTask(with: url) { (result) in
            switch result {
            case .success(let (response, data)):
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode, 200..<299 ~= statusCode else {
                    completion(.failure(.invalidResponse))
                    return
                }
                if let imageData = UIImage(data: data) {
                    completion(.success(imageData))
                } else {
                    completion(.failure(.decodeError))
                }

            case .failure(let error):
                print(error)
                completion(.failure(.apiError))
            }
        }.resume()
    }

}
