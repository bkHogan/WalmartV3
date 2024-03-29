//
//  ViewController.swift
//  WalmartCodingTest
//
//  Created by Brian Hogan on 3/28/24.
//

import UIKit
import Combine

class ViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    private var viewModel: CountryListViewModel!
    private var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        
        searchBar.delegate = self
        setupViewModel()
        setupSearchController()
        fetchCountries()
    }

    private func setupViewModel() {
        viewModel = CountryListViewModel()
        viewModel.$filteredCountries
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &subscriptions)
    }

    private func fetchCountries() {
        viewModel.fetchCountries { result in
            switch result {
            case .success:
                print("Countries fetched successfully")
            case .failure(let error):
                print("Failed to fetch countries: \(error)")
                // display alert
            }
        }
    }

    private func setupSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self // Fix error here
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Countries"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
}

// MARK: - UISearchBar
extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            // Trim leading and trailing whitespaces
            let trimmedText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            // Remove special characters and non-alphanumeric characters
            let cleanedText = trimmedText.components(separatedBy: CharacterSet.alphanumerics.inverted).joined(separator: "")
            viewModel.filterCountries(with: cleanedText)
        }
}

// MARK: - UISearchResultsUpdating
extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        viewModel.filterCountries(with: searchText) // Fix error here
    }
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filteredCountries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CountryTableViewCell", for: indexPath) as? CountryTableViewCell else {
                fatalError("Unable to dequeue cell")
            }
            
            let country = viewModel.filteredCountries[indexPath.row]
            cell.nameLabel?.text = country.name
            cell.capitalLabel?.text = country.capital
            cell.codeLabel?.text = country.code

            return cell
        }
}
