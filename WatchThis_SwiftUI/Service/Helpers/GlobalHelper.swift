//
//  GlobalVariables.swift
//  WatchThis
//
//  Created by Damonique Thomas on 8/18/18.
//  Copyright © 2018 Damonique Thomas. All rights reserved.
//

import UIKit

let imageCache = NSCache<NSString, NSData>()

enum APIError: Error {
    case noResponse
    case jsonDecodingError(error: Error)
    case networkError(error: Error)
}
