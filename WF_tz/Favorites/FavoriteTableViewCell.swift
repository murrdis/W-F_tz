//
//  FavoriteTableViewCell.swift
//  WF_tz
//
//  Created by Диас Мурзагалиев on 14.12.2024.
//

import UIKit
import SDWebImage

final class FavoriteTableViewCell: UITableViewCell {
    lazy var photoImageView = makePhotoImageView()
    private lazy var authorLabel = makeAuthorLabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }


    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configure(with favoritePhoto: DetailedPhoto) {
        setup()
        let photoURL = favoritePhoto.urls[URLType.regular.rawValue]
        guard let imageURL = photoURL, let url = URL(string: imageURL) else {
            return
        }
        photoImageView.sd_setImage(with: url)
        authorLabel.text = favoritePhoto.user.name
    }

    private func setup() {
        [
            photoImageView,
            authorLabel
        ].forEach { addSubview($0) }

        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            photoImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            photoImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            photoImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            photoImageView.heightAnchor.constraint(equalTo: photoImageView.widthAnchor)
        ])
        NSLayoutConstraint.activate([
            authorLabel.topAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: 10),
            authorLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            authorLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            authorLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -10)
        ])
    }

    
    private func makePhotoImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }
    
    private func makeAuthorLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
}

