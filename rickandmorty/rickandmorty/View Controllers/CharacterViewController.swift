//
//  CharacterViewController.swift
//  rickandmorty
//
//  Created by 漠川 阮 on 2019-07-13.
//  Copyright © 2019 Mochuan Ruan. All rights reserved.
//

import UIKit

class CharacterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var characterImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var loadingIndicator = UIActivityIndicatorView(style: .gray)
    
    var character: RMCharacter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableView.automaticDimension
        
        title = character?.name
        characterImage.image = character?.imageWorker.image
        if character?.imageWorker.state == .new {
            setupLoadingIndicator()
            downloadImage()
            loadingIndicator.stopAnimating()
        } else {
            characterImage.image = character?.imageWorker.image
        }
        // Do any additional setup after loading the view.
    }
    
    func setupLoadingIndicator() {
        loadingIndicator.backgroundColor = .white
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.center = characterImage.center
        characterImage.addSubview(loadingIndicator)
    }
    
    func downloadImage() {
        loadingIndicator.startAnimating()
        guard let character = character else { return }
        
        guard let photoURL = URL(string: character.imageWorker.url) else {
            characterImage.image = UIImage(named: "Failed")
            return
        }
        guard let imageData = try? Data(contentsOf: photoURL) else { return }
        if !imageData.isEmpty {
            characterImage.image = UIImage(data: imageData)
            character.imageWorker.image = UIImage(data:imageData)
            character.imageWorker.state = .downloaded
        } else {
            characterImage.image = UIImage(named: "Failed")
        }
    }
    
    //MARK: - table view delegate and data source methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CharacterDetailCell = tableView.dequeueReusableCell(withIdentifier: "CharacterDetailCell") as! CharacterDetailCell
        switch indexPath.row {
        case 0:
            cell.name.text = "Name:"
            cell.detail.text = character?.name
        case 1:
            cell.name.text = "Status:"
            cell.detail.text = character?.status
            cell.detail.textColor = character?.status == "Alive" ? .black : .red
        case 2:
            cell.name.text = "Species:"
            cell.detail.text = character?.species
        case 3:
            cell.name.text = "Gender:"
            cell.detail.text = character?.gender
        case 4:
            cell.name.text = "Origin:"
            cell.detail.text = character?.origin
        case 5:
            cell.name.text = "Location:"
            cell.detail.text = character?.location
        default:
            return cell
        }
        
        return cell
    }

}
