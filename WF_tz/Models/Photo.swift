//
//  Photo.swift
//  WF_tz
//
//  Created by Диас Мурзагалиев on 14.12.2024.
//

import Foundation

struct Photo: Decodable {
    let id: String
    let created_at: String
    let width: Int
    let height: Int
    let urls: [URLType.RawValue : String]
    let user: User
}
