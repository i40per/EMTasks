//
//  NetworkService.swift
//  EMTasks
//
//  Created by Евгений Лукин on 22.03.2026.
//

import Foundation

// MARK: - NetworkServiceProtocol
protocol NetworkServiceProtocol: AnyObject {
    func fetchTasks(completion: @escaping ([APITask]) -> Void)
}

// MARK: - NetworkService
final class NetworkService: NetworkServiceProtocol {

    // MARK: - Properties
    private let urlString = "https://dummyjson.com/todos"

    // MARK: - Public Methods
    func fetchTasks(completion: @escaping ([APITask]) -> Void) {
        guard let url = URL(string: urlString) else {
            completion([])
            return
        }

        let request = URLRequest(url: url)

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completion([])
                return
            }

            guard let data else {
                completion([])
                return
            }

            do {
                let result = try JSONDecoder().decode(APIResponse.self, from: data)
                completion(result.todos)
            } catch {
                print("Decoding error:", error.localizedDescription)
                completion([])
            }
        }.resume()
    }
}
