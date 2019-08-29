//
//  PeopleActions.swift
//  WatchThis_SwiftUI
//
//  Created by Damonique Thomas on 8/28/19.
//  Copyright © 2019 Damonique Thomas. All rights reserved.
//

import Foundation

struct PeopleActions {
    
    struct FetchPersonDetails: AsyncAction {
        let id: Int
        func execute(state: FluxState?, dispatch: @escaping DispatchFunction) {
            TMDBClient.sharedInstance().GET(endpoint: TMDBClient.Endpoint.Person_Details(id: id), params: parameters)
            {
                (result: Result<Person, APIError>) in
                switch result {
                case let .success(response):
                    dispatch(SetPersonDetail(id: self.id, personDetail: response))
                case let .failure(error):
                    print(error)
                    break
                }
            }
        }
    }
    
    // TODO: Change to handle movies
    struct FetchPersonCombinedCredit: AsyncAction {
        let id: Int
        func execute(state: FluxState?, dispatch: @escaping DispatchFunction) {
            TMDBClient.sharedInstance().GET(endpoint: TMDBClient.Endpoint.Person_Combined_Credits(id: id), params: parameters)
            {
                (result: Result<[TVShow], APIError>) in
                switch result {
                case let .success(response):
                    dispatch(SetPersonCredits(id: self.id, tvShows: response))
                case let .failure(error):
                    print(error)
                    break
                }
            }
        }
    }
    
    struct SetPersonDetail: Action {
        let id: Int
        let personDetail: Person
    }
    
    struct SetPersonCredits: Action {
        let id: Int
        let tvShows: [TVShow]
    }
}
