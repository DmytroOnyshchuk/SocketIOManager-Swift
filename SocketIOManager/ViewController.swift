//
//  ViewController.swift
//  SocketIOManager
//
//  Created by Dmitry Onishchuk on 08.07.2021.
//

import UIKit

class ViewController: UIViewController, Observer {
    
    @IBOutlet weak var typingLabel: UILabel!
    
    var sm: SocketIOManager!
    
    @IBOutlet weak var loginButtonAction: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sm = SocketIOManager.shared
        sm.subscribe(self)
    }
    
    @IBAction func loginButtonAction(_ sender: UIButton) {
        sm.login()
    }
    
    func newMessage(message: Any) {
        print(#function + self.description)
        if message is MessageEvent {
            
            let msg = message as! MessageEvent
            
            switch msg.event {
            case .TYPING:
                if let typing: TypingResponse = try? SocketParser.convert(data: msg.json) {
                    typingLabel.text = typing.username + " is typing"
                }
            case .STOP_TYPING:
                typingLabel.text = " "
            default:
                break
            }
        }
        
    }
}
