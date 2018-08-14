//
//  PostsDataSource.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 14/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import UIKit

class PostsDataSource: NSObject, UITableViewDataSource {
    
    private var data: [Int] = [0, 1, 2]
    
    /// Cell identifier.
    private let cellIdentifier                      = "PostItemCellId"
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // create cell
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        // setup cell
        cell.textLabel?.text = "Item \(data[indexPath.row])"
//        cell.model = WalkerTableViewCell.Model(visitedLocation: visitedLocation)
        
        return cell
    }
    
    
}
