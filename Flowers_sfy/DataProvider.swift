//
//  PhotosRequest.swift
//  Flowers-sfy (iOS)
//
//  Created by Alba Bussalleu on 21/10/21.
//

import UIKit

public class DataProvider: NSObject {
    
    static func searchPhotos(query: String,
                       page: Int = 1,
                       per_page: Int = 10,
                       completion: @escaping ([Photo], Errors?) -> Void) {
        
        Request.GETRequest(path: "search/photos?query=\(query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")&page=\(page)&per_page=\(per_page)", params: nil) { (data,error) in
            if let error = error  {
                var err = Errors()
                err.errors = [error.localizedDescription]
                completion([], err)
                return
            }
            guard let data = data else {
                return
            }
            let decoder = JSONDecoder()
            do {
                let k = try decoder.decode(Photo.SearchResult.self, from: data)
                if let results = k.results {
                    completion(results, nil)
                }
            } catch {
                do {
                    let k = try decoder.decode(Errors.self, from: data)
                    completion([], k)
                } catch {
                    if let dataString = String(data: data, encoding: .utf8) {
                        var err = Errors()
                        err.errors = [dataString]
                        completion([], err)
                    }
                }
            }
        }
    }
    }
    

