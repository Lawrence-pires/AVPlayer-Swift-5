//
//  TableController.swift
//  DNBShare.com-IOS
//
//  Created by lawrencepires on 30/03/2021.
//

import Foundation
import AVKit

class TableViewController: NSObject, UITableViewDelegate {
    
    
    
    // #1
    weak var delegate: ViewControllerDelegate?
    
    // #2
    init(withDelegate delegate: ViewControllerDelegate) {
        self.delegate = delegate
    }
    
    // #3
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.selectedCell(row: indexPath.row)
    }
    
    //alternative colour rows
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if(indexPath.row % 2 == 0) {
            cell.backgroundColor = UIColor(cgColor: CGColor(red: 0.19, green: 0.19, blue: 0.17, alpha: 1.0))
        } else {
            cell.backgroundColor =  UIColor(cgColor: CGColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)) }
    }
    

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 60
    }
    
}


class TableViewDataSource: NSObject, UITableViewDataSource {
    
    var data = [[String:String]]()
    
    init(withData data: [[String:String]]) {
        self.data = data
    }
    /*
    // Create a standard header that includes the returned text.
     func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
       return "PlayList"
    }
    */
    
    
    
    

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        
        let selectedView = UIView()
        selectedView.backgroundColor = .systemBlue
        UITableViewCell.appearance().selectedBackgroundView = selectedView
        
        let cell = UITableViewCell()
        cell.textLabel?.textColor = UIColor.lightGray
        cell.textLabel?.font = UIFont.systemFont(ofSize: 25, weight: .semibold)
        cell.textLabel?.text = self.data[indexPath.row]["MusicTitle"]
        
        return cell
    }
    
}
protocol ViewControllerDelegate: class {
    func selectedCell(row: Int)
    func playAudio(url: URL)
}

    
    

