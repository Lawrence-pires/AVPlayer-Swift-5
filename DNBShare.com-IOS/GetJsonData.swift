//
//  GetJsonData.swift
//  DNBShare.com-IOS
//
//  Created by lawrencepires on 31/03/2021.
//

import Foundation
import Combine
import AVKit

var dataCompleteDictionaory = [[String:String]]()

class GetJsonData: NSObject {

    struct Post: Decodable {
        let MusicTitle: String
        let Link: String
    }
    
    
    
    func getJSONAndDecode(completionBlock: @escaping(String?) -> Void)  {
   
        let url = URL(string: "https://api.jsonbin.io/b/60649f3f418f307e258623b1")!
 

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                fatalError("Error: invalid HTTP response code")
            }
            guard let data = data else {
                fatalError("Error: missing response data")
            }

            do {
                let decoder = JSONDecoder()
                let posts = try decoder.decode([Post].self, from: data)
                let link: [String] = posts.map { $0.Link }
                let title: [String] = posts.map { $0.MusicTitle.capitalized }
            
                
                for n in 0...49 {
                 dataCompleteDictionaory.append(["MusicTitle": title[n], "Link": link[n]])
            
                }
                
                completionBlock("Complete")
                
            }
            catch {
                print("Error: \(error.localizedDescription)")
            }
            
        }
        task.resume()
    }
    
   
}
