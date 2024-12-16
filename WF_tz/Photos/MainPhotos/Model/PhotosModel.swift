//
//  PhotosModel.swift
//  WF_tz
//
//  Created by Диас Мурзагалиев on 13.12.2024.
//

import UIKit

protocol PhotosModelDelegate: AnyObject {
    func updateSelectionButtonsVisibility()
    func hideError()
}

final class PhotosModel {
    private let networkService = NetworkService.shared
    private let favoritesManager = FavoritesManager.shared
    weak var delegate: PhotosModelDelegate?
    
    private(set) var photos: [Photo] = [] {
        didSet {
            if !photos.isEmpty {
                delegate?.hideError()
            }
        }
    }
    private(set) var randomPhotos: [Photo] = []
    private(set) var fetchedPhotoIDs: Set<String> = []
    
    private(set) var selectedIDs: Set<String> = [] {
        didSet {
            delegate?.updateSelectionButtonsVisibility()
        }
    }
    private(set) var selectedImages: [UIImage] = []
    
    func addSelectedPhoto(photoID: String, image: UIImage) {
        selectedIDs.insert(photoID)
        selectedImages.append(image)
    }
    
    func removeSelectedPhoto(photoID: String, image: UIImage) {
        selectedIDs.remove(photoID)
        if let index = selectedImages.firstIndex(of: image) {
            selectedImages.remove(at: index)
        }
    }
    
    func clearSelectedPhotos() {
        selectedIDs.removeAll()
        selectedImages.removeAll()
    }
    
    func addFavorites() {
        for id in selectedIDs {
            favoritesManager.addFavorite(id: id)
        }
    }
    
    func clearAllPhotos() {
        photos.removeAll()
        fetchedPhotoIDs.removeAll()
        clearSelectedPhotos()
    }
    
    func showRandomPhotos() {
        photos = randomPhotos
        fetchedPhotoIDs.formUnion(randomPhotos.map { $0.id })
    }
    
    func getRandomPhotos(shouldReplaceOldPhotos: Bool = false, completion: @escaping (Result<Int, NetworkError>) -> Void) {
        networkService.getRandomPhotos { [weak self] result in
            switch result {
            case .success(let newPhotos):
                let oldPhotosCount = self?.photos.count ?? 0
                self?.updateNewPhotos(shouldReplaceOldPhotos: shouldReplaceOldPhotos, newPhotos: newPhotos)
                self?.randomPhotos = self?.photos ?? []
                completion(.success(oldPhotosCount))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func searchPhotos(page: Int, searchText: String, completion: @escaping (Result<Int, NetworkError>) -> Void) {
        if page == 1 {
            networkService.searchPhotos(page: 1, searchText: searchText) { [weak self] firstResult in
                switch firstResult {
                case .success(let firstPageResults):
                    guard !firstPageResults.results.isEmpty else {
                        completion(.failure(.notFound))
                        return
                    }

                    self?.networkService.searchPhotos(page: 2, searchText: searchText) { [weak self] secondResult in
                        switch secondResult {
                        case .success(let secondPageResults):
                            let combinedResults = firstPageResults.results + secondPageResults.results
                            let oldPhotosCount = self?.photos.count ?? 0
                            self?.updateNewPhotos(shouldReplaceOldPhotos: true, newPhotos: combinedResults)
                            completion(.success(oldPhotosCount))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                    
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            networkService.searchPhotos(page: page, searchText: searchText) { [weak self] result in
                switch result {
                case .success(let searchResults):
                    guard !searchResults.results.isEmpty else { return }
                    
                    let oldPhotosCount = self?.photos.count ?? 0
                    self?.updateNewPhotos(shouldReplaceOldPhotos: false, newPhotos: searchResults.results)
                    completion(.success(oldPhotosCount))
                    
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }

    
    func getPhoto(id: String, completion: @escaping (Result<DetailedPhoto, NetworkError>) -> Void) {
        networkService.getPhoto(withID: id) { result in
            switch result {
            case .success(let photo):
                completion(.success(photo))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func updateNewPhotos(shouldReplaceOldPhotos: Bool = false, newPhotos: [Photo]) {
        let uniquePhotos = newPhotos.filter { !fetchedPhotoIDs.contains($0.id) }

        if !shouldReplaceOldPhotos && photos.count != 0 {
            photos.append(contentsOf: uniquePhotos)
        } else {
            clearAllPhotos()
            photos = newPhotos
        }

        fetchedPhotoIDs.formUnion(uniquePhotos.map { $0.id })
    }
}
