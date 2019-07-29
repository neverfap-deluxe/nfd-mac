//
//  ContentAPIService.swift
//  nfd-mac
//
//  Created by Julius Reade on 29/7/19.
//  Copyright © 2019 Julius Reade. All rights reserved.
//

import Foundation

class ContentAPIService {
    //
    // MARK: - Constants
    //
    let defaultSession = URLSession(configuration: .default)

    //
    // MARK: - Variables And Properties
    //
    var dataTask: URLSessionDataTask?
    var errorMessage = ""
    var nfdArticles: [NFDText] = []
    var nfdPractices: [NFDText] = []
    var nfdMeditations: [NFDAudio] = []
    var nfdPodcasts: [NFDAudio] = []

    //
    // MARK: - Type Alias
    //
    typealias JSONDictionary = [String: Any]
    typealias QueryResult = ([NFDText]?, String) -> Void

    //
    // MARK: - Internal Methods
    //

    private func getRelevantUrlByType(type: String) -> String {
        switch type {
        case "article":
            return "https://neverfapdeluxe.netlify.com/content_articles/index.json"
        case "practice":
            return "https://neverfapdeluxe.netlify.com/content_practices/index.json"
        case "meditation":
            return "https://neverfapdeluxe.netlify.com/content_meditations/index.json"
        case "podcast":
            return "https://neverfapdeluxe.netlify.com/content_podcast/index.json"
        default:
            return "WOAH!"
        }
    }

    func getSearchResults(searchTerm: String, completion: @escaping QueryResult, type: String) {
        // 1
        dataTask?.cancel()

        // NOTE: This will have
        // 2
        if var urlComponents = URLComponents(string: getRelevantUrlByType(type: type)) {

            // 3
            guard let url = urlComponents.url else {
                return
            }

            // 4
            dataTask = defaultSession.dataTask(with: url) { [weak self] data, response, error in
                defer {
                    self?.dataTask = nil
                }

                // 5
                if let error = error {
                    self?.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
                } else if
                    let data = data,
                    let response = response as? HTTPURLResponse,
                    response.statusCode == 200 {

                    self?.updateResults(data: data, type: type)

                    // 6
                    DispatchQueue.main.async {
                        completion(self?.nfdArticles, self?.errorMessage ?? "")
                    }
                }
            }

            // 7
            dataTask?.resume()
        }
    }

    //
    // MARK: - Private Methods
    //
    private func updateResults(_ data: Data, type: String) {
        var response: JSONDictionary?
        // nfdArticles.removeAll()

        do {
            response = try JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary
        } catch let parseError as NSError {
            errorMessage += "JSONSerialization error: \(parseError.localizedDescription)\n"
            return
        }

        guard let array = response!["results"] as? [Any] else {
            errorMessage += "Dictionary does not contain results key\n"
            return
        }

        switch(type) {
            case "article",
                 "practice":
                updateTextResults(array: array, type: type)
            case "meditation",
                 "podcast":
                updateAudioResults(array: array, type: type)
            default:
                updateTextResults(array: array, type: type)
        }
    }

    private func updateTextResults(array: [Any], type: String) {
        var index = 0

        for nfdTextDictionary in array {
            if let nfdTextDictionary = nfdTextDictionary as? JSONDictionary,
                let title = nfdTextDictionary["title"] as? String,
                let date = nfdTextDictionary["date"] as? String,
                let content = nfdTextDictionary["content"] as? String {
                    switch type {
                        case "article":
                            nfdArticles.append(NFDText(title: title, date: date, content: content, type: type))
                        case "practice":
                            nfdPractices.append(NFDText(title: title, date: date, content: content, type: type))
                        default:
                            "WOAH!"
                    }
                index += 1
            } else {
                errorMessage += "Problem parsing nfdTextDictionary\n"
            }
        }
    }

    private func updateAudioResults(array: [Any], type: String) {
        var index = 0

        for nfdAudioDictionary in array {
            if let nfdAudioDictionary = nfdAudioDictionary as? JSONDictionary,
                let previewURLString = nfdAudioDictionary["mp3Url"] as? String,
                let previewURL = URL(string: previewURLString),
                let title = nfdAudioDictionary["title"] as? String,
                let date = nfdAudioDictionary["date"] as? String,
                let content = nfdAudioDictionary["content"] as? String {
                    switch type {
                        case "article":
                            nfdMeditations.append(NFDAudio(title: title, date: date, content: content, type: type, mp3Url: mp3Url))

                        case "practice":
                            nfdPodcasts.append(NFDAudio(title: title, date: date, content: content, type: type, mp3Url: mp3Url))

                        default:
                            "WOAH!"
                    }
                index += 1
            } else {
                errorMessage += "Problem parsing nfdAudioDictionary\n"
            }
        }
    }


}
