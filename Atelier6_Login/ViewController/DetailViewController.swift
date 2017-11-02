//
//  DetailViewController.swift
//  Atelier3_Navigation_Dynamique
//
//  Created by CedricSoubrie on 01/11/2017.
//  Copyright © 2017 CedricSoubrie. All rights reserved.
//

import UIKit

class DetailViewController: UITableViewController {
    
    var movie: Movie!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 361
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        title = movie.title
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieDetailCell", for: indexPath) as! MovieDetailCell
        cell.fill(with: movie)
        return cell
    }
}
