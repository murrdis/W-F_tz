//
//  PhotosButton.swift
//  WF_tz
//
//  Created by Диас Мурзагалиев on 13.12.2024.
//

import UIKit

final class PhotosButton: UIButton {
    
    init(
        imageName: String? = nil,
        title: String? = nil,
        selectedTitle: String? = nil,
        font: UIFont? = nil,
        backgroundColor: UIColor = UIColor.darkGray,
        cornerRadius: CGFloat = 20,
        size: CGSize? = nil,
        target: Any?,
        action: Selector
    ) {
        super.init(frame: .zero)
        
        if let imageName = imageName {
            self.setImage(UIImage(systemName: imageName), for: .normal)
            self.tintColor = .white
        }
        
        if let title = title {
            self.setTitle(title, for: .normal)
            self.setTitleColor(.white, for: .normal)
            if let selectedTitle = selectedTitle {
                self.setTitle(selectedTitle, for: .selected)
                self.setTitleColor(.white, for: .selected)
            }
            if let font = font {
                self.titleLabel?.font = font
            }
        }
        
        if let size = size {
            NSLayoutConstraint.activate([
                self.widthAnchor.constraint(equalToConstant: size.width),
                self.heightAnchor.constraint(equalToConstant: size.height)
            ])
        }
        
        self.layer.cornerRadius = cornerRadius
        self.backgroundColor = backgroundColor.withAlphaComponent(0.85)
        self.isHidden = true
        self.translatesAutoresizingMaskIntoConstraints = false
        self.addTarget(target, action: action, for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
