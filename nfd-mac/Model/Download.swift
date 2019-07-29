//
//  Download.swift
//  nfd-mac
//
//  Created by Julius Reade on 29/7/19.
//  Copyright © 2019 Julius Reade. All rights reserved.
//


import Foundation

//
// MARK: - Download
//
class Download {
    //
    // MARK: - Variables And Properties
    //
    var isDownloading = false
    var progress: Float = 0
    var resumeData: Data?
    var task: URLSessionDownloadTask?
    var nfdAudio: NFDAudio

    //
    // MARK: - Initialization
    //
    init(nfdAudio: NFDAudio) {
        self.nfdAudio = nfdAudio
    }
}
