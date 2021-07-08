//
//  SocketIOEvent.swift
//  LT Driver
//
//  Created by Dmitry Onishchuk on 06.07.2021.
//  Copyright © 2021 Lubimoe Taxi. All rights reserved.
//

import Foundation

enum SocketIOEvent : String {
    case TYPING           = "typing";
    case STOP_TYPING      = "stop typing";
    case LOGIN            = "login";
}
