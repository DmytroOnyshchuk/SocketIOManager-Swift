//
//  SocketIOManager.swift
//  LT Driver
//
//  Created by Dmitry Onishchuk on 06.07.2021.
//  Copyright © 2021 Lubimoe Taxi. All rights reserved.
//

import Foundation
import SocketIO
import SwiftyJSON

protocol Observer: class {
    func newMessage(message: Any)
}

let chatURL = "http://socketio-chat-h9jt.herokuapp.com/"

class SocketIOManager {
    
    static let shared = SocketIOManager(socketURL: URL(string: chatURL)!)
    
    private let RECONNECTION_ATTEMPT = 10;
    private let RECONNECTION_DELAY = 5000;
    
    private var socket:SocketIOClient!
    private var manager:SocketManager!
    private lazy var observers = [Observer]()
    
    init(socketURL: URL) {
        let config: SocketIOClientConfiguration = [.log(false),
                                                   .forceNew(true),
                                                   .reconnects(true),
                                                   .reconnectAttempts(RECONNECTION_ATTEMPT),
                                                   .reconnectWait(RECONNECTION_DELAY),
                                                   .compress]
        
        
        
        self.manager = SocketManager(socketURL: socketURL, config: config)
        self.socket = manager.defaultSocket
        setupListeners()
        setup()
    }
    
    private func setup(){
        self.establishConnection()
    }
    
    // MARK: Observer Functions
    
    func subscribe(_ observer: Observer){
        if isUniqSubscriber(observer: observer) {
            print("Someone subscribed to SocketIO observer")
            observers.append(observer)
            print(String(observers.count) + " subscribers")
        }else{
            print("Someone didnt subscribed to SocketIO. Is already subscriber")
        }
    }
    
    func unsubscribe(_ observer: Observer){
        if let index = observers.index(where: {$0 === observer}){
            observers.remove(at: index)
            print(#function)
        }
    }
    
    private func isUniqSubscriber(observer: Observer) -> Bool{
        for subscriber in observers {
            if subscriber === observer{
                return false
            }
        }
        return true
    }
    
    // MARK: SocketIO Functions
    
    private func setupListeners() {
        
        socket.on(clientEvent: .connect) {[weak self] data, ack in
            self?.connected()
        }
        
        socket.on(clientEvent: .reconnect) {[weak self] data, ack in
            self?.reconnect()
        }
        
        socket.on(clientEvent: .reconnectAttempt) {[weak self] data, ack in
            self?.reconnectAttempt()
        }
        
        socket.on(clientEvent: .disconnect) {[weak self] data, ack in
            self?.disconnected()
        }
        
        socket.on(clientEvent: .statusChange) {[weak self] data, ack in
            print("SocketIO statusChanged: " + (self?.socket.status.description)!)
        }
        
        socket.on(clientEvent: .error) {[weak self] data, ack in
            print("SocketIO ERROR: ")
            if data.count > 0 {
                print(data)
            }
        }
        
        socket.on(SocketIOEvent.TYPING.rawValue) {[weak self] data, ack in
            if data.count > 0 {
                self?.isTyping(data: data)
            }
        }
        
        socket.on(SocketIOEvent.STOP_TYPING.rawValue) {[weak self] data, ack in
            if data.count > 0 {
                self?.stopTyping(data: data)
            }
        }
        
        socket.onAny({(event) in
            // print(event)
            //print("Got event: \(event.event), with items: \(event.items)")
        })
    }
    
    private func connected(){
        print("SocketIO Connected")
    }
    
    private func reconnect(){
        print("SocketIO Reconnect")
    }
    
    private func reconnectAttempt(){
        print("SocketIO Reconnect Attempt")
    }
    
    private func disconnected(){
        print("SocketIO Disconnected")
    }
    
    private func isTyping(data: [Any]){
        print(String(describing: self) + " " + #function)
        print(data)
        
        guard let json = data.first as? [String: Any] else { return }
        let me = MessageEvent(event: SocketIOEvent.TYPING, json: json, error: nil)
        notifyEvent(message: me)
    }
    
    private func stopTyping(data: [Any]){
        print(String(describing: self) + " " + #function)
        print(data)
        
        guard let json = data.first as? [String: Any] else { return }
        let me = MessageEvent(event: SocketIOEvent.STOP_TYPING, json: json, error: nil)
        notifyEvent(message: me)
    }
    
    private func notifyEvent(message: MessageEvent){
        print(String(describing: self) + " " + #function)
        observers.forEach{$0.newMessage(message: message)}
    }
    
    
    // MARK: Public Functions
    
    func establishConnection() {
        print("SocketIO " + #function)
        if (self.socket?.status == .disconnected || self.socket?.status == .notConnected ) {
            socket?.connect()
        }
        else {
            debugPrint("======= Socket already connected =======")
        }
    }
    
    func getStatus() -> SocketIOStatus? {
        guard let status = self.socket?.status else{ return nil }
        return status
    }
    
    func login(){
        print(String(describing: self) + " " + #function)
        //sendEvent(event: SocketIOEvent.LOGIN, json: "TestUser")
        socket.emit(SocketIOEvent.LOGIN.rawValue, "TestUser")
    }
    
    func sendEvent(event:SocketIOEvent, json: mJSON){
       // print("sendEvent: " + "\"" + event.rawValue + "\"" + ". With JSON:")
       // print(json)
        
        print("SocketIOManager: sendEvent: " + "\"" + event.rawValue + "\"" + ". With JSON:")
        print(json)
        socket.emit(event.rawValue, json)
    }
    
}
