//
//  rmCharacter.swift
//  rickandmorty
//
//  Created by 漠川 阮 on 2019-07-13.
//  Copyright © 2019 Mochuan Ruan. All rights reserved.
//

import Foundation
import UIKit

class RMCharacter {
    
    let name: String
    let species: String
    let status: String
    let gender: String
    let origin: String
    let location: String
    let imageWorker: PhotoRecord
    
    
    init(name: String, species: String, status: String, gender: String, origin: String, location: String, imageURL: String) {
        self.name = name
        self.species = species
        self.status = status
        self.gender = gender
        self.origin = origin
        self.location = location
        self.imageWorker = PhotoRecord(url: imageURL)
    }
    
}
