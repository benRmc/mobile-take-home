//
//  EpisodesTableViewController.swift
//  rickandmorty
//
//  Created by 漠川 阮 on 2019-07-11.
//  Copyright © 2019 Mochuan Ruan. All rights reserved.
//

import UIKit

class EpisodesTableViewController: UITableViewController {

    var episodes: [Episode] = []
    
    let queryService = QueryService()
    var loadingIndicator = UIActivityIndicatorView(style: .gray)
    let episodesURL = "https://rickandmortyapi.com/api/episode/"
    var errorInfo: String?
    var nextPage = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 80.0
        tableView.rowHeight = UITableView.automaticDimension
        
        setupLoadingIndicator()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if episodes.isEmpty == true {
            getEpisodes(URL: episodesURL)
        }
    }
    
    func setupLoadingIndicator() {
        loadingIndicator.backgroundColor = .white
        loadingIndicator.hidesWhenStopped = true
        let window = UIApplication.shared.keyWindow
        loadingIndicator.center = window!.center
        window?.addSubview(loadingIndicator)
    }
    
    func getEpisodes(URL: String) {
        
        loadingIndicator.startAnimating()
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        queryService.getEpisodes(episodesURL: URL) { [weak self] results, nextPage,errorMessage in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self?.loadingIndicator.stopAnimating()
            
            if let results = results {
                self?.episodes = results
                self?.nextPage = nextPage
                self?.tableView.reloadData()
            }
            
            if !errorMessage.isEmpty {
                self?.errorInfo = errorMessage
                let alert = UIAlertController.init(title: "Ops, something is wrong!", message: self?.errorInfo, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Try again", comment: "Default action"), style: .default, handler: { _ in
                    self?.getEpisodes(URL: URL)
                }))
                self?.present(alert, animated: true, completion: nil)
                print("Error: " + errorMessage)
            }
        }
        
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.nextPage != "" {
            return episodes.count + 1
        } else {
            return episodes.count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: EpisodeTableViewCell = tableView.dequeueReusableCell(withIdentifier: "EpisodeCell", for: indexPath) as! EpisodeTableViewCell
        if episodes.count > 0 {
            if indexPath.row > 0 && indexPath.row % 20 == 0 && nextPage != "" {
                cell.name.text = "Loading More..."
                cell.episode.text = ""
                cell.date.text = ""
                cell.accessoryType = .none
                tableView.allowsSelection = false
                getEpisodes(URL: nextPage)
            } else {
                let episode = self.episodes[indexPath.row]
                cell.name.text = episode.name
                cell.episode.text = episode.episode
                cell.date.text = episode.date
                cell.accessoryType = .disclosureIndicator
                tableView.allowsSelection = true
            }
        } else {
            cell.name.text = ""
            cell.episode.text = ""
            cell.date.text = ""
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return
            UITableView.automaticDimension
    }
    
    
    // MARK: -Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let episodeDetailViewController = segue.destination as? EpisodeDetailViewController,
            let indexPath = tableView.indexPathForSelectedRow {
            episodeDetailViewController.episode = episodes[indexPath.row]
        }
    }
}
