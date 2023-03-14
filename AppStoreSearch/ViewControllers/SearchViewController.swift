//
//  SearchViewController.swift
//  AppStoreSearch
//
//  Created by Igor P-V on 14.03.2023.
//

import UIKit

final class SearchViewController: UIViewController {
    
    typealias SnapShot = NSDiffableDataSourceSnapshot<Section, Cell>
    typealias DataSource = UITableViewDiffableDataSource<Section, Cell>
    
    private lazy var tableView = UITableView(frame: .zero, style: .insetGrouped)
    private lazy var searchController = UISearchController(searchResultsController: nil)
    private lazy var activityIndicator = UIActivityIndicatorView()
    private lazy var statusLabel = UILabel()
    
    private lazy var dataSource = createDataSource()
    private lazy var searchService = SearchService()
    
    private var searchingTask: Task<Void, Never>?
    
    private var state: State = .initial {
        didSet {
            updateState()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureApperance()
    }
}

extension SearchViewController {
    
    enum Section: Hashable {
        case main
    }
    
    enum Cell: Hashable {
        case app(AppEntity)
    }
    
    enum State {
        case initial
        case loading
        case empty
        case data([AppEntity])
        case error(Error)
    }
}

extension SearchViewController: UISearchControllerDelegate, UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text else { return }
        
        searchingTask?.cancel()
        
        searchingTask = Task { [weak self] in
            self?.state = .loading
            
            do {
                let apps = try await searchService.search(with: query)
                
                if Task.isCancelled {
                    return
                }
                
                if apps.isEmpty {
                    self?.state = .empty
                } else {
                    self?.state = .data(apps)
                }
            } catch {
                self?.state = .error(error)
            }
        }
    }
}

private extension SearchViewController {
    
    func configureApperance() {
        configureNavigation()
        configureView()
        configureSubviews()
        configureConstraints()
    }
    
    func configureNavigation() {
        navigationItem.title = "Search"
        navigationItem.searchController = searchController
    }
    
    func configureView() {
        view.backgroundColor = .systemGroupedBackground
        
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        view.addSubview(statusLabel)
    }
    
    func configureSubviews() {
        tableView.dataSource = dataSource
        tableView.register(AppSearchCell.self, forCellReuseIdentifier: "app")
        tableView.allowsSelection = false
        tableView.contentInset.top = 64
        
        statusLabel.textColor = .secondaryLabel
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0
        
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search apps"
        searchController.searchBar.autocapitalizationType = .none
        
        updateState()
    }
    
    func configureConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            activityIndicator.bottomAnchor.constraint(equalTo: statusLabel.topAnchor, constant: -16),
            activityIndicator.centerXAnchor.constraint(equalTo: statusLabel.centerXAnchor),

            statusLabel.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: -56),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
    
    func updateState() {
        switch state {
        case .initial:
            tableView.isHidden = false
            activityIndicator.stopAnimating()
            statusLabel.text = "Input your request"
        case .loading:
            tableView.isHidden = true
            activityIndicator.startAnimating()
            statusLabel.text = "Loading..."
        case .empty:
            tableView.isHidden = true
            activityIndicator.stopAnimating()
            statusLabel.text = "No apps found"
        case let .data(apps):
            tableView.isHidden = false
            activityIndicator.stopAnimating()
            statusLabel.text = nil
            
            var snapshot = SnapShot()
            snapshot.appendSections([.main])
            snapshot.appendItems(apps.map { .app($0) }, toSection: .main)
            dataSource.apply(snapshot)
        case let .error(error):
            tableView.isHidden = true
            activityIndicator.stopAnimating()
            statusLabel.text = "Error: \(error.localizedDescription)"
        }
    }
    
    func createDataSource() -> DataSource {
        DataSource(tableView: tableView, cellProvider: { (tableView, indexPath, item) -> UITableViewCell? in
            switch item {
            case let .app(appEntity):
                let cell = tableView.dequeueReusableCell(withIdentifier: "app", for: indexPath) as? AppSearchCell
                cell?.configure(with: appEntity)
                return cell
            }
        })
    }
}
