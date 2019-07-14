//
//  QueryService.swift
//  rickandmorty
//
//  Created by 漠川 阮 on 2019-07-11.
//  Copyright © 2019 Mochuan Ruan. All rights reserved.
//

import Foundation

class QueryService {
    
    let defaultSession = URLSession(configuration: .default)
    
    var dataTask: URLSessionDataTask?
    var errorMessage = ""
    var episodes: [Episode] = []
    var characters: [RMCharacter] = []
    
    var nextPage: String?
    
    typealias JSONDictionary = [String: Any]
    typealias EpisodeQueryResult = ([Episode]?, String, String) -> Void
    typealias CharacterQueryResult = ([RMCharacter]?, String) -> Void
    
    func getEpisodes(episodesURL: String, completion: @escaping EpisodeQueryResult) {
        guard let url = URL(string: episodesURL) else {
            return
        }
        
        dataTask = defaultSession.dataTask(with: url) { [weak self] data, response, error in
            defer {
                self?.dataTask = nil
            }
            
            if let error = error {
                self?.errorMessage = "DataTask error: " + error.localizedDescription + "\n"
                DispatchQueue.main.async {
                    completion(self?.episodes, self?.nextPage ?? "", self?.errorMessage ?? "")
                }
            } else if
                let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                
                    self?.updateEpisodes(data)
                
                    DispatchQueue.main.async {
                        completion(self?.episodes, self?.nextPage ?? "", self?.errorMessage ?? "")
                    }
                }
        }
        
        dataTask?.resume()
    }
    
    func getCharacters(charactersURL: String, completion: @escaping CharacterQueryResult) {
        guard let url = URL(string: charactersURL) else {
            return
        }
        
        dataTask = defaultSession.dataTask(with: url) { [weak self] data, response, error in
            defer {
                self?.dataTask = nil
            }
            
            if let error = error {
                self?.errorMessage = "DataTask error: " + error.localizedDescription + "\n"
                DispatchQueue.main.async {
                    completion(self?.characters, self?.errorMessage ?? "")
                }
            } else if
                let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                
                self?.updateCharacters(data)
                
                DispatchQueue.main.async {
                    completion(self?.characters, self?.errorMessage ?? "")
                }
            }
        }
        
        dataTask?.resume()
    }
    
    func updateEpisodes(_ data: Data) {
        var response: JSONDictionary?
        
        do {
            response = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
        } catch let parseError as NSError {
            errorMessage += "JSONSerialization error: \(parseError.localizedDescription)\n"
            return
        }
        
        guard let resultsArray = response!["results"] as? [Any] else {
            errorMessage += "Response does not contain results key\n"
            return
        }
        
        guard let infoArray = response!["info"] as? [String : Any] else {
            errorMessage += "Response does not contain info key\n"
            return
        }
        
        for episode in resultsArray {
            if let episode = episode as? JSONDictionary,
                let name = episode["name"] as? String,
                let episodeCode = episode["episode"] as? String,
                let date = episode["air_date"] as? String,
                let characters = episode["characters"] as? [String] {
                
                var charactersString: String = ""
                var count = 0
                for characterURL in characters {
                    if let index = characterURL.split(separator: "/").last {
                        charactersString.append(String(index))
                        if count <= characters.count - 2 {
                            charactersString.append(",")
                            count += 1
                        }
                    }
                }
                
                episodes.append(Episode(name: name, episode: episodeCode, date: date, characters: charactersString))
            }
        }
        
        
        if let next = infoArray["next"] as? String {
            nextPage = next
        }
    }
    
    func updateCharacters(_ data: Data) {
        var response: [Any]?
        
        do {
            response = try JSONSerialization.jsonObject(with: data, options: []) as? [Any]
        } catch let parseError as NSError {
            errorMessage += "JSONSerialization error: \(parseError.localizedDescription)\n"
            return
        }
        
        guard let charactersResponse = response else {
            errorMessage += "no response"
            return
        }
        for character in charactersResponse {
            guard let character = character as? [String : Any] else {
                return
            }
            
            if let name = character["name"] as? String,
                let status = character["status"] as? String,
                let species = character["species"] as? String,
                let gender = character["gender"] as? String,
                let imageURL = character["image"] as? String,
                let originDic = character["origin"] as? [String : Any],
                let origin = originDic["name"] as? String,
                let locationDic = character["location"] as? [String : Any],
                let location = locationDic["name"] as? String {
                
                let rmcharacter = RMCharacter(name: name, species: species, status: status, gender: gender, origin: origin, location: location, imageURL: imageURL)
                
                characters.append(rmcharacter)
            }
        }
    }
    
}
