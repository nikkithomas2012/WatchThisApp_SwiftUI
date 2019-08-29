//
//  PeopleState.swift
//  WatchThis_SwiftUI
//
//  Created by Damonique Thomas on 8/28/19.
//  Copyright © 2019 Damonique Thomas. All rights reserved.
//

import Foundation

struct PeopleState: FluxState, Codable {
    var people: [Int: Person] = [:]
    var peopleCredits: [Int: [TVShow]] = [:]
}
