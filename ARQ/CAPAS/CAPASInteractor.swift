//
//  CAPASInteractor.swift
//  ARQ
//
//  Created by Victor Sanchez on 3/11/22.
//

import UIKit

protocol ListMoviesBusinessLogic {
    func fetchMovies(request: ListMovies.FetchMovies.Request)
    func addMovies(movie: ListMovies.FetchMovies.Add)
}

class ListMoviesInteractor: ListMoviesBusinessLogic, MoviesWorkerDelegate {
    var presenter: ListMoviesPresentationLogic?
    var moviesWorker = MoviesWorker()
    
    func fetchMovies(request: ListMovies.FetchMovies.Request) {
        moviesWorker.fetch { (movies) in
            let response = ListMovies.FetchMovies.Response(movies: movies)
            self.presenter?.presentFetchedMovies(response: response)
        }
    }
    
    func addMovies(movie: ListMovies.FetchMovies.Add) {
        print("*** MOVIE ADDED*** \(movie)")
        moviesWorker.add(movie)
    }
    
    func moviesWorker(moviesWorker: MoviesWorker, didFetchMovies movies: [Movie]) {
        let response = ListMovies.FetchMovies.Response(movies: movies)
        presenter?.presentFetchedMovies(response: response)
    }
}
