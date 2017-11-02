//
//  MovieDetailCell.swift
//  Films
//
//  Created by Claire Reynaud on 13/10/2017.
//  Copyright © 2017 Claire Reynaud EIRL. All rights reserved.
//

import UIKit
import AlamofireImage
import MBProgressHUD

class MovieDetailCell: UITableViewCell {
    
    @IBOutlet weak var customImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var addToWatchListButton: UIButton!
    @IBOutlet weak var inWatchListLabel: UILabel!
    
    var movie: Movie?
    
    func fill(with movie: Movie) {
        self.movie = movie
        print ("Fill detail cell with \(movie)")
        
        customImageView.image = nil
        if let url = URL(string: movie.fullBackdropURLString()) {
            customImageView.af_setImage(withURL: url)
        }
        titleLabel.text = movie.title
        descriptionLabel.text = movie.overview
        ratingLabel.text = String(format: "Note : %.1f/10", movie.vote_average)
        
        addToWatchListButton.isHidden = movie.watchlist ?? false
        inWatchListLabel.isHidden = !(addToWatchListButton.isHidden)
    }
    
    @IBAction func addToWatchList(_ sender: Any) {
        guard let sessionId = UserAccount.getSessionId(), let movie = movie else {
            return
        }
        
        let hud = MBProgressHUD.showAdded(to: contentView, animated: true)
        APIRequestManager.addToWatchList(movieId: movie.id, sessionId: sessionId) { (error) in
            self.movie?.watchlist = true
            self.addToWatchListButton.isHidden = true
            self.inWatchListLabel.isHidden = false
            hud.hide(animated: true)
        }
    }
}
