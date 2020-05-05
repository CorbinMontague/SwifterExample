//
//  ToDoResponse.swift
//  SwifterSpike
//
//  Created by Corbin Montague on 5/5/20.
//  Copyright © 2020 Corbin. All rights reserved.
//

import Foundation

struct ToDoResponse: Codable {
    let userId: Int
    let title: String
    let completed: Bool
    let id: Int?
    
    init(userId: Int, title: String, completed: Bool, id: Int? = nil) {
        self.userId = userId
        self.title = title
        self.completed = completed
        self.id = id
    }
}
