//
//  CAPASWorker.swift
//  ARQ
//
//  Created by Victor Sanchez on 3/11/22.
//

import UIKit

protocol MoviesWorkerDelegate {
    func moviesWorker(moviesWorker: MoviesWorker, didFetchMovies movies: [Movie])
}

class MoviesWorker: MovieAPIDelegate {
    var movieAPI: MovieAPIProtocol = MovieAPI()
    var delegate: MoviesWorkerDelegate?
   
    func fetch(completion: @escaping ([Movie]) -> Void) {
        movieAPI.fetch { (movies) in
            completion(movies)
        }
    }
  
    func fetch() {
        movieAPI.delegate = self
        movieAPI.fetch { _ in
        }
    }
    
    func add(_ movie: ListMovies.FetchMovies.Add) {
        movieAPI.add(movie)
    }
    
    func delete(_ movie: ListMovies.FetchMovies.ViewModel.DisplayedMovies) {
        movieAPI.delete(movie)
    }
    
    func edit(_ movie: ListMovies.FetchMovies.ViewModel.DisplayedMovies) {
        movieAPI.edit(movie)
    }
    
    func movieAPI(movieAPI: MovieAPIProtocol, didFetchMovies movies: [Movie]) {
        delegate?.moviesWorker(moviesWorker: self, didFetchMovies: movies)
    }
}
