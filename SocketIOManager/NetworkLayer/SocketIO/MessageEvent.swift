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
    let data: Any
    let error: String?
    
    init(event: SocketIOEvent, data: Any, error: String?) {
        self.event = event
        self.data = data
        self.error = error
    }
}
