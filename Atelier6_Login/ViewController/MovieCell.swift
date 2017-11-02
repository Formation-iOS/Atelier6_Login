//
//  MovieCell.swift
//  Atelier3_Navigation_Dynamique
//
//  Created by CedricSoubrie on 01/11/2017.
//  Copyright © 2017 CedricSoubrie. All rights reserved.
//

import UIKit
import AlamofireImage

class MovieCell: UITableViewCell {

    @IBOutlet weak var customImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
    func fill(with movie: Movie) {
        print ("Fill cell with \(movie)")
        customImageView.image = nil
        if let url = URL(string: movie.fullPosterURLString()) {
            customImageView.af_setImage(withURL: url)
        }
        titleLabel.text = movie.title
        descriptionLabel.text = movie.overview
        ratingLabel.text = String(format: "Note : %.1f/10", movie.vote_average)
    }
}
