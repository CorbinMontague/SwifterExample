//
//  ToDoResponse.swift
//  SwifterSpike
//
//  Created by Corbin Montague on 5/5/20.
//  Copyright © 2020 Corbin. All rights reserved.
//

import Foundation

struct ToDoResponseModel: Codable {
    let userId: Int
    let id: Int
    let title: String
    let completed: Bool
}
