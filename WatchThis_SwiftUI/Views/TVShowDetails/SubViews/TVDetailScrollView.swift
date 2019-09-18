//
//  TVDetailScrollView.swift
//  WatchThis_SwiftUI
//
//  Created by Damonique Thomas on 9/14/19.
//  Copyright © 2019 Damonique Thomas. All rights reserved.
//

import SwiftUI

struct TVDetailScrollView: View {
    @EnvironmentObject var store: Store<AppState>
    @Binding var isFavorite: Bool
    @Binding var showActionSheet: Bool
    let showDetail: TVShowDetails
    
    private var cast: [Cast] {
        return store.state.tvShowState.tvShowDetail[showDetail.id]?.credits?.cast ?? []
    }
    private var similarShows: [TVShowDetails] {
        return store.state.tvShowState.tvShowDetail[showDetail.id]?.similar?.results ?? []
    }
    private var seasons: [Season] {
        return store.state.tvShowState.tvShowDetail[showDetail.id]?.seasons ?? []
    }
    
    var body: some View {
        ScrollView(.vertical) {
            ZStack {
                VStack {
                    TVDetailHeader(showDetail: showDetail)
                    ShowOverviewDetailView(showDetail: showDetail)
                    if cast.count > 0 {
                        CastRow(cast: cast)
                    }
                    if seasons.count > 0 {
                        TVSeasonsRow(seasons: seasons, showId: showDetail.id)
                    }
                    if similarShows.count > 0 {
                        TVSimilarShowsRow(similarShows: similarShows)
                    }
                }
                FavoriteButtonView(isFavorite: $isFavorite, addAction: TVShowActions.AddShowToFavorites(showId: showDetail.id), removeAction: TVShowActions.RemoveShowFromFavorites(showId: showDetail.id))
                CustomListButtonView(showActionSheet: $showActionSheet)
                WatchTrailerButton()
            }
        }.padding(8)
    }
}

struct CustomListButtonView: View {
    @Binding var showActionSheet: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                CustomListButton(action: {
                    self.showActionSheet.toggle()
                })
                Spacer()
            }.padding(.leading, UIScreen.main.bounds.width / 2 - UIScreen.main.bounds.width/6 - 80)
            Spacer()
        }.padding(.top, 310)
    }
}

struct CustomListButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: { self.action() } ) {
            ZStack {
                Circle().foregroundColor(.orange)
                Image(systemName: "text.badge.plus")
                    .imageScale(.large)
                    .foregroundColor(.white)
            }
        }.frame(width: 30, height: 30)
    }
}