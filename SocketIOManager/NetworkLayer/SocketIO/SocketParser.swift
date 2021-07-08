//
//  SocketParser.swift
//  LT Driver
//
//  Created by Dmitry Onishchuk on 06.07.2021.
//  Copyright © 2021 Lubimoe Taxi. All rights reserved.
//

import Foundation
import UIKit

class SocketParser {
    
    static func convert<T: Decodable>(data: Any) throws -> T {
        let jsonData = try JSONSerialization.data(withJSONObject: data)
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: jsonData)
    }
    
    static func convert<T: Decodable>(datas: [Any]) throws -> [T] {
        return try datas.map { (dict) -> T in
            let jsonData = try JSONSerialization.data(withJSONObject: dict)
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: jsonData)
        }
    }
    
}
