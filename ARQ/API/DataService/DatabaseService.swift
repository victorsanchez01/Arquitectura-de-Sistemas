//
//  DatabaseService.swift
//  ARQ
//
//  Created by Victor Sanchez on 2/11/22.
//

import Foundation
import UIKit
import ObjectMapper
import FirebaseFirestore

private let databaseServiceName = "DatabaseService"
private let db = Firestore.firestore()

extension ServiceRegistryImplementation {
    var databaseService: DatabaseService {
        get {
            return serviceWith(name: databaseServiceName) as! DatabaseService
        }
    }
}

protocol DatabaseService: Service {
    func addMovie(title: String, description: String, year: String, completion: @escaping (Result<Bool, Error>) -> ())
}

extension DatabaseService {
    var serviceName: String {
        get {
            return databaseServiceName
        }
    }
    
    func addMovie(title: String, description: String, year: String,  completion: @escaping (Result<Bool, Error>) -> ()) {
        db.collection("movielist").addDocument(data: [
            "title": title,
            "description": description,
            "year": year
        ])
        completion(.success(true))
    }
}

internal class DatabaseServiceImplementation: DatabaseService {
    
    internal static func register() {
        ServiceRegistry.add(service: LazyService(serviceName: databaseServiceName, serviceGetter: {
            DatabaseServiceImplementation()
        }))
    }
}
