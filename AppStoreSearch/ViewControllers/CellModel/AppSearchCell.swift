//
//  AppSearchCell.swift
//  AppStoreSearch
//
//  Created by Igor P-V on 14.03.2023.
//

import UIKit
import Foundation

final class AppSearchCell: UITableViewCell {
    
    private lazy var iconApp = UIImageView()
    private lazy var activityIndicator = UIActivityIndicatorView()
    private lazy var developerLabel = UILabel()
    private lazy var appNameLabel = UILabel()
    private lazy var ratingLabel = UILabel()
    
    private var loadImageTask: Task<Void, Never>?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureApperance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureApperance()
    }
}

extension AppSearchCell {
    
    func configure(with appEntity: AppEntity) {
        appNameLabel.text = appEntity.position.formatted() + ". " + appEntity.name
        developerLabel.text = appEntity.developer
        ratingLabel.text = appEntity.rating.formatted(.number.precision(.significantDigits(3))) + " rating"
        
        configureIcon(for: appEntity.iconUrl)
    }
}

private extension AppSearchCell {
    
    func configureApperance() {
        configureView()
        configureSubviews()
        configureConstraints()
    }
    
    func configureView() {
        [
            iconApp,
            activityIndicator,
            developerLabel,
            appNameLabel,
            ratingLabel
        ].forEach(contentView.addSubview(_:))
    }
    
    func configureSubviews() {
        iconApp.layer.masksToBounds = true
        iconApp.layer.cornerRadius = 12
        iconApp.layer.borderColor = UIColor.secondaryLabel.cgColor
        iconApp.layer.borderWidth = 0.5
        
        appNameLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        
        developerLabel.font = .systemFont(ofSize: 15, weight: .regular)
        developerLabel.textColor = .secondaryLabel
        
        ratingLabel.font = .systemFont(ofSize: 15, weight: .regular)
        ratingLabel.textColor = .secondaryLabel
    }
    
    func configureConstraints() {
        iconApp.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        appNameLabel.translatesAutoresizingMaskIntoConstraints = false
        developerLabel.translatesAutoresizingMaskIntoConstraints = false
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            iconApp.widthAnchor.constraint(equalToConstant: 60),
            iconApp.heightAnchor.constraint(equalToConstant: 60),

            activityIndicator.centerXAnchor.constraint(equalTo: iconApp.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: iconApp.centerYAnchor),

            iconApp.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            iconApp.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),

            appNameLabel.topAnchor.constraint(equalTo: iconApp.topAnchor),
            appNameLabel.leadingAnchor.constraint(equalTo: iconApp.trailingAnchor, constant: 16),
            appNameLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),

            developerLabel.topAnchor.constraint(equalTo: appNameLabel.bottomAnchor, constant: 2),
            developerLabel.leadingAnchor.constraint(equalTo: iconApp.trailingAnchor, constant: 16),
            developerLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),

            ratingLabel.topAnchor.constraint(equalTo: developerLabel.bottomAnchor, constant: 2),
            ratingLabel.leadingAnchor.constraint(equalTo: iconApp.trailingAnchor, constant: 16),
            ratingLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            ratingLabel.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
        ])
    }
    
    func configureIcon(for url: URL) {
        loadImageTask?.cancel()
        
        loadImageTask = Task { [weak self] in
            self?.iconApp.image = nil
            self?.activityIndicator.startAnimating()
            
            do {
                try await self?.iconApp.setImage(by: url)
                if Task.isCancelled { return }
                self?.iconApp.contentMode = .scaleAspectFit
            } catch {
                if Task.isCancelled { return }
                self?.iconApp.image = UIImage(systemName: "exclamationmark.icloud")
                self?.iconApp.contentMode = .center
            }
            
            self?.activityIndicator.stopAnimating()
        }
    }
}
