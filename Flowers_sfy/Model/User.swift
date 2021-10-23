//
//  User.swift
//  Flowers-sfy (iOS)
//
//  Created by Alba Bussalleu on 21/10/21.
//

import UIKit
struct UserLinks: Codable {
    var me: String?
    var html: String?
    var photos : String?
    var likes : String?
    var portfolio : String?
}

struct User: Codable {
    var id: String?
    var username: String?
    var name: String?
    var bio: String?
    var links: UserLinks?
}
