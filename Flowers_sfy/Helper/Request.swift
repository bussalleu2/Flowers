//
//  Request.swift
//  Flowers-sfy (iOS)
//
//  Created by Alba Bussalleu on 21/10/21.
//
import Foundation

class Request: NSObject {
    
    let clientId = Constants.Api.UNSPLASH_ACCESS_KEY
    
    let requestQueue : OperationQueue = {
        $0.name = "unsplash.queue"
        $0.qualityOfService = .utility
        return $0
    }(OperationQueue())
    private static let _client = Request()
    let session: URLSession?
    
    private static let baseURL = "https://api.unsplash.com/"
    
    
    private override init() {
        
        let config = URLSessionConfiguration.default
        config.networkServiceType = .responsiveData
        config.httpAdditionalHeaders = ["Authorization" : "Client-ID \(clientId)"]
        session = URLSession(configuration: config, delegate: nil, delegateQueue: requestQueue)
    }
    
    class func GETRequest(path: String, params: [String: AnyObject]?, completion:@escaping (_ data1: Data?, _ error1 : Error?)-> Void) {
        if let url = URL(string: "\(baseURL + path)") {
            let request = URLRequest(url: url)
            _client.session?.dataTask(with: request) { (data, response, error) in
                guard error == nil else {
                    completion(data,error)
                    return
                }
                completion(data, error)
            }.resume()
        }
    }
}

