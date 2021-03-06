//
//  AppState.swift
//  WatchThis_SwiftUI
//
//  Created by Damonique Thomas on 8/28/19.
//  Copyright © 2019 Damonique Thomas. All rights reserved.
//

import UIKit
import SwiftUIFlux

fileprivate var savePath: URL!
fileprivate let encoder = JSONEncoder()
fileprivate let decoder = JSONDecoder()

struct AppState: FluxState, Codable {
    var userState: UserState
    var traktState: TraktState
    
    init() {
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory,
                                                                in: .userDomainMask,
                                                                appropriateFor: nil,
                                                                create: false)
            savePath = documentDirectory.appendingPathComponent("userData")
        } catch let error {
            fatalError("Couldn't create save state data with error: \(error)")
        }
                
        if let data = try? Data(contentsOf: savePath),
            let savedState = try? decoder.decode(AppState.self, from: data) {
            self.userState = savedState.userState
            self.traktState = savedState.traktState
        } else {
            self.userState = UserState()
            self.traktState = TraktState()
        }
    }
    
    func archiveState() {
        let shows = traktState.traktShows.filter { (arg) -> Bool in
            let (_, show) = arg
            for list in Array(userState.customLists.values) {
                if list.traktItems.contains(where: { (id, item) in
                    return id == show.slug && item.itemType == .TVShow
                }) {
                    return true
                }
            }
            return false
        }
        let movies = traktState.traktMovies.filter { (arg) -> Bool in
            let (_, movie) = arg
            for list in Array(userState.customLists.values) {
                if list.traktItems.contains(where: { (id, item) in
                    return id == movie.slug && item.itemType == .Movie
                }) {
                    return true
                }
            }
            return false
        }
        let people = traktState.people.filter { (arg) -> Bool in
            let (_, person) = arg
            for list in Array(userState.customLists.values) {
                if list.traktItems.contains(where: { (id, item) in
                    return id == person.slug && item.itemType == .Person
                }) {
                    return true
                }
            }
            return false
        }
        
        var slugImages: [String: TraktImages] = [:]
        shows.forEach({ slugImages[$0.key] = traktState.slugImages[$0.key] })
        movies.forEach({ slugImages[$0.key] = traktState.slugImages[$0.key] })
        people.forEach({ slugImages[$0.key] = traktState.slugImages[$0.key] })

        var savingState = AppState()
        
        // Save Users
        savingState.userState.customLists = userState.customLists
        
        // Save Trakt State
        savingState.traktState.traktShows = shows
        savingState.traktState.traktMovies = movies
        savingState.traktState.people = people
        savingState.traktState.slugImages = slugImages
        
        guard let data = try? encoder.encode(savingState) else {
            return
        }
        try? data.write(to: savePath)
    }
    
    #if DEBUG
    init(userState: UserState, traktState: TraktState) {
        self.userState = userState
        self.traktState = traktState
    }
    #endif
}
