//
//  CAPASApi.swift
//  ARQ
//
//  Created by Victor Sanchez on 3/11/22.
//

import Foundation
import FirebaseFirestore

protocol MovieAPIProtocol {
    func fetch(completion: @escaping ([Movie]) -> Void)
    func add(_ movie: ListMovies.FetchMovies.Add)
    func delete(_ movie: ListMovies.FetchMovies.ViewModel.DisplayedMovies)
    func edit(_ movie: ListMovies.FetchMovies.ViewModel.DisplayedMovies)
    var delegate: MovieAPIDelegate? { get set }
}

protocol MovieAPIDelegate {
    func movieAPI(movieAPI: MovieAPIProtocol, didFetchMovies movies: [Movie])
}

class MovieAPI: NSObject, MovieAPIProtocol {

    private let db = Firestore.firestore()
    var delegate: MovieAPIDelegate?

    var results = [String: NSMutableData]()

    func fetch(completion: @escaping ([Movie]) -> Void) {
        var movies = [Movie]()
        
        db.collection("movielist").addSnapshotListener { querySnapshot, error in
            if error != nil {
                print("**** ERROR **** \(String(describing: error?.localizedDescription))")
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
                completion(movies)
            }
        }
    }
    
    func add(_ movie: ListMovies.FetchMovies.Add) {
        db.collection("movielist")
            .addDocument(data: ["title": movie.title, "description": movie.description, "year": movie.year])
    }
    
    func delete(_ movie: ListMovies.FetchMovies.ViewModel.DisplayedMovies) {
        db.collection("movielist").document(movie.id!).delete()
    }
    
    func edit(_ movie: ListMovies.FetchMovies.ViewModel.DisplayedMovies){
        db.collection("movielist")
            .document(movie.id!)
            .setData([
                "title": movie.title,
                "year": movie.year,
                "description": movie.description
            ])
    }
}
