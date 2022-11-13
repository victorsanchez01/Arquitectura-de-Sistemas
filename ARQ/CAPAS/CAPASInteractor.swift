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
    func deleteMovies(movie: ListMovies.FetchMovies.ViewModel.DisplayedMovies)
    func editMovies(movie: ListMovies.FetchMovies.ViewModel.DisplayedMovies)
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
        moviesWorker.add(movie)
    }
    
    func deleteMovies(movie: ListMovies.FetchMovies.ViewModel.DisplayedMovies) {
        moviesWorker.delete(movie)
    }
    
    func editMovies(movie: ListMovies.FetchMovies.ViewModel.DisplayedMovies) {
        moviesWorker.edit(movie)
    }
    
    func moviesWorker(moviesWorker: MoviesWorker, didFetchMovies movies: [Movie]) {
        let response = ListMovies.FetchMovies.Response(movies: movies)
        presenter?.presentFetchedMovies(response: response)
    }
}
