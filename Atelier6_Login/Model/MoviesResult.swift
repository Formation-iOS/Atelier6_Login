//
//  MoviesResult.swift
//  Films
//
//  Created by Claire Reynaud on 14/10/2017.
//  Copyright © 2017 Claire Reynaud EIRL. All rights reserved.
//

import Foundation
import Alamofire

class MoviesResult: NSObject, Codable {
    var results = [Movie]()
}
