//
//  ViewController.swift
//  Atelier3_Navigation_Dynamique
//
//  Created by CedricSoubrie on 01/11/2017.
//  Copyright © 2017 CedricSoubrie. All rights reserved.
//

import UIKit
import MBProgressHUD

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var movieArray = [Movie]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        
        APIRequestManager.movieList { moviesResult in
            if let moviesResult = moviesResult {
                self.movieArray = moviesResult.results
                self.tableView.reloadData()
                hud.hide(animated: true)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if UserAccount.getSessionId() == nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
            present(loginVC, animated: false, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MovieCell
        if let movie = self.movie(at:indexPath) {
            cell.fill(with:movie)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let sessionId = UserAccount.getSessionId(), let movie = self.movie(at: indexPath) {
            let hud = MBProgressHUD.showAdded(to: view, animated: true)
            
            APIRequestManager.isInWatchList(movieId: movie.id, sessionId: sessionId, result: { (watchlist, error) in
                movie.watchlist = watchlist
                hud.hide(animated: true)
                self.showDetailForMovie(movie)
            })
        }
    }
    
    func showDetailForMovie(_ movie: Movie) {
        let detailVC = self.storyboard?.instantiateViewController(withIdentifier:"DetailViewController") as! DetailViewController
        detailVC.movie = movie
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func movie(at indexPath:IndexPath) -> Movie? {
        let row = indexPath.row
        if row >= 0 && movieArray.count > row {
            return movieArray[row]
        }
        return nil
    }
}

