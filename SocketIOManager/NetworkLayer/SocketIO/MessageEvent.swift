//
//  MessageEvent.swift
//  LT Driver
//
//  Created by Dmitry Onishchuk on 06.07.2021.
//  Copyright © 2021 Lubimoe Taxi. All rights reserved.
//

import Foundation
import UIKit

class MessageEvent{
    
    let event: SocketIOEvent
    let json: mJSON
    let error: String?
    
    init(event: SocketIOEvent, json: [String: Any], error: String?) {
        self.event = event
        self.json = json
        self.error = error
    }
}
