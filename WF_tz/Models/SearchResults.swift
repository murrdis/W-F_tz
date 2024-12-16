//
//  SearchResults.swift
//  WF_tz
//
//  Created by Диас Мурзагалиев on 12.12.2024.
//

import Foundation

struct SearchResults: Decodable {
    let total: Int
    let results: [Photo]
}
