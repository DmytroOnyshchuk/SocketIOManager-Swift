//
//  ViewController.swift
//  SocketIOManager
//
//  Created by Dmitry Onishchuk on 08.07.2021.
//

import UIKit

class ViewController: UIViewController, SocketIOObserver {
    
    @IBOutlet weak var typingLabel: UILabel!
    
    var socketIOManager: SocketIOManager!
    
    @IBOutlet weak var loginButtonAction: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        socketIOManager = SocketIOManager.shared
        socketIOManager.subscribe(self)
    }
    
    deinit {
        socketIOManager.unsubscribe(self)
    }
    
    @IBAction func loginButtonAction(_ sender: UIButton) {
        socketIOManager.login()
    }
    
    func newMessage(message: Any) {
        print(#function + self.description)
        if message is MessageEvent {
            
            let msg = message as! MessageEvent
            
            switch msg.event {
            case .TYPING:
                let us = msg.data as! TypingResponse
                typingLabel.text = us.username + " is typing"
            case .STOP_TYPING:
                typingLabel.text = " "
            default:
                break
            }
        }
        
    }
}
