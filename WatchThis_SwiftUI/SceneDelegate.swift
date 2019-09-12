//
//  SceneDelegate.swift
//  WatchThis_SwiftUI
//
//  Created by Damonique Thomas on 8/7/19.
//  Copyright © 2019 Damonique Thomas. All rights reserved.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        //TODO: Move that to SwiftUI once implemented
        UINavigationBar.appearance().barTintColor = .black
        
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor(named: "Orange")!,
            NSAttributedString.Key.font: UIFont(name: "ArialRoundedMTBold", size: 24)!]
        
        UIBarButtonItem.appearance().setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor(named: "Orange")!,
            NSAttributedString.Key.font: UIFont(name: "ArialRoundedMTBold", size: 24)!],
                                                            for: .normal)

        // Use a UIHostingController as window root view controller
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            
            let controller = UIHostingController(rootView:
                StoreProvider(store: store) {
                    TabbedView()
            })
            window.rootViewController = controller
            self.window = window
            window.makeKeyAndVisible()
        }
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        store.state.archiveState()
    }
}

let store = Store<AppState>(reducer: appStateReducer,
middleware: [],
state: AppState())

#if DEBUG
let testCast = [1416: [
    Cast(id: 1, name: "Sample Name", character: "Sample Character", profilePath: "/eqgIOObafPJitt8JNh1LuO2fvqu.jpg"),
    Cast(id: 1, name: "Sample Name", character: "Sample Character", profilePath: "/eqgIOObafPJitt8JNh1LuO2fvqu.jpg"),
    Cast(id: 1, name: "Sample Name", character: "Sample Character", profilePath: "/eqgIOObafPJitt8JNh1LuO2fvqu.jpg"),
    Cast(id: 1, name: "Sample Name", character: "Sample Character", profilePath: "/eqgIOObafPJitt8JNh1LuO2fvqu.jpg"),
    Cast(id: 1, name: "Sample Name", character: "Sample Character", profilePath: "/eqgIOObafPJitt8JNh1LuO2fvqu.jpg"),
    Cast(id: 1, name: "Sample Name", character: "Sample Character", profilePath: "/eqgIOObafPJitt8JNh1LuO2fvqu.jpg"),
    Cast(id: 1, name: "Sample Name", character: "Sample Character", profilePath: "/eqgIOObafPJitt8JNh1LuO2fvqu.jpg"),
    Cast(id: 1, name: "Sample Name", character: "Sample Character", profilePath: "/eqgIOObafPJitt8JNh1LuO2fvqu.jpg"),
    Cast(id: 1, name: "Sample Name", character: "Sample Character", profilePath: "/eqgIOObafPJitt8JNh1LuO2fvqu.jpg"),
    Cast(id: 1, name: "Sample Name", character: "Sample Character", profilePath: "/eqgIOObafPJitt8JNh1LuO2fvqu.jpg")]]
let sampleStore = Store<AppState>(reducer: appStateReducer, state: AppState(tvShowState: TVShowState(tvShowCast: testCast), peopleState: PeopleState(),
                                                                            movieState: MovieState()))
#endif

