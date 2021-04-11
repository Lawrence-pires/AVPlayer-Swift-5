//
//  CreateLink.swift
//  DNBShare.com-IOS
//
//  Created by lawrencepires on 01/04/2021.
//

import Foundation
import AVKit


class CreateLink: NSObject {
    
    
    // #1
    weak var delegate: ViewControllerDelegate?
    // #2
    init(withDelegate delegate: ViewControllerDelegate) {
        self.delegate = delegate
    }
    
    func createLinkAndPlay(url: URL) {
     //passing row which is the table row selected to this func which then passes exacrly the same row back to audioPlay on viewcontroller

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
        
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                fatalError("Error: invalid HTTP response code")
            }
            guard let data = data else {
                fatalError("Error: missing response data")
            }
        
            let returnedContent = String(data: data, encoding: .utf8)!
            var array =  returnedContent.components(separatedBy: " ")
            var valueArray = array.filter( { $0.range(of: "value", options: .caseInsensitive) != nil })
            array.removeAll()
            
            var createLinkToPlay: [String] = []
            
            for item in valueArray {
                
                
                let findValueReplace = item.replacingOccurrences(of: "value=\"", with: "", options: NSString.CompareOptions.literal, range: nil)
                let removeBackslash = findValueReplace.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil)
                
                
                createLinkToPlay.append(removeBackslash)
            }
            let urlString = URL(string: "\(url)?file=\(createLinkToPlay[0])&payload=\(createLinkToPlay[1])&play=1")
            valueArray.removeAll(); createLinkToPlay.removeAll()
            self.delegate?.playAudio(url: urlString!)
           
            }
            task.resume()
        
        
        
    }
    
   
}

    
    


extension String {
    public var withoutHtml: String {
        guard let data = self.data(using: .utf8) else {
            return self
        }

        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]

        guard let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
            return self
        }

        return attributedString.string
    }
    

}

extension String {
    func titlecased() -> String {
        if self.count <= 1 {
            return self.uppercased()
        }
        
        let regex = try! NSRegularExpression(pattern: "(?=\\S)[A-Z]", options: [])
        let range = NSMakeRange(1, self.count - 1)
        var titlecased = regex.stringByReplacingMatches(in: self, range: range, withTemplate: " $0")
        
        for i in titlecased.indices {
            if i == titlecased.startIndex || titlecased[titlecased.index(before: i)] == " " {
                titlecased.replaceSubrange(i...i, with: String(titlecased[i]).uppercased())
            }
        }
        return titlecased
    }
}


