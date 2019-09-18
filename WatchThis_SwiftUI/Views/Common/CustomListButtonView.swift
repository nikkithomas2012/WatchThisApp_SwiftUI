//
//  CustomListButtonView.swift
//  WatchThis_SwiftUI
//
//  Created by Damonique Thomas on 9/17/19.
//  Copyright © 2019 Damonique Thomas. All rights reserved.
//

import SwiftUI

struct CustomListButtonView: View {
    @Binding var showActionSheet: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                CustomListButton(action: {
                    self.showActionSheet.toggle()
                })
                Spacer()
            }.padding(.leading, UIScreen.main.bounds.width / 2 - UIScreen.main.bounds.width/6 - 40)
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