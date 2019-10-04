//
//  MovieDetailsView.swift
//  WatchThis_SwiftUI
//
//  Created by Damonique Thomas on 9/12/19.
//  Copyright © 2019 Damonique Thomas. All rights reserved.
//

import SwiftUI

struct MovieDetailsView: View {
    @EnvironmentObject var store: Store<AppState>
    @State private var showActionSheet = false
    @State private var showVideoPlayer = false
    
    let movieId: Int
    private var movieDetails: MovieDetails {
        return store.state.movieState.movieDetails[movieId] ?? MovieDetails(id: movieId, title: "")
    }
    
    private func fetchMovieDetails() {
        if store.state.movieState.movieDetails[movieId] == nil {
            store.dispatch(action: MovieActions.FetchMovieDetails(id: movieDetails.id))
        }
    }
    
    private var video: Video? {
        if let videos = movieDetails.videos?.results, !videos.isEmpty {
            return videos[0]
        }
        
        return nil
    }
        
    var body: some View {
        DetailView(id: movieId, title: movieDetails.title, itemType: .Movie, video: video, imagePath: movieDetails.posterPath, showActionSheet: $showActionSheet, showVideoPlayer: $showVideoPlayer) {
            MovieDetailsScrollView(showActionSheet: self.$showActionSheet, showVideoPlayer: self.$showVideoPlayer, movieDetails: self.movieDetails)
        }.onAppear() {
            self.fetchMovieDetails()
        }
    }
}

#if DEBUG
struct MovieDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        MovieDetailsView(movieId: testMovieDetails.id).environmentObject(sampleStore)
    }
}
#endif
