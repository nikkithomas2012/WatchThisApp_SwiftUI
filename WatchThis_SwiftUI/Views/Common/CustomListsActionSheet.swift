//
//  CustomListsActionSheet.swift
//  WatchThis_SwiftUI
//
//  Created by Damonique Thomas on 9/16/19.
//  Copyright © 2019 Damonique Thomas. All rights reserved.
//

import SwiftUI

struct CustomListActionSheet {
    @ObservedObject var customListModel: CustomListModel
    @Binding var showCustomListConfirmation: Bool
    private let customLists: [CustomList]
    private let objectName: String
    private let objectId: Int
    private let itemType: ItemType
    
    var title: Text {
        return Text("Custom Lists for \(objectName)")
    }
    var message: Text? {
        return Text("Tap to add or remove \(objectName) to your custom lists")
    }
    var buttons: [ActionSheet.Button] {
        var buttonList = [ActionSheet.Button]()
        
        // Create list button
        buttonList.append(ActionSheet.Button.default(Text("Create a new list"), action: { self.customListModel.response = CustomListContent(shouldCreateNewList: true, listId: UUID(), itemId: self.objectId, itemType: .TVShow) }))
        
        // Add/ Remove from existing lists buttons
        for list in customLists {
            if list.items[objectId] != nil {
                buttonList.append(ActionSheet.Button.default(Text("Remove \(objectName) from \(list.listName)"), action: {
                    self.customListModel.response = CustomListContent(shouldRemove: true, listName: list.listName, listId: list.id, itemId: self.objectId, itemType: self.itemType)
                    self.showCustomListConfirmation = true
                }))
            } else {
                buttonList.append(ActionSheet.Button.default(Text("Add \(objectName) to \(list.listName)"), action: { self.customListModel.response = CustomListContent(shouldAdd: true, listName: list.listName, listId: list.id, itemId: self.objectId, itemType: self.itemType)
                    self.showCustomListConfirmation = true
                }))
            }
        }
        
        // Cancel button
        buttonList.append(.cancel())
        
        return buttonList
    }
    
    init(customListModel: CustomListModel, showCustomListConfirmation: Binding<Bool>, customLists: [CustomList], objectName: String, objectId: Int, itemType: ItemType) {
        self.customListModel = customListModel
        self._showCustomListConfirmation = showCustomListConfirmation
        self.customLists = customLists
        self.objectName = objectName
        self.objectId = objectId
        self.itemType = itemType
    }
}