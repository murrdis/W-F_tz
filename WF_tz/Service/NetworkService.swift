//
//  NetworkService.swift
//  WF_tz
//
//  Created by Диас Мурзагалиев on 14.12.2024.
//

import Alamofire

enum NetworkError: Error, Equatable {
    case decodingError
    case timeout
    case noInternet
    case notFound
    case unknown(String)
}

final class NetworkService {
    static let shared = NetworkService()
    
    private let baseURL = "https://api.unsplash.com"
    private let clientID = "FJiN20I1MLldtQ5GXjBFTQ1EHJIzegaA_-pWDzc2aJc"
    
    private init() { }
    
    private func request<T: Decodable>(
        _ url: String,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        headers: HTTPHeaders? = nil,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        
        var finalHeaders = headers ?? HTTPHeaders()
        if finalHeaders["Authorization"] == nil {
            finalHeaders["Authorization"] = "Client-ID \(clientID)"
        }
        
        AF.request(url, method: method, parameters: parameters, headers: finalHeaders).responseData { response in
            switch response.result {
            case .failure(let error):
                if let underlyingError = error.underlyingError as? URLError {
                    switch underlyingError.code {
                    case .notConnectedToInternet:
                        completion(.failure(.noInternet))
                    case .timedOut:
                        completion(.failure(.timeout))
                    default:
                        completion(.failure(.unknown(underlyingError.localizedDescription)))
                    }
                } else {
                    completion(.failure(.unknown(error.localizedDescription)))
                }
            case .success(let data):
                guard let decodedResponse = try? JSONDecoder().decode(T.self, from: data) else {
                    completion(.failure(.decodingError))
                    return
                }
                completion(.success(decodedResponse))
            }
        }
    }
    
    func getRandomPhotos(completion: @escaping (Result<[Photo], NetworkError>) -> Void) {
        let url = "\(baseURL)/photos/random"
        let parameters: Parameters = ["count": 30]
        
        request(url, parameters: parameters, completion: completion)
    }

    
    func searchPhotos(page: Int, searchText: String, completion: @escaping (Result<SearchResults, NetworkError>) -> Void) {
        let url = "\(baseURL)/search/photos"
        let parameters: Parameters = [
            "query": searchText,
            "page": page,
            "per_page": "10"
        ]
        
        request(url, parameters: parameters, completion: completion)
    }
    
    func getPhoto(withID id: String, completion: @escaping (Result<DetailedPhoto, NetworkError>) -> Void) {
        let url = "\(baseURL)/photos/\(id)"
        
        request(url, completion: completion)
    }
}
