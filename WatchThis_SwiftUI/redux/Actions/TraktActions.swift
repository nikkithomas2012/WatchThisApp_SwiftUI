//
//  TraktActions.swift
//  WatchThis_SwiftUI
//
//  Created by Damonique Blake on 3/12/20.
//  Copyright © 2020 Damonique Thomas. All rights reserved.
//

import Foundation
import SwiftUIFlux

struct TraktActions {
    struct FetchTraktShowList<T: Codable>: AsyncAction {
        let endpoint: TraktApiClient.Endpoint
        let showList: TVShowList
        func execute(state: FluxState?, dispatch: @escaping DispatchFunction) {
            TraktApiClient.sharedInstance().GET(endpoint: endpoint, params: Trakt_Parameters) { (result: Result<T, APIError>) in
                switch result {
                case let .success(response):
                    if T.self == [TraktShow].self {
                        dispatch(SetTVShowList(list: self.showList, shows: response as! [TraktShow]))
                        dispatch(FetchImagesFromTMDB(shows: response as! [TraktShow]))
                    } else if T.self == [TraktShowListResults].self {
                        let list = (response as! [TraktShowListResults]).compactMap {$0.show}
                        dispatch(SetTVShowList(list: self.showList, shows: list))
                        dispatch(FetchImagesFromTMDB(shows: list))
                    }
                    
                case let .failure(error):
                    #if DEBUG
                    print(error)
                    #endif
                    break
                }
            }
        }
    }
    
    struct FetchFromTraktApi<U: Codable>: AsyncAction {
        let ids: Ids
        let endpoint: TraktApiClient.Endpoint
        var extendedInfo = true
        func execute(state: FluxState?, dispatch: @escaping DispatchFunction) {
            guard let slug = ids.slug else {
                return
            }
            let params = extendedInfo ? Trakt_Parameters : [:]
            TraktApiClient.sharedInstance().GET(endpoint: endpoint, params: params) { (result: Result<U, APIError>) in
                switch result {
                case let .success(response):
                    if self.endpoint == TraktApiClient.Endpoint.TV_Seasons(slug: slug) {
                        let seasons = response as! [TraktSeason]
                        dispatch(FetchSeasonImagesFromTMDB(showIds: self.ids, seasons: seasons))
                        dispatch(SetSeasons(showSlug: slug, seasons: seasons))
                    } else if self.endpoint == TraktApiClient.Endpoint.TV_Cast(slug: slug) {
                        let cast = (response as! TraktPeopleResults).cast
                        let people = cast.map({ $0.person })
                        dispatch(FetchPeopleImagesFromTMDB(people: people))
                        dispatch(SetCast(showSlug: slug, cast: cast))
                    } else if self.endpoint == TraktApiClient.Endpoint.TV_Related(slug: slug) {
                        let shows = response as! [TraktShow]
                        dispatch(FetchImagesFromTMDB(shows: shows))
                        dispatch(SetRelatedShows(showSlug: slug, shows: shows))
                    } else if self.endpoint == TraktApiClient.Endpoint.TV_Details(slug: slug) {
                        let show = response as! TraktShow
                        dispatch(FetchImagesFromTMDB(shows: [show]))
                    } else if self.endpoint == TraktApiClient.Endpoint.Person_TVCredits(slug: slug) {
                        let castlist = (response as! TraktShowCreditsResults).cast
                        dispatch(SetPersonShowCredits(slug: slug, credit: castlist))
                        let shows = castlist.map({$0.show})
                        dispatch(FetchImagesFromTMDB(shows: shows))
                    } else {
                        print("Endpoint \"\(self.endpoint.path())\" action not defined.")
                    }
                case let .failure(error):
                    #if DEBUG
                    print(error)
                    #endif
                    break
                }
            }
        }
    }
    
    struct SearchTraktApi: AsyncAction {
        let query: String
        let endpoint: TraktApiClient.Endpoint
        func execute(state: FluxState?, dispatch: @escaping DispatchFunction) {
            var params = Trakt_Parameters
            params["query"] = query
            TraktApiClient.sharedInstance().GET(endpoint: endpoint, params: params) { (result: Result<[TraktSearchResult], APIError>) in
                switch result {
                case let .success(response):
                    if self.endpoint == TraktApiClient.Endpoint.Search_TV {
                        let shows = response.compactMap { $0.show }
                        dispatch(FetchImagesFromTMDB(shows: shows))
                        dispatch(SetTVShowSearch(query: self.query, shows: shows))
                    } else if self.endpoint == TraktApiClient.Endpoint.Search_People {
                        let people = response.compactMap { $0.person }
                        dispatch(FetchPeopleImagesFromTMDB(people: people))
                        dispatch(SetPeopleSearch(query: self.query, people: people))
                    } else {
                        print("Endpoint \"\(self.endpoint.path())\" action not defined.")
                    }
                case let .failure(error):
                    #if DEBUG
                    print("Search error: \(error)")
                    #endif
                    break
                }
            }
        }
    }
    
    struct FetchSeasonEpisodes: AsyncAction {
        let showIds: Ids
        let seasonNumber: Int
        func execute(state: FluxState?, dispatch: @escaping DispatchFunction) {
            TraktApiClient.sharedInstance().GET(endpoint: .TV_TVSeasonEpisodes(slug: showIds.slug!, seasonNumber: seasonNumber), params: Trakt_Parameters) { (result: Result<[TraktEpisode], APIError>) in
                switch result {
                case let .success(response):
                    dispatch(SetEpisodes(showSlug: self.showIds.slug!, seasonNumber: self.seasonNumber, episodes: response))
                    dispatch(FetchEpisodeImagesFromTMDB(showTmdbId: self.showIds.tmdb!, seasonNumber: self.seasonNumber, episodes: response))
                case let .failure(error):
                    #if DEBUG
                    print(error)
                    #endif
                    break
                }
            }
        }
    }
    
    struct FetchImagesFromTMDB: AsyncAction {
        let shows: [TraktShow]
        func execute(state: FluxState?, dispatch: @escaping DispatchFunction) {
            for show in shows {
                if let appState = state as? AppState, let tmdbId = show.ids.tmdb, let slug = show.ids.slug {
                    // Only fetch images if not already in state.
                    if appState.tvShowState.slugImages[slug] == nil {
                        TMDBClient.sharedInstance.GET(endpoint: TMDBClient.Endpoint.TV_ShowDetails(id: tmdbId), params: TMDB_Parameters)
                        {
                            (result: Result<TVShowDetails, APIError>) in
                            switch result {
                            case let .success(response):
                                dispatch(SetSlugImage(slug: slug, slugImage: .init(backgroundPath: response.backdropPath, posterPath: response.posterPath)))
                            case let .failure(error):
                                #if DEBUG
                                print("Images error: \(error)")
                                #endif
                                break
                            }
                        }
                    }
                    dispatch(SetShow(slug: slug, show: show))
                }
            }
        }
    }
    
    struct FetchSeasonImagesFromTMDB: AsyncAction {
        let showIds: Ids
        let seasons: [TraktSeason]
        func execute(state: FluxState?, dispatch: @escaping DispatchFunction) {
            for season in seasons {
                if let appState = state as? AppState, let tmdbId = season.ids.tmdb, let showTmdbId = showIds.tmdb {
                    // Only fetch images if not already in state.
                    if appState.tvShowState.traktImages[.Season]?[tmdbId] == nil {
                        TMDBClient.sharedInstance.GET(endpoint: TMDBClient.Endpoint.TV_Seasons_Details(id: showTmdbId, seasonNum: season.number), params: TMDB_Parameters)
                        {
                            (result: Result<Season, APIError>) in
                            switch result {
                            case let .success(response):
                                dispatch(SetEntityImages(entity: .Season, tmdbId: tmdbId, slugImage: .init(backgroundPath: nil, posterPath: response.posterPath)))
                            case let .failure(error):
                                #if DEBUG
                                print(error)
                                #endif
                                break
                            }
                        }
                    }
                }
            }
        }
    }
    
    struct FetchPeopleImagesFromTMDB: AsyncAction {
        let people: [TraktPerson]
        func execute(state: FluxState?, dispatch: @escaping DispatchFunction) {
            for person in people {
                if let appState = state as? AppState, let tmdbId = person.ids.tmdb {
                    // Only fetch images if not already in state.
                    if appState.tvShowState.traktImages[.Person]?[tmdbId] == nil {
                        TMDBClient.sharedInstance.GET(endpoint: TMDBClient.Endpoint.Person_Details(id: tmdbId), params: TMDB_Parameters)
                        {
                            (result: Result<Person, APIError>) in
                            switch result {
                            case let .success(response):
                                dispatch(SetEntityImages(entity: .Person, tmdbId: tmdbId, slugImage: .init(backgroundPath: nil, posterPath: response.profilePath)))
                            case let .failure(error):
                                #if DEBUG
                                print("People Images error: \(error)")
                                #endif
                                break
                            }
                        }
                    }
                }
            }
        }
    }
    
    struct FetchEpisodeImagesFromTMDB: AsyncAction {
        let showTmdbId: Int
        let seasonNumber: Int
        let episodes: [TraktEpisode]
        func execute(state: FluxState?, dispatch: @escaping DispatchFunction) {
            for episode in episodes {
                if let appState = state as? AppState, let tmdbId = episode.ids.tmdb {
                    // Only fetch images if not already in state.
                    if appState.tvShowState.traktImages[.Season]?[tmdbId] == nil {
                        TMDBClient.sharedInstance.GET(endpoint: TMDBClient.Endpoint.TV_Episode_Details(id: showTmdbId, seasonNum: seasonNumber, episodeNum: episode.number), params: TMDB_Parameters)
                        {
                            (result: Result<Episode, APIError>) in
                            switch result {
                            case let .success(response):
                                dispatch(SetEntityImages(entity: .Episode, tmdbId: tmdbId, slugImage: .init(backgroundPath: nil, posterPath: response.stillPath)))
                            case let .failure(error):
                                #if DEBUG
                                print(error)
                                #endif
                                break
                            }
                        }
                    }
                }
            }
        }
    }
    
    struct SetTVShowList: Action {
        let list: TVShowList
        let shows: [TraktShow]
    }
    
    struct SetShowSlug: Action {
        let showId: Int
        let slug: String
    }
    
    struct SetSlugImage: Action {
        let slug: String
        let slugImage: TraktImages
    }
    
    struct SetShow: Action {
        let slug: String
        let show: TraktShow
    }
    
    struct SetSeasons: Action {
        let showSlug: String
        let seasons: [TraktSeason]
    }
    
    struct SetEpisodes: Action {
        let showSlug: String
        let seasonNumber: Int
        let episodes: [TraktEpisode]
    }
    
    struct SetCast: Action {
        let showSlug: String
        let cast: [TraktCast]
    }
    
    struct SetRelatedShows: Action {
        let showSlug: String
        let shows: [TraktShow]
    }
    
    struct SetEntityImages: Action {
        let entity: TraktEntity
        let tmdbId: Int
        let slugImage: TraktImages
    }
    
    struct SetPersonShowCredits: Action {
        let slug: String
        let credit: [TraktShowCredits]
    }
    
    struct SetTVShowSearch: Action {
        let query: String
        let shows: [TraktShow]
    }
    
    struct SetPeopleSearch: Action {
        let query: String
        let people: [TraktPerson]
    }
    
    struct SetMovieSearch: Action {
        let query: String
//        let movies: [TraktPerson]
    }
}
