//
//  ImageService.swift
//  WatchThis_SwiftUI
//
//  Created by Damonique Thomas on 8/29/19.
//  Copyright © 2019 Damonique Thomas. All rights reserved.
//

import UIKit
import Combine

class ImageService {
    static let sharedInstance = ImageService()
    
    private init() {}
    
    enum Size: String, Codable {
        case small = "https://image.tmdb.org/t/p/w154"
        case medium = "https://image.tmdb.org/t/p/w500"
        case cast = "https://image.tmdb.org/t/p/w185"
        case original = "https://image.tmdb.org/t/p/original"
        
        func path(urlPath: String) -> URL {
            return URL(string: rawValue)!.appendingPathComponent(urlPath)
        }
    }
    
    enum ImageError: Error {
        case error(error: Error)
    }
    
    func fetchImage(urlPath: String, size: Size) -> AnyPublisher<UIImage?, ImageError> {
        let url = size.path(urlPath: urlPath)
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { (data, response) -> UIImage? in
                return UIImage(data: data)
            }
            .mapError { error -> ImageError in
                return ImageError.error(error: error)
            }
            .eraseToAnyPublisher()
    }
}
