//
//  PhotoCollectionViewCell.swift
//  WF_tz
//
//  Created by Диас Мурзагалиев on 12.12.2024.
//

import UIKit
import SDWebImage

protocol PhotoCollectionViewCellDelegate: AnyObject {
    func shouldUpdateUIForSelection(in cell: PhotoCollectionViewCell) -> Bool
}

final class PhotoCollectionViewCell: UICollectionViewCell {
    lazy var photoImageView = makePhotoImageView()
    private lazy var checkMark = makeCheckMark()
    
    weak var delegate: PhotoCollectionViewCellDelegate?
    var photo: Photo? {
        didSet {
            let photoURL = photo?.urls[URLType.small.rawValue]
            guard let imageURL = photoURL, let url = URL(string: imageURL) else { return }
            photoImageView.sd_setImage(with: url)
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if delegate?.shouldUpdateUIForSelection(in: self) ?? false {
                updateSelectedState()
            }
            if !isSelected {
                photoImageView.alpha =  1
                checkMark.alpha = 0
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    private func updateSelectedState() {
        photoImageView.alpha = isSelected ? 0.7 : 1
        checkMark.alpha = isSelected ? 1 : 0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(photo: Photo) {
        self.photo = photo

        setup()
    }
    
    private func setup() {
        [
            photoImageView,
            checkMark
        ].forEach { addSubview($0) }
        
        updateSelectedState()
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            photoImageView.topAnchor.constraint(equalTo: topAnchor),
            photoImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            photoImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            photoImageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        NSLayoutConstraint.activate([
            checkMark.trailingAnchor.constraint(equalTo: photoImageView.trailingAnchor, constant: -8),
            checkMark.bottomAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: -8)
        ])
    }
    
    private func makePhotoImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.backgroundColor = .lightGray
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }
    
    private func makeCheckMark() -> UIImageView {
        let boldConfiguration = UIImage.SymbolConfiguration(weight: .bold)
        let image = UIImage(systemName: "checkmark.circle.fill", withConfiguration: boldConfiguration)
        let imageView = UIImageView(image: image)
        imageView.backgroundColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.alpha = 0
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.clipsToBounds = true
        return imageView
    }

}
