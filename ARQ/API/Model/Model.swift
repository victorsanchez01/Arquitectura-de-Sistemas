//
//  Model.swift
//  ARQ
//
//  Created by Victor Sanchez on 11/11/22.
//

import Foundation

struct MovieAPIModel: Codable {
    let movies: [MovieData]
    
    private enum CodingKeys: String, CodingKey {
        case movies = "documents"
    }
}

struct MovieData: Codable {
    let name: String?
    let fields: Document
}

struct Document: Codable {
    let title: String
    let year: String
    let description: String
    
    private enum FieldKeys:  String, CodingKey {
        case title
        case year
        case description
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: FieldKeys.self)
        title = try container.decode(StringValue.self, forKey: .title).value
        description = try container.decode(StringValue.self, forKey: .description).value
        year = try container.decode(StringValue.self, forKey: .year).value
    }
    
}

struct StringValue: Codable {
    let value: String
    
    private enum CodingKeys: String, CodingKey {
        case value = "stringValue"
    }
}

struct APIDocumentPost: Codable {
    var fields : Fields
}

struct Fields: Codable {
    var title: String
    var year: String
    var description: String
}



