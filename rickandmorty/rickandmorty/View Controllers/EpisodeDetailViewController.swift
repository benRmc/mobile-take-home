//
//  EpisodeDetailViewController.swift
//  rickandmorty
//
//  Created by 漠川 阮 on 2019-07-13.
//  Copyright © 2019 Mochuan Ruan. All rights reserved.
//

import UIKit

class EpisodeDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var episodeName: UILabel!
    @IBOutlet weak var episodeDate: UILabel!
    @IBOutlet weak var episodeCode: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var episode: Episode?
    var charactersString: String = ""
    var characters: [RMCharacter] = []
    
    let queryService = QueryService()
    let imageDownloadOperations = DownloadOperations()
    var loadingIndicator = UIActivityIndicatorView(style: .gray)
    let characterBaseUrl = "https://rickandmortyapi.com/api/character/"
    var errorInfo: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Characters"
        // Do any additional setup after loading the view.
        if let episode = episode {
            episodeName.text = episode.name
            episodeCode.text = episode.episode
            episodeDate.text = episode.date
            charactersString = episode.characters
        }
        
        setupLoadingIndicator()
        if self.characters.count == 0 {
            getCharacters()
        }
    }
    
    func setupLoadingIndicator() {
        loadingIndicator.backgroundColor = .white
        loadingIndicator.hidesWhenStopped = true
        let window = UIApplication.shared.keyWindow
        loadingIndicator.center = window!.center
        window?.addSubview(loadingIndicator)
    }
    
    func getCharacters() {
        loadingIndicator.startAnimating()
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        queryService.getCharacters(charactersURL: characterBaseUrl+charactersString) { [weak self] results, errorMessage in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self?.loadingIndicator.stopAnimating()
            
            if let results = results {
                self?.characters = results
                self?.tableView.reloadData()
            }
            
            if !errorMessage.isEmpty {
                self?.errorInfo = errorMessage
                let alert = UIAlertController.init(title: "Ops, something is wrong!", message: self?.errorInfo, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Try again", comment: "Default action"), style: .default, handler: { _ in
                    self?.getCharacters()
                }))
                self?.present(alert, animated: true, completion: nil)
                print("Error: " + errorMessage)
            }
        }
    }
    

    // MARK: - tableview delegate methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return characters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CharacterTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CharacterCell") as! CharacterTableViewCell
        
        let character = characters[indexPath.row]
        cell.name.text = character.name
        cell.gender.text = character.gender
        cell.species.text = character.species
        cell.status.text = character.status
        cell.status.textColor = character.status != "Alive" ? .red : .black
        
        let indicator = UIActivityIndicatorView(style: .gray)
        indicator.backgroundColor = .white
        indicator.hidesWhenStopped = true
        indicator.center = cell.picture.center
        cell.picture.image = character.imageWorker.image
        cell.picture.addSubview(indicator)
        
        switch character.imageWorker.state {
        case .failed, .downloaded:
            indicator.stopAnimating()
        case .new:
            indicator.startAnimating()
            if !tableView.isDragging && !tableView.isDecelerating {
                startDownload(for: character.imageWorker, at: indexPath)
            }
        }
        
        return cell
    }
    
    
    // MARK: - scrollview delegate methods
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        suspendAllOperations()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            loadImagesForOnscreenCells()
            resumeAllOperations()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        loadImagesForOnscreenCells()
        resumeAllOperations()
    }
    
    
    // MARK: - operation management
    func suspendAllOperations() {
        imageDownloadOperations.downloadQueue.isSuspended = true
    }
    
    func resumeAllOperations() {
        imageDownloadOperations.downloadQueue.isSuspended = false
    }
    
    func loadImagesForOnscreenCells() {
        if let pathsArray = tableView.indexPathsForVisibleRows {
            let allPendingOperations = Set(imageDownloadOperations.downloadsInProgress.keys)

            var toBeCancelled = allPendingOperations
            let visiblePaths = Set(pathsArray)
            toBeCancelled.subtract(visiblePaths)
            
            var toBeStarted = visiblePaths
            toBeStarted.subtract(allPendingOperations)
            
            for indexPath in toBeCancelled {
                if let pendingDownload = imageDownloadOperations.downloadsInProgress[indexPath] {
                    pendingDownload.cancel()
                }
                
                imageDownloadOperations.downloadsInProgress.removeValue(forKey: indexPath)
            }
            
            for indexPath in toBeStarted {
                let characterToDownloadImage = characters[indexPath.row]
                startDownload(for: characterToDownloadImage.imageWorker, at: indexPath)
            }
        }
    }
    
    func startDownload(for photoRecord: PhotoRecord, at indexPath: IndexPath) {
        guard imageDownloadOperations.downloadsInProgress[indexPath] == nil && photoRecord.state == .new else {
            return
        }
        
        let downloader = ImageDownloader(photoRecord)
        downloader.completionBlock = {
            if downloader.isCancelled {
                return
            }
            
            DispatchQueue.main.async {
                self.imageDownloadOperations.downloadsInProgress.removeValue(forKey: indexPath)
                self.tableView.reloadRows(at: [indexPath], with: .none)
            }
        }
        imageDownloadOperations.downloadsInProgress[indexPath] = downloader
        imageDownloadOperations.downloadQueue.addOperation(downloader)
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let characterDetailViewController = segue.destination as? CharacterViewController,
            let indexPath = tableView.indexPathForSelectedRow {
            characterDetailViewController.character = characters[indexPath.row]
        }
    }

}
