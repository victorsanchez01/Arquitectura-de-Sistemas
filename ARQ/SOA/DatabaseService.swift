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

extension ServiceRegistryImplementation {
    var databaseService: DatabaseService {
        get {
            return serviceWith(name: databaseServiceName) as! DatabaseService
        }
    }
}

protocol DatabaseService: Service {
    func getMovies(success: @escaping ([Movie]) -> (), failure: @escaping (Error) -> ())
}

extension DatabaseService {
    var serviceName: String {
        get {
            return databaseServiceName
        }
    }
    
    func getMovies(success: @escaping ([Movie]) -> (), failure: @escaping (Error) -> ()) {
        let db = Firestore.firestore()
        var movies = [Movie]()
        
        db.collection("movielist").addSnapshotListener { querySnapshot, error in
            if error != nil {
                print("**** ERROR **** \(String(describing: error?.localizedDescription))")
                failure(error!)
                return
            } else {
                movies = []
                for movie in querySnapshot?.documents ?? [] {
                    movies.append(
                        Movie(
                            id: movie.documentID,
                            title: movie["title"] as? String ?? "",
                            description: movie["description"] as? String ?? "",
                            year: movie["year"] as? String ?? "")
                    )
                }
               success(movies)
            }
        }
    }
}

internal class DatabaseServiceImplementation: DatabaseService {
    internal static func register() {
        ServiceRegistry.add(service: LazyService(serviceName: databaseServiceName, serviceGetter: {
            DatabaseServiceImplementation()
        }))
    }
}
