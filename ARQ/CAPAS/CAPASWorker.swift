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
    
    // MARK: Block implementation
    func fetch(completion: @escaping ([Movie]) -> Void) {
        movieAPI.fetch { (movies) in
            completion(movies)
        }
    }
    
    // MARK: Delegate implementation
    func fetch() {
        movieAPI.delegate = self
        movieAPI.fetch { _ in
        }
    }
    
    func add(_ movie: ListMovies.FetchMovies.Add) {
        movieAPI.add(movie)
    }
    
    func movieAPI(movieAPI: MovieAPIProtocol, didFetchMovies movies: [Movie]) {
        delegate?.moviesWorker(moviesWorker: self, didFetchMovies: movies)
    }
}
