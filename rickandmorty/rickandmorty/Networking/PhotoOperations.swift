//
//  PhotoOperations.swift
//  rickandmorty
//
//  Created by 漠川 阮 on 2019-07-13.
//  Copyright © 2019 Mochuan Ruan. All rights reserved.
//

import Foundation
import UIKit

enum PhotoRecordState {
    case new, downloaded, failed
}

class PhotoRecord {
    let url: String
    var state = PhotoRecordState.new
    var image = UIImage(named: "Placeholder")
    
    init(url: String) {
        self.url = url
    }
}

class DownloadOperations {
    lazy var downloadsInProgress: [IndexPath: Operation] = [:]
    lazy var downloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Download queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
}

class ImageDownloader: Operation {
    let photoRecord: PhotoRecord
    
    init(_ photoRecord: PhotoRecord) {
        self.photoRecord = photoRecord
    }
    
    override func main() {
        if isCancelled {
            return
        }
        
        guard let photoURL = URL(string: photoRecord.url) else {
            photoRecord.image = UIImage(named: "Failed")
            return
        }
        guard let imageData = try? Data(contentsOf: photoURL) else { return }
        
        if isCancelled {
            return
        }
        
        if !imageData.isEmpty {
            photoRecord.image = UIImage(data:imageData)
            photoRecord.state = .downloaded
        } else {
            photoRecord.state = .failed
            photoRecord.image = UIImage(named: "Failed")
        }
    }
}
