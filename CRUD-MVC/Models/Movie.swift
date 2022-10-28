//
//  Movie.swift
//  ArquitecturaDeSoftware
//
//  Created by victor.sanchez on 20/10/22.
//

import Foundation

struct Movie: Identifiable, Codable {
    var id: String?
    var title: String
    var description: String
    var year: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case year
    }
}
