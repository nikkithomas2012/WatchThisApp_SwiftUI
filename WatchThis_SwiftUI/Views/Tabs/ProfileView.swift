//
//  ProfileView.swift
//  WatchThis_SwiftUI
//
//  Created by Damonique Thomas on 9/17/19.
//  Copyright © 2019 Damonique Thomas. All rights reserved.
//

import SwiftUI
import SwiftUIFlux

struct ProfileView: View {
    @EnvironmentObject var store: Store<AppState>
    @State var showSettings = false
    
    private var customLists: [CustomList] {
        let lists = Array(store.state.userState.customLists.values)
        // This handles the list migrations from TMDb to Trakt
        for list in lists {
            for (_, item) in list.items {
                if let slug = store.state.traktState.tmdbIdToSlug[item.id] {
                    if list.traktItems[slug] == nil {
                        store.state.userState.customLists[list.id]?.traktItems[slug] = TraktListItem(slug: slug, itemType: item.itemType)
                    }
                }
            }
        }
        return lists
    }
    
    var body: some View {
        ZStack {
            BlurredBackground(image: UIImage(named: "appBackground"), imagePath: nil)
            if customLists.count > 0 {
                ScrollView(.vertical) {
                    VStack {
                        ForEach(customLists) { list in
                            CustomListRow(customList: list)
                        }
                    }
                }.padding(.vertical, 44)
            } else {
                VStack {
                    Text("View your custom lists here. To create a custom list, visit a TV Show, Movie or Person screen and click the button that looks like this:")
                        .font(.headline)
                        .foregroundColor(.white)
                        .fixedSize(horizontal: false, vertical: true)
                    Image(systemName: "text.badge.plus")
                        .imageScale(.large)
                        .foregroundColor(.white)
                }.padding()
            }
        }
        .navigationBarTitle(Text("Your Lists"), displayMode: .inline)
        .navigationBarItems(trailing: NavigationLink(destination: SettingsView()) {
            Image(systemName: "gear").font(Font.system(size: 25, weight: .regular))
        })
    }
}

struct CustomListRow: View {
    @EnvironmentObject var store: Store<AppState>
    let customList: CustomList
    
    lazy var computedListItems: [ListItemIdAndImagePath] = {
        var items = [ListItemIdAndImagePath]()
        for item in Array(customList.traktItems.values) {
            switch item.itemType {
            case .TVShow:
                if let detail = store.state.traktState.traktShows[item.slug] {
                    let posterPath = store.state.traktState.slugImages[item.slug]?.posterPath
                    items.append(ListItemIdAndImagePath(itemType: .TVShow, slug: item.slug, ids: detail.ids, itemName: detail.title, imagePath: posterPath))
                }
                break
            case .Movie:
                if let detail = store.state.traktState.traktMovies[item.slug] {
                    let posterPath = store.state.traktState.slugImages[item.slug]?.posterPath
                    items.append(ListItemIdAndImagePath(itemType: .Movie, slug: item.slug, ids: detail.ids, itemName: detail.title, imagePath: posterPath))
                }
                break
            case .Person:
                if let detail = store.state.traktState.people[item.slug] {
                    let posterPath = store.state.traktState.slugImages[item.slug]?.posterPath
                    items.append(ListItemIdAndImagePath(itemType: .Person, slug: item.slug, ids: detail.ids, itemName:detail.name, imagePath: posterPath))
                }
                break
            }
        }
        return items
    }()
    
    private var listItems: [ListItemIdAndImagePath] {
        var mutatableSelf = self
        return mutatableSelf.computedListItems
    }
    
    var body: some View {
        VStack(alignment: HorizontalAlignment.leading) {
            HStack {
                Text(customList.listName)
                    .font(Font.system(.title, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
            }
            ScrollView(.horizontal) {
                HStack {
                    ForEach(listItems) { item in
                        CustomListRowCell(item: item)
                    }
                }
            }.frame(height: 200)
            Spacer()
        }.padding(.top, 8)
        .padding(.horizontal, 8)
    }
}

struct CustomListRowCell: View {
    @EnvironmentObject var store: Store<AppState>
    let item: ListItemIdAndImagePath
    
    var body: some View {
        VStack {
            if item.itemType == ItemType.TVShow {
                NavigationLink(destination: TVShowDetailView(slug: item.slug, showIds: item.ids)) {
                    RoundedImageCell(title: item.itemName ?? "", posterPath: item.imagePath, height: CGFloat(200))
                }
            }
            if item.itemType == ItemType.Movie {
                NavigationLink(destination: MovieDetailsView(slug: item.slug, movieIds: item.ids)) {
                    RoundedImageCell(title: item.itemName ?? "", posterPath: item.imagePath, height: CGFloat(200))
                }
            }
            if item.itemType == ItemType.Person {
                NavigationLink(destination: PersonDetailsView(personDetails: store.state.traktState.people[item.slug]!)) {
                    RoundedImageCell(title: item.itemName ?? "", posterPath: item.imagePath, height: CGFloat(200))
                }
            }
        }
    }
}

struct ListItemIdAndImagePath: Identifiable {
    let itemType: ItemType
    let slug: String
    let ids: Ids
    let itemName: String?
    let imagePath: String?
    
    var id = UUID()
}
