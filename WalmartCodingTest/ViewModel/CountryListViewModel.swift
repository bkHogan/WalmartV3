//
//  CountryListViewModel.swift
//  WalmartCodingTest
//
//  Created by Mac on 3/29/24.
//

import Foundation
import Combine

class CountryListViewModel {
    @Published private(set) var filteredCountries: [Country] = []
    private var countries: [Country] = []
    private var subscriptions = Set<AnyCancellable>()

    init() {
        // Initialize your view model here
    }

    func fetchCountries(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "https://gist.githubusercontent.com/peymano-wmt/32dcb892b06648910ddd40406e37fdab/raw/db25946fd77c5873b0303b858e861ce724e0dcd0/countries.json") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: [Country].self, decoder: JSONDecoder())
            .sink { completionResult in
                switch completionResult {
                case .failure(let error):
                    completion(.failure(error))
                case .finished:
                    completion(.success(()))
                }
            } receiveValue: { [weak self] countries in
                self?.countries = countries
                self?.filteredCountries = countries
            }
            .store(in: &subscriptions)
    }

    func filterCountries(with searchText: String) {
        if searchText.isEmpty {
            // If search text is empty, show all countries
            filteredCountries = countries
        } else {
            // Filter countries based on name or other properties
            filteredCountries = countries.filter { country in
                return country.name.lowercased().contains(searchText.lowercased()) ||
                       country.capital.lowercased().contains(searchText.lowercased()) ||
                       country.code.lowercased().contains(searchText.lowercased())
            }
        }
    }
}

enum NetworkError: Error {
    case invalidURL
    // Add more error cases as needed
}

