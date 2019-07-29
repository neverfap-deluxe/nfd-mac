//
//  NFDText.swift
//  nfd-mac
//
//  Created by Julius Reade on 29/7/19.
//  Copyright © 2019 Julius Reade. All rights reserved.
//

import Cocoa

import Foundation.NSURL

//
// MARK: - Track
//

/// Query service creates Track objects
class NFDText {
    //
    // MARK: - Constants
    //
    
    let title: String
    let date: String
    let content: String
    let type: String
    
    //
    // MARK: - Variables And Properties
    //
    var downloaded = false
    
    //
    // MARK: - Initialization
    //
    init(title: String, date: String, content: String, type: String) {
        self.title = title
        self.date = date
        self.content = content
        self.type = type
    }
}
