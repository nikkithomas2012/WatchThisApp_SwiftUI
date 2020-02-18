//
//  ContentView.swift
//  WatchThis_SwiftUI
//
//  Created by Damonique Thomas on 8/7/19.
//  Copyright © 2019 Damonique Thomas. All rights reserved.
//

import SwiftUI
import SwiftUIFlux

struct TVShowDetailView: View {
    @EnvironmentObject var store: Store<AppState>
    @State private var showActionSheet = false
    @State private var showVideoPlayer = false
    
    let showId: Int
    private var showDetail: TVShowDetails {
        return store.state.tvShowState.tvShowDetail[showId] ?? TVShowDetails(id: showId, name: "")
    }
    
    private func fetchShowDetails() {
        if store.state.tvShowState.tvShowDetail[showId] == nil {
            store.dispatch(action: TVShowActions.FetchTVShowDetails(id: showId))
        }
    }
    
    private var video: Video? {
        if let videos = showDetail.videos?.results, !videos.isEmpty {
            return videos[0]
        }
        
        return nil
    }
        
    var body: some View {
        DetailView(id: showId, title: showDetail.name, itemType: .TVShow, video: video, imagePath: showDetail.posterPath, showActionSheet: $showActionSheet, showVideoPlayer: $showVideoPlayer) {
            TVDetailScrollView(showActionSheet: self.$showActionSheet, showVideoPlayer: self.$showVideoPlayer, showDetail: self.showDetail)
        }.onAppear() {
            self.fetchShowDetails()
        }
    }
}

#if DEBUG
struct TVShowDetailView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TVShowDetailView(showId: testTVShowDetail.id).environmentObject(sampleStore)
                .previewDevice(PreviewDevice(rawValue: "iPhone XS Max"))
                .previewDisplayName("iPhone XS Max")
            
//            TVShowDetailView(showId: testTVShowDetail.id).environmentObject(sampleStore)
//                .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
//                .previewDisplayName("iPhone SE")
        }
    }
}
#endif
