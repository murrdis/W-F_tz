//
//  FavoritesManager.swift
//  WF_tz
//
//  Created by Диас Мурзагалиев on 14.12.2024.
//

import Foundation

extension Notification.Name {
    static let favoritesUpdated = Notification.Name("favoritesUpdated")
}


final class FavoritesManager {
    static let shared = FavoritesManager()
    private let networkService = NetworkService.shared
    
    private(set) var favorites: [DetailedPhoto] = [] {
        didSet {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .favoritesUpdated, object: nil)
            }
        }
    }
    
    private init() {
        loadFavorites()
    }
    
    func addFavorite(photo: DetailedPhoto) {
        if !isFavorite(photo: photo) {
            favorites.append(photo)
        }
    }
    
    func addFavorite(id: String) {
        if !isFavorite(id: id) {
            networkService.getPhoto(withID: id) { [weak self] result in
                switch result {
                case .success(let detailedPhoto):
                    self?.favorites.append(detailedPhoto)
                case .failure:
                    break
                }
            }
        }
    }
    
    func removeFavorite(photo: DetailedPhoto) {
        favorites.removeAll { $0.id == photo.id }
    }
    
    func isFavorite(photo: DetailedPhoto) -> Bool {
        return favorites.contains { $0.id == photo.id }
    }
    
    func isFavorite(id: String) -> Bool {
        return favorites.contains { $0.id == id }
    }
    
    func saveFavorites() {
        let favoriteIDs = favorites.map { $0.id }
        UserDefaults.standard.set(favoriteIDs, forKey: "favoriteIDs")
    }
    
    private func loadFavorites() {
        if let savedIDs = UserDefaults.standard.array(forKey: "favoriteIDs") as? [String] {
            fetchPhotosFromIDs(savedIDs: savedIDs)
        }
    }
    
    private func fetchPhotosFromIDs(savedIDs: [String]) {
        let group = DispatchGroup()
        var loadedPhotos: [DetailedPhoto?] = Array(repeating: nil, count: savedIDs.count)
        
        for (index, id) in savedIDs.enumerated() {
            group.enter()
            NetworkService.shared.getPhoto(withID: id) { result in
                switch result {
                case .success(let photo):
                    loadedPhotos[index] = photo
                case .failure(let error):
                    print("Failed to fetch photo for ID \(id): \(error)")
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.favorites = loadedPhotos.compactMap { $0 }
        }
    }
}

