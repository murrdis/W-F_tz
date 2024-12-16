//
//  PhotosViewController.swift
//  WF_tz
//
//  Created by Диас Мурзагалиев on 14.12.2024.
//

import UIKit

final class PhotosViewController: UICollectionViewController {
    private let refreshControl = UIRefreshControl()
    private lazy var selectButton: UIButton = PhotosButton(title: "Select", selectedTitle: "Cancel", font: UIFont.systemFont(ofSize: 14, weight: .medium), cornerRadius: 15, size: CGSize(width: 70, height: 30), target: self, action: #selector(selectButtonTapped(_:)))
    private lazy var shareButton: UIButton = PhotosButton(imageName: "square.and.arrow.up", size: CGSize(width: 40, height: 40), target: self, action: #selector(shareButtonTapped(_:)))
    private lazy var favoriteButton: UIButton = PhotosButton(imageName: "heart", size: CGSize(width: 40, height: 40), target: self, action: #selector(favoriteButtonTapped(_:)))
    private lazy var errorView: ErrorView = ErrorView()
    
    private let photosModel = PhotosModel()
    private var timer: Timer?
    
    private var currentSearchText = ""
    private var currentPage = 1
    private var isLoading = false
    private var isSelectionModeEnabled = false
    private var isShowingError: Bool = false
    private var isBatchUpdating = false
    private var pendingSearchText: String?

    
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
        photosModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupCollectionView()
    }
    
    private func setup() {
        [
            selectButton,
            shareButton,
            favoriteButton,
            errorView
        ].forEach { view.addSubview($0) }
        setupNavigationBar()
        setupConstraints()
        setupRefreshControl()
        
        getRandomPhotos()
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Photos"
        setupSearchBar()
        definesPresentationContext = true
    }
    
    private func setupSearchBar() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search Unsplash Photos"
        navigationItem.searchController = searchController
    }
    
    private func setupCollectionView() {
        collectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: "PhotoCell")
        collectionView.addSubview(errorView)
        view.bringSubviewToFront(errorView)
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: (view.frame.width / 3) - 1, height: (view.frame.width / 3) - 1)
            layout.minimumInteritemSpacing = 1
            layout.minimumLineSpacing = 1
        }
    }
    
    private func setupRefreshControl() {
        refreshControl.tintColor = .gray
        refreshControl.addTarget(self, action: #selector(refreshPhotos(_:)), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    @objc private func refreshPhotos(_ sender: UIRefreshControl) {
        currentPage = 1
        refreshSelections()
        getRandomPhotos(shouldReplaceOldPhotos: true, completion: {
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }
        })
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            selectButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            selectButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            
        ])
        NSLayoutConstraint.activate([
            shareButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            shareButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
        ])
        NSLayoutConstraint.activate([
            favoriteButton.leadingAnchor.constraint(equalTo: shareButton.trailingAnchor, constant: 10),
            favoriteButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
        ])
        NSLayoutConstraint.activate([
            errorView.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            errorView.topAnchor.constraint(equalTo: collectionView.topAnchor, constant: 250),
            errorView.leadingAnchor.constraint(greaterThanOrEqualTo: collectionView.leadingAnchor, constant: 16),
            errorView.trailingAnchor.constraint(lessThanOrEqualTo: collectionView.trailingAnchor, constant: -16)
        ])
    }
    
    @objc func selectButtonTapped(_ sender: UIBarButtonItem) {
        sender.isSelected.toggle()
        isSelectionModeEnabled.toggle()
        collectionView.allowsMultipleSelection = isSelectionModeEnabled
        updateSelectionButtonsVisibility()
    }
    
    @objc func shareButtonTapped(_ sender: UIBarButtonItem) {
        let shareController = UIActivityViewController(activityItems: photosModel.selectedImages, applicationActivities: nil)
        
        shareController.completionWithItemsHandler = {_, bool, _, _ in
            if bool {
                self.refreshSelections()
            }
        }
        
        shareController.popoverPresentationController?.barButtonItem = sender
        shareController.popoverPresentationController?.permittedArrowDirections = .any
        present(shareController, animated: true, completion: nil)
    }
    
    func refreshSelections() {
        photosModel.clearSelectedPhotos()
        isSelectionModeEnabled = false
        selectButton.isSelected = false
        updateSelectionButtonsVisibility()
        collectionView.selectItem(at: nil, animated: true, scrollPosition: [])
    }
    
    @objc func favoriteButtonTapped(_ sender: UIBarButtonItem) {
        photosModel.addFavorites()
        self.refreshSelections()
    }
    
    private func updateCollectionView(shouldReplaceOldPhotos: Bool, oldPhotosCount: Int) {
        if shouldReplaceOldPhotos || oldPhotosCount == 0 {
            self.collectionView.reloadData()
            collectionView.setContentOffset(CGPoint(x: 0, y: -collectionView.adjustedContentInset.top), animated: true)
        } else {
            let newCount = self.photosModel.photos.count
            guard newCount > oldPhotosCount else { return }
            let newIndexPaths = (oldPhotosCount..<newCount).map { IndexPath(item: $0, section: 0) }
            collectionView.performBatchUpdates({
                self.isBatchUpdating = true
                collectionView.insertItems(at: newIndexPaths)
            }, completion: { _ in
                self.isBatchUpdating = false
                // If there's a pending search, start it now
                if let text = self.pendingSearchText {
                    self.pendingSearchText = nil
                    self.searchPhotos(searchText: text)
                }
            })

        }
    }
    
    private func getRandomPhotos(shouldReplaceOldPhotos: Bool = false, completion: (() -> Void)? = nil) {
        guard !isLoading else { return }
        isLoading = true
        
        photosModel.getRandomPhotos(shouldReplaceOldPhotos: shouldReplaceOldPhotos) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let oldPhotosCount):
                    self?.updateCollectionView(shouldReplaceOldPhotos: shouldReplaceOldPhotos, oldPhotosCount: oldPhotosCount)
                case .failure(let error):
                    self?.showError(error)
                }
                completion?()
            }
        }
    }
    
    private func searchPhotos(searchText: String) {
        guard !isLoading else { return }
        guard !searchText.isEmpty else {
            getRandomPhotos(shouldReplaceOldPhotos: true)
            return
        }
        currentSearchText = searchText
        
        isLoading = true
        photosModel.searchPhotos(page: currentPage, searchText: searchText) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let oldPhotosCount):
                    self?.updateCollectionView(shouldReplaceOldPhotos: self?.currentPage == 1, oldPhotosCount: oldPhotosCount)
                    if self?.currentPage == 1 {
                        self?.currentPage += 2
                    } else {
                        self?.currentPage += 1
                    }
                case .failure(let error):
                    self?.showError(error)
                }
            }
        }
    }
    
    func getDetailedPhoto(id: String, completion: @escaping (Result<DetailedPhoto, NetworkError>) -> Void) {
        photosModel.getPhoto(id: id) { result in
            switch result {
            case .success(let detailedPhoto):
                completion(.success(detailedPhoto))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - UIScrollViewDelegate
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let navigationBarHeight = navigationController?.navigationBar.frame.height ?? 0
        let isLargeTitleVisible = scrollView.contentOffset.y < ((navigationBarHeight - scrollView.safeAreaInsets.top) - 50)
        
        selectButton.isHidden = isLargeTitleVisible && !isSelectionModeEnabled
        updateSelectionButtonsVisibility()
        
        // Fetch more photos as user scrolls
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height
        
        if offsetY > contentHeight - frameHeight - 200 && !isLoading {
            if !currentSearchText.isEmpty {
                searchPhotos(searchText: currentSearchText)
            } else {
                if !isShowingError {
                    getRandomPhotos()
                }
            }
        }
    }
}

// MARK: - UICollectionViewDelegate Methods

extension PhotosViewController: PhotoCollectionViewCellDelegate {
    func shouldUpdateUIForSelection(in cell: PhotoCollectionViewCell) -> Bool {
        return isSelectionModeEnabled
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isShowingError {
            return 0
        }
        return photosModel.photos.count
    }

    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCollectionViewCell
        cell.delegate = self
        cell.configure(photo: photosModel.photos[indexPath.row])
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !isSelectionModeEnabled {
            let selectedPhoto = photosModel.photos[indexPath.row]
            let placeholderDetailPhoto = DetailedPhoto(
                id: selectedPhoto.id,
                created_at: selectedPhoto.created_at,
                width: selectedPhoto.width,
                height: selectedPhoto.height,
                downloads: nil,
                location: nil,
                urls: selectedPhoto.urls,
                user: selectedPhoto.user
            )
            let cell = collectionView.cellForItem(at: indexPath) as! PhotoCollectionViewCell
            let image = cell.photoImageView.image
            let detailedPhotoViewController = DetailedPhotoViewController(photo: placeholderDetailPhoto, initialImage: image)
            detailedPhotoViewController.preferredTransition = .zoom(sourceViewProvider: { context in
                guard let cell = self.collectionView.cellForItem(at: indexPath) else {
                    return nil
                }
                return cell.contentView
            })
            
            self.present(detailedPhotoViewController, animated: true)
        } else {
            let cell = collectionView.cellForItem(at: indexPath) as! PhotoCollectionViewCell
            guard let image = cell.photoImageView.image, let photoID = cell.photo?.id else { return }
            photosModel.addSelectedPhoto(photoID: photoID, image: image)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoCollectionViewCell
        guard let image = cell.photoImageView.image, let photoID = cell.photo?.id else { return }
        photosModel.removeSelectedPhoto(photoID: photoID, image: image)
    }
}

// MARK:  UISearchBarDelegate

extension PhotosViewController: UISearchBarDelegate {
    private func search(_ searchText: String) {
        guard !searchText.isEmpty else {
            self.currentPage = 1
            self.photosModel.showRandomPhotos()
            self.collectionView.reloadData()
            collectionView.setContentOffset(CGPoint(x: 0, y: -collectionView.adjustedContentInset.top), animated: true)
            return
        }
        
        self.currentPage = 1
        if isBatchUpdating {
            // Batch update not finished: delay the search
            pendingSearchText = searchText
        } else {
            searchPhotos(searchText: searchText)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { [weak self] _ in
            guard let self = self else { return }
            
            search(searchText)
        })
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let searchText = searchBar.text else { return }
        search(searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        
        currentPage = 1
        photosModel.showRandomPhotos()
        collectionView.reloadData()
        collectionView.setContentOffset(CGPoint(x: 0, y: -collectionView.adjustedContentInset.top), animated: true)
    }
}

// MARK:  PhotosModelDelegate

extension PhotosViewController: PhotosModelDelegate {
    func updateSelectionButtonsVisibility() {
        let shouldShowButtons = isSelectionModeEnabled && photosModel.selectedIDs.count > 0
        shareButton.isHidden = !shouldShowButtons
        favoriteButton.isHidden = !shouldShowButtons
        
        if !shouldShowButtons {
            for indexPath in collectionView.indexPathsForSelectedItems ?? [] {
                collectionView.deselectItem(at: indexPath, animated: false)
            }
        }
    }
    
    func hideError() {
        isShowingError = false
        errorView.hideError()
    }

    
    func showError(_ error: NetworkError) {
        isShowingError = true
        errorView.showError(error)
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}
