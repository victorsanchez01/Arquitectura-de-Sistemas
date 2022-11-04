//
//  CAPASPresenter.swift
//  ARQ
//
//  Created by Victor Sanchez on 3/11/22.
//

import UIKit

protocol ListMoviesPresentationLogic {
    func presentFetchedMovies(response: ListMovies.FetchMovies.Response)
}

class ListMoviesPresenter: ListMoviesPresentationLogic {
    weak var viewController: ListMoviesDisplayLogic?
    
    func presentFetchedMovies(response: ListMovies.FetchMovies.Response) {
        let displayedMovies = convertMovies(movies: response.movies)
        let viewModel = ListMovies.FetchMovies.ViewModel(displayedMovies: displayedMovies)
        viewController?.displayFetchedMovies(viewModel: viewModel)
    }
    
    private func convertMovies(movies: [Movie]) -> [ListMovies.FetchMovies.ViewModel.DisplayedMovies] {
        return movies.map { ListMovies.FetchMovies.ViewModel.DisplayedMovies(id: $0.id, title: $0.title, description: $0.description, year: $0.year)
        }
    }
}
