//
//  CustomDateFormatter.swift
//  WF_tz
//
//  Created by Диас Мурзагалиев on 14.12.2024.
//

import Foundation

final class CustomDateFormatter {
    func convertDateString(_ dateString: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        guard let date = dateFormatter.date(from: dateString) else {
            return nil
        }
        
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let formattedDateString = dateFormatter.string(from: date)
        
        return formattedDateString
    }
}
