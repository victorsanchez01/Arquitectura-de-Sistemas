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
    func getMovies(success: @escaping ([Movie]) -> (), failure: @escaping (Error) -> ())
    func addMovie(title: String, description: String, year: String, completion: @escaping (Result<Bool, Error>) -> ())
    func editMovie(id: String, title: String, description: String, year: String)
    func deleteMovie(id: String)
}

extension DatabaseService {
    var serviceName: String {
        get {
            return databaseServiceName
        }
    }
    
    func getMovies(success: @escaping ([Movie]) -> (), failure: @escaping (Error) -> ()) {
        
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
    
    func addMovie(title: String, description: String, year: String,  completion: @escaping (Result<Bool, Error>) -> ()) {
        db.collection("movielist").addDocument(data: [
            "title": title,
            "description": description,
            "year": year
        ])
        completion(.success(true))
    }
    
    func editMovie(id: String, title: String, description: String, year: String) {
        db.collection("movielist").document(id)
            .setData([
                "title": title,
                "year": year,
                "description": description
            ])
    }
    
    func deleteMovie(id: String) {
        db.collection("movielist").document(id).delete()
    }
}

internal class DatabaseServiceImplementation: DatabaseService {
    
    internal static func register() {
        ServiceRegistry.add(service: LazyService(serviceName: databaseServiceName, serviceGetter: {
            DatabaseServiceImplementation()
        }))
    }
}
