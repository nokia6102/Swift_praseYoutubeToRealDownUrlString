//
//  ViewController.swift
//  SSYoutubeParser
//
//  Created by leznupar999 on 2015/06/03.
//  Copyright (c) 2015 leznupar999. All rights reserved.
//

import UIKit
import AVFoundation
import UIKit
//import SSYoutubeParser

class ViewController: UIViewController {
    
    @IBOutlet weak var avPlayerView: AVPlayerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    //    self.setupVideo()
      
       SSYoutubeParser.h264videosWithYoutubeID("yYIBb81ocvg") { (videoDictionary) -> Void in
        let videoMediumURL = videoDictionary["medium"]
        //let videoHD720URL = videoDictionary["hd720"]
        
        if let urlStr = videoMediumURL {
            print (">url:\(urlStr)")
          }
        }
       }
  }
    
//     as URL as URL
//    func setupVideo() {
//        SSYoutubeParser.h264videosWithYoutubeID("yYIBb81ocvg") { (videoDictionary) -> Void in
//            //let videoSmallURL = videoDictionary["small"]
//            let vd = videoDictionary["medium"]
//            //let videoHD720URL = videoDictionary["hd720"]
//            let urlS = vd.forKeyPath(url) as? String
//            print ("> dic: \(urlS))")
////            if let urlStr = videoMediumURL {
////                if let playerItem:AVPlayerItem = AVPlayerItem(url: NSURL(string: urlStr)! as URL) {
////                    self.avPlayerView.player = AVPlayer(playerItem: playerItem)
////                    playerItem.addObserver(self, forKeyPath: "status", options: [.new,.old,.initial], context: nil)
////                }
////            }
//        }
    
    
//    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutableRawPointer) {
//        if keyPath == "status" {
//            let change2 = change!
//            let changeOld = change2["old"] as? NSNumber
//            let changeNew = change2["new"] as? NSNumber
//            let status = object!.status as AVPlayerItemStatus
//            
//            if changeOld == 0 && changeNew == 1 && status == AVPlayerItemStatus.readyToPlay {
//                self.avPlayerView.player.play()
//            }
//        } else {
//          //  super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
//        }
//    }



