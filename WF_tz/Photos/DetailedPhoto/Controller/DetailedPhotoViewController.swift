//
//  DetailedPhotoViewController.swift
//  WF_tz
//
//  Created by Диас Мурзагалиев on 14.12.2024.
//

import UIKit

final class DetailedPhotoViewController: UIViewController {
    private var contentView: DetailedPhotoContentView
    private let networkService = NetworkService.shared
    private let favoritesManager = FavoritesManager.shared
    
    var photo: DetailedPhoto
    
    init(photo: DetailedPhoto, initialImage: UIImage?) {
        self.photo = photo
        self.contentView = DetailedPhotoContentView(photo: photo, initialImage: initialImage, isFavorite: favoritesManager.isFavorite(photo: photo))
        super.init(nibName: nil, bundle: nil)
        getDetailPhoto()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func getDetailPhoto() {
        networkService.getPhoto(withID: photo.id) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let detailedPhoto):
                    self?.photo = detailedPhoto
                    self?.contentView.updateUI(photo: detailedPhoto)
                case .failure(let error):
                    self?.contentView.showError(error)
                }
            }
        }
    }
    
    private func setup() {
        contentView.delegate = self
        view.addSubview(contentView)
        view.backgroundColor = UIColor.systemBackground
        setupConstraints()
    }
    
    private func setupConstraints() {
        contentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: view.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
}

extension DetailedPhotoViewController: DetailedPhotoContentViewDelegate {
    func didTapFavoriteButton() {
        if contentView.isFavoriteButtonSelected {
            let alert = UIAlertController(title: "Remove from Favorites", message: "Are you sure you want to remove this image from your favorites?", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

            alert.addAction(UIAlertAction(title: "Remove", style: .destructive, handler: { _ in
                self.favoritesManager.removeFavorite(photo: self.photo)
                self.contentView.deselectFavoriteButton()
                self.didTapBackButton()
            }))

            present(alert, animated: true, completion: nil)
        } else {
            self.favoritesManager.addFavorite(photo: photo)
            contentView.selectFavoriteButton()
        }
    }
    
    
    func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    func didTapShareButton(sender: UIButton, image: UIImage?) {
        guard let image = image else { return }
        let shareController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        
        shareController.completionWithItemsHandler = {  _, bool, _, _ in
            if bool {
            }
        }

        if let popoverController = shareController.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
            popoverController.permittedArrowDirections = .any
        }
        
        present(shareController, animated: true, completion: nil)
    }
}
