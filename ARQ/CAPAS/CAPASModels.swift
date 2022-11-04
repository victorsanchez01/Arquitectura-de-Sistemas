//
//  CAPASModels.swift
//  ARQ
//
//  Created by Victor Sanchez on 3/11/22.
//

import UIKit

enum ListMovies
{
    // MARK: Use cases
    
    enum FetchMovies
    {
        struct Request {}
        struct Add {
            var id: String?
            var title: String
            var description: String
            var year: String
        }
        struct Response {
            var movies: [Movie]
        }
        struct ViewModel {
            struct DisplayedMovies {
                var id: String?
                var title: String
                var description: String
                var year: String
            }
            var displayedMovies: [DisplayedMovies]
        }
    }
}

