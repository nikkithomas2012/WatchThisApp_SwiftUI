//
//  ShowHomeView.swift
//  WatchThis_SwiftUI
//
//  Created by Damonique Thomas on 8/25/19.
//  Copyright © 2019 Damonique Thomas. All rights reserved.
//

import SwiftUI
import SwiftUIFlux

struct TVShowListView: View {
    @EnvironmentObject var store: Store<AppState>
    
    private var popularShows: [TraktShow] {
        return store.state.traktState.tvLists[.Popular] ?? [TraktShow]()
    }
    
    private var trendingShows: [TraktShow] {
        return store.state.traktState.tvLists[.Trending] ?? [TraktShow]()
    }
    
    private var mostWatched: [TraktShow] {
        return store.state.traktState.tvLists[.MostWatchedWeekly] ?? [TraktShow]()
    }
    
    private var anticipatedShows: [TraktShow] {
        return store.state.traktState.tvLists[.Anticipated] ?? [TraktShow]()
    }
            
    func fetchShowLists() {
        store.dispatch(action: TraktActions.FetchTraktShowList<[TraktShow]>(endpoint: .TV_Popular, showList: .Popular))
        store.dispatch(action: TraktActions.FetchTraktShowList<[TraktShowListResults]>(endpoint: .TV_Trending, showList: .Trending))
        store.dispatch(action: TraktActions.FetchTraktShowList<[TraktShowListResults]>(endpoint: .TV_MostWatchedWeekly, showList: .MostWatchedWeekly))
        store.dispatch(action: TraktActions.FetchTraktShowList<[TraktShowListResults]>(endpoint: .TV_Anticipated, showList: .Anticipated))
    }
    
    private var noListsLoaded: Bool {
        return popularShows.isEmpty && trendingShows.isEmpty && mostWatched.isEmpty && anticipatedShows.isEmpty
    }
    
    var body: some View {
        ZStack {
            BlurredBackground(image: UIImage(named: "appBackground"), imagePath: nil)
            if noListsLoaded {
                ActivitySpinner()
            } else {
                ScrollView(.vertical) {
                    VStack {
                        TVCategoryRow(title: "Trending Shows", shows: trendingShows)
                        TVCategoryRow(title: "Popular Shows", shows: popularShows)
                        TVCategoryRow(title: "Most Watched (weekly)", shows: mostWatched)
                        TVCategoryRow(title: "Anticipated Shows", shows: anticipatedShows)
                    }
                }.padding(.vertical, 44)
            }
        }
        .navigationBarTitle(Text("Hot Shows"), displayMode: .inline)
        .onAppear() {
            self.fetchShowLists()
        }
    }
}

struct TVCategoryRow: View {
    @EnvironmentObject var store: Store<AppState>
    let title: String
    let shows: [TraktShow]
    
    private func getPosterPath(for show: TraktShow) -> String? {
        return store.state.traktState.slugImages[show.slug]?.posterPath
    }
    
    var body: some View {
        VStack(alignment: HorizontalAlignment.leading) {
            if !shows.isEmpty {
                HStack {
                    Text(title)
                        .font(Font.system(.title, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(shows) { show in
                            NavigationLink(destination: TVShowDetailView(slug: show.slug, showIds: show.ids)) {
                                RoundedImageCell(title: show.title!, posterPath: self.getPosterPath(for: show), height: CGFloat(200))
                            }
                        }
                    }
                }.frame(height: 200)
                Spacer()
            }
        }.padding(.top, 8)
            .padding(.horizontal, 8)
    }
}
