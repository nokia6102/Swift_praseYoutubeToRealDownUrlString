//
//  SSYoutubeParser.swift
//  SSYoutubeParser
//
//  Created by leznupar999 on 2015/06/03.
//  Copyright (c) 2015 leznupar999. All rights reserved.
//

import Foundation

class SSYoutubeParser: NSObject {
   
    static let kYoutubeURL:String = "https://www.youtube.com/watch?v="
    static let kYoutubeVideoInfoURL:NSString = "https://www.youtube.com/get_video_info?video_id=%@&asv=3&el=detailpage&ps=default&hl=en_US"
    static let kURLEncodedFmtStreamMap:String = "(url_encoded_fmt_stream_map=)(.*?)(&)"
    static let kAdaptiveFmts:String = "(adaptive_fmts=)(.*?)(&)"

    
    class func h264videosWithYoutubeID(_ youtubeID :String, completionHandler handler:@escaping (_ videoDictionary :[String:String]) -> Void) {
        
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: { () -> Void in
            let videoDictionary = self.getStreams(youtubeID)
            
            DispatchQueue.main.async(execute: { () -> Void in
                handler(videoDictionary)
            })
        })
    }
    
    fileprivate class func getStreams(_ youtubeID :String) -> [String:String] {
        var videoDictionary = [String:String]()
        
        let urlStr = NSString(format: kYoutubeVideoInfoURL, youtubeID)
        let url = URL(string: urlStr as String)
        let req = NSMutableURLRequest(url: url!)
        req.addValue("en", forHTTPHeaderField: "Accept-Language")
        
        var uRLResponse : URLResponse?
        let data:Data = try! NSURLConnection.sendSynchronousRequest(req as URLRequest, returning: &uRLResponse)
        if data.count == 0 {
            return videoDictionary
        }
        let html = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        
        var regex: NSRegularExpression?
        regex = try! NSRegularExpression(pattern: kURLEncodedFmtStreamMap, options: NSRegularExpression.Options())
        
        if regex == nil {
            return videoDictionary
        }
        
        if let result = regex?.firstMatch(in: html as String!, options: NSRegularExpression.MatchingOptions(), range: NSMakeRange(0, html!.length)) {
            
            if let streamMap :NSString = html?.substring(with: result.rangeAt(2)) as! NSString {
                
                let decodeMap :NSString = streamMap.removingPercentEncoding! as NSString
                print(decodeMap)
                
                let fmtStreamMapArray = decodeMap.components(separatedBy: ",") 
                
                for stream in fmtStreamMapArray {
                    let videoComponents = self.dictionaryFromQueryStringComponents(stream as NSString)
                    let typeArray = videoComponents["type"]
                    var typeStr = typeArray?.object(at: 0) as! NSString
                    typeStr = self.stringByDecodingURLFormat(typeStr)
                    
                    var signature :NSString?
                    
                    if let itag = videoComponents["itag"] {
                        signature = itag.object(at: 0) as? NSString
                    }
                    
                    if signature != nil && typeStr.range(of: "mp4").length > 0 {
                        let urlArr = videoComponents["url"]
                        var streamUrl = urlArr?.object(at: 0) as! NSString
                        streamUrl = self.stringByDecodingURLFormat(streamUrl)
                        streamUrl = NSString(format: "%@&signature=%@", streamUrl, signature!)
                        
                        let qualityArr = videoComponents["quality"]
                        var quality = qualityArr?.object(at: 0) as! NSString
                        quality = self.stringByDecodingURLFormat(quality)
                        
                        if let stereo3d = videoComponents["stereo3d"],let bl = stereo3d.object(at: 0) as? NSString {
                            if bl.boolValue {
                                quality = quality.appending("-stereo3d") as NSString
                            }
                        }
                        
                        if videoDictionary[quality as String] == nil {
                            videoDictionary[quality as String] = streamUrl as String
                        }
                    }
                }
            }
        }
        
        return videoDictionary
    }

    fileprivate class func stringByDecodingURLFormat(_ value :NSString) -> NSString {
        var result :NSString = value.replacingOccurrences(of: "+", with: " ") as NSString
        result = result.replacingPercentEscapes(using: String.Encoding.utf8.rawValue)! as NSString
        return result
    }
    
    fileprivate class func dictionaryFromQueryStringComponents(_ stream :NSString) -> [String:NSMutableArray] {
        var parameters = [String:NSMutableArray]()
        
        for keyValue in stream.components(separatedBy: "&") {
            let keyValueStr = keyValue as NSString
            let keyValueArray:[Any] = keyValueStr.components(separatedBy: "=")
            if keyValueArray.count < 2 {
                continue
            }
            
            let key = self.stringByDecodingURLFormat(keyValueArray[0] as! NSString)
            let value = self.stringByDecodingURLFormat(keyValueArray[1] as! NSString)
            
            var results = parameters[key as String]
            
            if results == nil {
                results = NSMutableArray(capacity: 1)
                parameters[key as String] = results
            }
            
            results?.add(value)
            
        }
        return parameters
    }
}
