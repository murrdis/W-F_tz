//
//  ErrorView.swift
//  WF_tz
//
//  Created by Диас Мурзагалиев on 13.12.2024.
//

import UIKit

final class ErrorView: UIView {
    private lazy var stackView: UIStackView = makeStackView()
    private lazy var errorImageView: UIImageView = makeErrorImageView()
    private lazy var errorLabel: UILabel = makeErrorLabel(fontSize: 20, isBold: true)
    private lazy var errorDescriptionLabel: UILabel = makeErrorLabel(fontSize: 16, isBold: false)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16)
        ])
        isHidden = true
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func makeStackView() -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [errorImageView, errorLabel, errorDescriptionLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    private func makeErrorImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .gray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        return imageView
    }
    
    private func makeErrorLabel(fontSize: CGFloat, isBold: Bool) -> UILabel {
        let label = UILabel()
        label.font = isBold ? UIFont.boldSystemFont(ofSize: fontSize) : UIFont.systemFont(ofSize: fontSize)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    func showError(_ error: Error) {
        let title: String
        let description: String
        let image: UIImage?

        if let networkError = error as? NetworkError {
            switch networkError {
            case .noInternet:
                title = "Network error"
                description = "Check your internet connection"
                image = UIImage(systemName: "wifi.exclamationmark")
            case .timeout:
                title = "The request timed out"
                description = "Please try again later"
                image = UIImage(systemName: "clock.arrow.circlepath")
            case .notFound:
                title = "No Results Found"
                description = "Try changing your request"
                image = UIImage(systemName: "magnifyingglass")
            default:
                title = "Something went wrong"
                description = "Please try again later \n(Probably Unsplash limits have been spent)"
                image = UIImage(systemName: "exclamationmark.triangle")
            }
        } else {
            title = "Something went wrong"
            description = "Please try again later \n(Probably Unsplash limits have been spent)"
            image = UIImage(systemName: "exclamationmark.triangle")
        }

        DispatchQueue.main.async {
            self.errorLabel.text = title
            self.errorDescriptionLabel.text = description
            self.errorImageView.image = image
            self.isHidden = false
        }
    }
    
    func hideError() {
        isHidden = true
    }
}
