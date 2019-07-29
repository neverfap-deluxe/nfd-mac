//
//  DownloadService.swift
//  nfd-mac
//
//  Created by Julius Reade on 29/7/19.
//  Copyright © 2019 Julius Reade. All rights reserved.
//

import Foundation

class DownloadService: NSObject {
    //
    // MARK: - Variables And Properties
    //
    var activeDownloads: [URL: Download] = [ : ]

    /// SearchViewController creates downloadsSession
    var downloadsSession: URLSession!

    //
    // MARK: - Internal Methods
    //
    func cancelDownload(_ nfdAudio: NFDAudio) {
        guard let download = activeDownloads[nfdAudio.mp3Url] else {
            return
        }
        download.task?.cancel()

        activeDownloads[nfdAudio.mp3Url] = nil
    }

    func pauseDownload(_ nfdAudio: NFDAudio) {
        guard
            let download = activeDownloads[nfdAudio.mp3Url],
            download.isDownloading
            else {
                return
        }

        download.task?.cancel(byProducingResumeData: { data in
            download.resumeData = data
        })

        download.isDownloading = false
    }

    func resumeDownload(_ nfdAudio: NFDAudio) {
        guard let download = activeDownloads[nfdAudio.mp3Url] else {
            return
        }

        if let resumeData = download.resumeData {
            download.task = downloadsSession.downloadTask(withResumeData: resumeData)
        } else {
            download.task = downloadsSession.downloadTask(with: download.nfdAudio.mp3Url)
        }

        download.task?.resume()
        download.isDownloading = true
    }

    func startDownload(_ nfdAudio: NFDAudio) {
        // 1
        let download = Download(nfdAudio: nfdAudio)
        // 2
        download.task = downloadsSession.downloadTask(with: nfdAudio.mp3Url)
        // 3
        download.task?.resume()
        // 4
        download.isDownloading = true
        // 5
        activeDownloads[download.nfdAudio.mp3Url] = download
    }
}
