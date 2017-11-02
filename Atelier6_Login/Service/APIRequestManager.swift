//
//  APIRequestManager.swift
//  KeyboardExample
//
//  Created by Claire Reynaud on 23/10/2017.
//  Copyright © 2017 Claire Reynaud EIRL. All rights reserved.
//

import Foundation
import Alamofire
import KeychainSwift

class APIRequestManager {
    
    private static let API_URL = "https://api.themoviedb.org/3"
    private static let API_KEY = "b692eafd258dae823a2d9ed21dbcdeb5"
    
    private enum ErrorCodes: Int {
        case invalidUsernameOrPassword = -1
        case invalidURLComponents = -2
        case invalidSessionId = -3
    }
    private static let errorDomain = "MovieApp"
    private static let invalidUsernameOrPassword = NSError(domain: errorDomain, code: ErrorCodes.invalidUsernameOrPassword.rawValue, userInfo: [NSLocalizedDescriptionKey: "L'identifiant ou le mot de passe n'est pas valide."])
    private static let invalidSessionId = NSError(domain: errorDomain, code: ErrorCodes.invalidSessionId.rawValue, userInfo: [NSLocalizedDescriptionKey: "Session id non valide."])
    private static let invalidURLComponents = NSError(domain: errorDomain, code: ErrorCodes.invalidURLComponents.rawValue, userInfo: [NSLocalizedDescriptionKey: "URL non valide."])
    
    static func movieList(result: @escaping (MoviesResult?) -> Void) {
        var urlComponents = URLComponents(string: API_URL)
        urlComponents?.path += "/discover/movie"
        urlComponents?.queryItems = [URLQueryItem(name: "api_key", value: API_KEY),
                                     URLQueryItem(name: "sort_by", value: "popularity.desc")]
        
        guard let url = urlComponents?.url else {
            print("Invalid URL: \(String(describing: urlComponents))")
            result(nil)
            return
        }
        
        Alamofire.request(url).responseJSON { response in
            if let _ = response.result.error {
                result(nil)
                return
            }
            
            result(decodeMoviesData(response))
        }
    }
    
    static func watchListMovies(sessionId: String, result: @escaping (MoviesResult?) -> Void) {
        getAccount(sessionId: sessionId) { (accountId, error) in
            if let accountId = accountId {
                var urlComponents = URLComponents(string: API_URL)
                urlComponents?.path += "/account/\(accountId)/watchlist/movies"
                urlComponents?.queryItems = [URLQueryItem(name: "api_key", value: API_KEY),
                                             URLQueryItem(name: "session_id", value: sessionId)]
                
                guard let url = urlComponents?.url else {
                    print("Invalid URL: \(String(describing: urlComponents))")
                    result(nil)
                    return
                }
                
                Alamofire.request(url).responseJSON { response in
                    if let _ = response.result.error {
                        result(nil)
                        return
                    }
                    
                    result(decodeMoviesData(response))
                }
            } else {
                result(nil)
            }
        }
    }
    
    private static func decodeMoviesData(_ response : DataResponse<Any>) -> MoviesResult? {
        if let data = response.data {
            let decoder = JSONDecoder()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            do {
                let moviesResult = try decoder.decode(MoviesResult.self, from: data)
                return moviesResult
            } catch let error {
                print("Cannot decode: error during decode: \(error)")
                return nil
            }
        } else {
            print("Cannot decode: no data")
            return nil
        }
    }
    
    private static func getAccount(sessionId: String, result: @escaping (Int?, Error?) -> Void) {
        var urlComponents = URLComponents(string: API_URL)
        urlComponents?.path += "/account"
        urlComponents?.queryItems = [URLQueryItem(name: "api_key", value: API_KEY),
                                     URLQueryItem(name: "session_id", value: sessionId)]
        
        guard let url = urlComponents?.url else {
            result(nil, invalidURLComponents)
            return
        }
        
        Alamofire.request(url).responseJSON { response in
            if let error = response.error {
                result(nil, error)
                return
            }
            
            if let dictionary = response.result.value as? Dictionary<String, Any>, let accountId = dictionary["id"] as? Int {
                result(accountId, nil)
            } else {
                result(nil, invalidSessionId)
            }
        }
    }
    
    static func isInWatchList(movieId: Int, sessionId: String, result: @escaping (Bool?, Error?) -> Void) {
        var urlComponents = URLComponents(string: API_URL)
        urlComponents?.path += "/movie/\(movieId)/account_states"
        urlComponents?.queryItems = [URLQueryItem(name: "api_key", value: API_KEY),
                                     URLQueryItem(name: "session_id", value: sessionId)]
        
        guard let url = urlComponents?.url else {
            result(nil, invalidURLComponents)
            return
        }
        
        Alamofire.request(url).responseJSON { response in
            if let error = response.error {
                result(nil, error)
                return
            }
            
            if let dictionary = response.result.value as? Dictionary<String, Any>, let watchList = dictionary["watchlist"] as? Bool {
                result(watchList, nil)
            } else {
                result(nil, invalidSessionId)
            }
        }
    }
    
    static func addToWatchList(movieId: Int, sessionId: String, result: @escaping (Error?) -> Void) {
        getAccount(sessionId: sessionId) { (accountId, error) in
            if let accountId = accountId {
                var urlComponents = URLComponents(string: API_URL)
                urlComponents?.path += "/account/\(accountId)/watchlist"
                urlComponents?.queryItems = [URLQueryItem(name: "api_key", value: API_KEY),
                                             URLQueryItem(name: "session_id", value: sessionId)]
                
                guard let url = urlComponents?.url else {
                    result(invalidURLComponents)
                    return
                }
                
                Alamofire.request(url, method: .post, parameters: ["media_type": "movie", "media_id": movieId, "watchlist": true]).responseJSON { response in
                    if let error = response.error {
                        result(error)
                        return
                    }
                    
                    result(nil)
                }
            } else {
                result(invalidSessionId)
            }
        }
    }
    
    static func login(username: String, password: String, result: @escaping (Error?) -> Void) {
        getToken(username: username, password: password, result: result)
    }
    
    private static func getToken(username: String, password: String, result: @escaping (Error?) -> Void) {
        var urlComponents = URLComponents(string: API_URL)
        urlComponents?.path += "/authentication/token/new"
        urlComponents?.queryItems = [URLQueryItem(name: "api_key", value: API_KEY)]
        
        guard let url = urlComponents?.url else {
            result(invalidURLComponents)
            return
        }
        
        Alamofire.request(url).responseJSON { response in
            if let error = response.error {
                result(error)
                return
            }
            
            if let dictionary = response.result.value as? Dictionary<String, Any>, let token = dictionary["request_token"] as? String {
                self.validateToken(token, username: username, password: password, result: result)
            } else {
                result(invalidUsernameOrPassword)
            }
        }
    }
    
    private static func validateToken(_ token: String, username: String, password: String, result: @escaping (Error?) -> Void) {
        var urlComponents = URLComponents(string: API_URL)
        urlComponents?.path += "/authentication/token/validate_with_login"
        urlComponents?.queryItems = [URLQueryItem(name: "api_key", value: API_KEY),
                                     URLQueryItem(name: "username", value: username),
                                     URLQueryItem(name: "password", value: password),
                                     URLQueryItem(name: "request_token", value: token)]
        
        guard let url = urlComponents?.url else {
            result(invalidURLComponents)
            return
        }
        
        Alamofire.request(url).responseJSON { response in
            if let error = response.error {
                result(error)
                return
            }
            
            self.getSession(token, username: username, password: password, result: result)
        }
    }
    
    private static func getSession(_ token: String, username: String, password: String, result: @escaping (Error?) -> Void) {
        var urlComponents = URLComponents(string: API_URL)
        urlComponents?.path += "/authentication/session/new"
        urlComponents?.queryItems = [URLQueryItem(name: "api_key", value: API_KEY),
                                     URLQueryItem(name: "request_token", value: token)]
        
        guard let url = urlComponents?.url else {
            result(invalidURLComponents)
            return
        }
        
        Alamofire.request(url).responseJSON { response in
            if let error = response.error {
                result(error)
                return
            }
            
            if let dictionary = response.result.value as? Dictionary<String, Any>, let session_id = dictionary["session_id"] as? String {
                print("Session id: \(session_id)")
                UserAccount.save(username: username, password: password, sessionId: session_id)
                result(nil)
            } else {
                result(invalidUsernameOrPassword)
            }
        }
    }
}
