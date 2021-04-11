//
//  Player.swift
//  DNBShare.com-IOS
//
//  Created by lawrencepires on 25/03/2021.
//

import Foundation
import AVFoundation
import AVKit

var player: AVPlayer! = nil
var artworkImage: UIImage?

class Play: AVPlayer {
    
    var url: URL
    override init(url: URL) {
    self.url = url
        super.init()
        playMusic(url: self.url)
    }
    
 
        
    func playMusic(url : URL) {
       
        let asset = AVAsset(url: url)
       

        
     
            
            let commonMetaData = asset.commonMetadata //this causes delays..
      
        let metaDataItem = AVMetadataItem.metadataItems(from: commonMetaData, filteredByIdentifier: .commonIdentifierArtwork)
          print("whats this? \(metaDataItem)")
            
            if let artworkItem = metaDataItem.first { // need to include a default pic here as not all files contain artwork.
     
            if let imageData = artworkItem.dataValue {
              
                artworkImage = UIImage(data: imageData)!
         
            }
            } else {
                
                artworkImage = UIImage(named: "nometa")
            }
        
       

       // let audioTItle = AVMetadataItem.metadataItems(from: commonMetaData, filteredByIdentifier: .commonIdentifierTitle)
      //  let getTitle = String((audioTItle.first?.stringValue ?? "No-Name"))
      //  print(getTitle)
        
        let playerItem = AVPlayerItem(asset: asset)
       
        if player == nil {
               player = AVPlayer(playerItem: playerItem)
            if player.status.rawValue == 0 {
               player.play()
  
           
                }
                } else {
                player.replaceCurrentItem(with: playerItem)
                player.play()
                }
    }
  

}
