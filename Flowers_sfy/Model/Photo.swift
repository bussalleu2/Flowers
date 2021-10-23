//
//  Photo.swift
//  Flowers-sfy (iOS)
//
//  Created by Alba Bussalleu on 21/10/21.
//

import UIKit

public enum FlowersImageQuality: String {
    case full, small, thumb, regular, raw
}

struct PhotoUrls: Codable {
    var full: String
    var small: String
    var thumb: String
    var regular: String
    var raw: String
}

struct PhotoLinks:Codable {
    var download_location: String
    var html: String
    var download: String
}

struct Photo: Codable, Equatable {
    static func == (lhs: Photo, rhs: Photo) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id: String?
    var urls: PhotoUrls?
    var links: PhotoLinks?
    var user: User?
    
    struct SearchResult: Codable {
        var results: [Photo]?
    }

    func getURLForQuality(quality: FlowersImageQuality) -> String? {
        var url: String? = nil
        switch quality {
        case .full:
            url = self.urls?.full
            break
        case .raw:
            url = self.urls?.raw
            break
        case .regular:
            url = self.urls?.regular
            break
        case .small:
            url = self.urls?.small
            break
        case .thumb:
            url = self.urls?.thumb
            break
        }
        return url
    }
}
