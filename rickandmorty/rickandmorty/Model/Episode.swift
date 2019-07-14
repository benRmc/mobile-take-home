//
//  Episode.swift
//  rickandmorty
//
//  Created by 漠川 阮 on 2019-07-11.
//  Copyright © 2019 Mochuan Ruan. All rights reserved.
//

import Foundation

class Episode {
    
    let name: String
    let episode: String
    let date: String
    
    let characters: String
    
    init(name: String, episode: String, date: String, characters: String) {
        self.name = name
        self.episode = episode
        self.date = date
        self.characters = characters
    }
    
}
