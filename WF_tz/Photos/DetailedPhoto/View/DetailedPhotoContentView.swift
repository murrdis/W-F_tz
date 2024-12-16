//
//  DetailedPhotoContentView.swift
//  WF_tz
//
//  Created by Диас Мурзагалиев on 14.12.2024.
//

import UIKit

protocol DetailedPhotoContentViewDelegate: AnyObject {
    func didTapBackButton()
    func didTapFavoriteButton()
    func didTapShareButton(sender: UIButton, image: UIImage?)
}

final class DetailedPhotoContentView: UIView {
    weak var delegate: DetailedPhotoContentViewDelegate?
    private var photo: DetailedPhoto
    private let initialImage: UIImage?
    private let isFavorite: Bool
    private let customDateFormatter = CustomDateFormatter()
    
    private lazy var navigationButtonsStackView = makeNavigationButtonsStackView()
    private lazy var shareButton = makeShareButton()
    private lazy var backButton = makeBackButton()
    private lazy var authorLabel = makeAuthorLabel()
    private lazy var photoImageView = makePhotoImageView()
    private lazy var dateLabel = makeDateLabel()
    private lazy var locationDateStackView = makeLocationDateStackView()
    private lazy var locationLabel = makeLocationLabel()
    private lazy var locationIconImageView = makeLocationIconImageView()
    private lazy var favoriteDownloadsStackView = makeFavoriteDownloadsStackView()
    private lazy var downloadsStackView = makeDownloadsStackView()
    private lazy var downloadsLabel = makeDownloadsLabel()
    private lazy var downloadsIconImageView = makeDownloadsIconImageView()
    private lazy var favoriteButton = makeFavoriteButton()
    private lazy var errorView: ErrorView = ErrorView()
    
    var isFavoriteButtonSelected: Bool {
        return favoriteButton.isSelected
    }
    
    init(photo: DetailedPhoto, initialImage: UIImage?, isFavorite: Bool) {
        self.photo = photo
        self.initialImage = initialImage
        self.isFavorite = isFavorite
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        [
            navigationButtonsStackView,
            authorLabel,
            locationDateStackView,
            photoImageView,
            favoriteDownloadsStackView,
            errorView
        ].forEach { addSubview($0) }
        configure()
        setupConstraints()
    }
    
    private func configure() {
        let photoURL = photo.urls[URLType.regular.rawValue]
        guard let imageURL = photoURL, let url = URL(string: imageURL) else { return }
        photoImageView.sd_setImage(with: url)
        
        authorLabel.text = photo.user.name
        if let date = customDateFormatter.convertDateString(photo.created_at) {
            dateLabel.text = date
        }
        
        if isFavorite {
            favoriteButton.tintColor = .red
            favoriteButton.isSelected = true
        }
    }
    
    func updateUI(photo: DetailedPhoto) {
        self.photo = photo
        var locationText = "unknown"
        
        if let city = photo.location?.city, let country = photo.location?.country {
            locationText = "\(city), \(country)"
        } else if let city = photo.location?.city {
            locationText = city
        } else if let country = photo.location?.country {
            locationText = country
        }
        
        locationLabel.text = locationText
        
        if let downloads = photo.downloads {
            downloadsLabel.text = "\(downloads)"
        } else {
            downloadsLabel.text = "0"
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            navigationButtonsStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 0),
            navigationButtonsStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            navigationButtonsStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            navigationButtonsStackView.heightAnchor.constraint(equalToConstant: 44),
            
            authorLabel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 40),
            authorLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            
            locationDateStackView.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 10),
            locationDateStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            locationDateStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            photoImageView.topAnchor.constraint(equalTo: locationDateStackView.bottomAnchor, constant: 20),
            photoImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            photoImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            photoImageView.heightAnchor.constraint(equalTo: widthAnchor),
            
            favoriteDownloadsStackView.topAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: 10),
            favoriteDownloadsStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            favoriteDownloadsStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            favoriteDownloadsStackView.bottomAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            errorView.topAnchor.constraint(equalTo: topAnchor),
            errorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            errorView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    

    private func makeNavigationButtonsStackView() -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [backButton, shareButton])
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    private func makeShareButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        button.tintColor = .label
        button.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    @objc func shareButtonTapped(_ sender: UIButton) {
        delegate?.didTapShareButton(sender: sender, image: photoImageView.image)
        
    }
    
    private func makeBackButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }
    
    @objc func backButtonTapped() {
        delegate?.didTapBackButton()
    }
    
    private func makePhotoImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.image = initialImage
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }
    
    private func makeAuthorLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func makeDateLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func makeLocationDateStackView() -> UIStackView {
        let spacerView = UIView()
        spacerView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spacerView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        let stackView = UIStackView(
            arrangedSubviews:
                [
                    locationIconImageView,
                    locationLabel,
                    spacerView,
                    dateLabel
                ]
        )
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    private func makeLocationLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func makeLocationIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "mappin.and.ellipse")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .label
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }
    
    private func makeDownloadsStackView() -> UIStackView {
        let stackView = UIStackView(
            arrangedSubviews:
                [
                    downloadsLabel,
                    downloadsIconImageView
                ]
        )
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    
    private func makeDownloadsLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func makeFavoriteDownloadsStackView() -> UIStackView {
        let spacerView = UIView()
        spacerView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spacerView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        favoriteButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        downloadsStackView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        let stackView = UIStackView(
            arrangedSubviews: [
                favoriteButton,
                spacerView,
                downloadsStackView
            ]
        )
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    
    private func makeDownloadsIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "square.and.arrow.down")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .label
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }
    
    private func makeFavoriteButton() -> UIButton {
        let button = CustomFavoriteButton()
        button.translatesAutoresizingMaskIntoConstraints = false

        if let image = UIImage(systemName: "heart")?.withRenderingMode(.alwaysTemplate) {
            button.setImage(image, for: .normal)
            button.tintColor = .label
        }
        
        button.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        
        button.imageView?.translatesAutoresizingMaskIntoConstraints = false
        button.imageView?.contentMode = .scaleAspectFit
        
        if let imageView = button.imageView {
            NSLayoutConstraint.activate([
                imageView.heightAnchor.constraint(equalToConstant: 40),
                imageView.widthAnchor.constraint(equalToConstant: 40),
                imageView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
                imageView.centerXAnchor.constraint(equalTo: button.centerXAnchor)
            ])
        }
        
        button.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        return button
    }
    
    @objc func favoriteButtonTapped() {
        delegate?.didTapFavoriteButton()
    }
    
    func selectFavoriteButton() {
        favoriteButton.tintColor = .red
        favoriteButton.isSelected = true
    }
    
    func deselectFavoriteButton() {
        favoriteButton.tintColor = .black
        favoriteButton.isSelected = false
    }
    
    func hideError() {
        subviews.forEach { $0.isHidden = false }
        errorView.hideError()
    }
    
    func showError(_ error: NetworkError) {
        subviews.forEach { $0.isHidden = true }
        errorView.showError(error)
    }
}

final class CustomFavoriteButton: UIButton {
    override var isHighlighted: Bool {
        get { return false }
        set { }
    }
}
