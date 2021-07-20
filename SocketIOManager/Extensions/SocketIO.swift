//
//  SIO.swift
//  LTDriver
//
//  Created by Dmitry Onishchuk on 13.07.2021.
//  Copyright © 2021 Lubimoe taxi. All rights reserved.
//

import Foundation
import SocketIO

extension Decodable {
  init(from any: Any) throws {
    let data = try JSONSerialization.data(withJSONObject: any)
    self = try JSONDecoder().decode(Self.self, from: data)
  }
}

extension SocketIOClient {

  func on<T: Decodable>(_ event: String, callback: @escaping (T)-> Void) {
    self.on(event) { (data, _) in
      guard !data.isEmpty else {
        print("[SocketIO] \(event) data empty")
        return
      }

        print("[SocketIO] Decode data: ")
        print(data.first)
        
      guard let decoded = try? T(from: data[0]) else {
        print("[SocketIO] \(event) data \(data) cannot be decoded to \(T.self)")
        return
      }

      callback(decoded)
    }
  }
}
