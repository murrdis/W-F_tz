//
//  FavoritesViewController.swift
//  WF_tz
//
//  Created by Диас Мурзагалиев on 13.12.2024.
//

import UIKit

final class FavoritesViewController: UITableViewController {
    private let networkService = NetworkService.shared
    private let favoritesManager = FavoritesManager.shared
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    private func setup() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadFavorites), name: .favoritesUpdated, object: nil)

        tableView.showsVerticalScrollIndicator = false
        tableView.register(FavoriteTableViewCell.self, forCellReuseIdentifier: "FavoriteCell")
        
        setupNavigationBar()
    }
    
    @objc private func reloadFavorites() {
        tableView.reloadData()
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Favorites"
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoritesManager.favorites.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell", for: indexPath) as! FavoriteTableViewCell
        let favoritePhoto = favoritesManager.favorites[indexPath.row]
        cell.configure(with: favoritePhoto)
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let photo = favoritesManager.favorites[indexPath.row]
        let cell = tableView.cellForRow(at: indexPath) as! FavoriteTableViewCell
        let image = cell.photoImageView.image
            
        let detailedPhotoViewController = DetailedPhotoViewController(photo: photo, initialImage: image)
        detailedPhotoViewController.preferredTransition = .zoom(sourceViewProvider: { context in
            guard let cell = self.tableView.cellForRow(at: indexPath) else {
                return nil
            }
            return cell.contentView
        })

        self.present(detailedPhotoViewController, animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .favoritesUpdated, object: nil)
    }

}



