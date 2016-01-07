//
//  ViewController.swift
//  Led-Grid
//
//  Created by Christopher G Walter on 1/5/16.
//  Copyright © 2016 Christopher G Walter. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
//    @IBOutlet var buttons: [UIButton]!

    
//    let image = UIImage(named: "circle.png") as UIImage!

    @IBOutlet var imgLeds: [UIImageView]!
    @IBOutlet weak var imgBluetoothStatus: UIImageView!


    
    var timerTXDelay: NSTimer?
    var allowTX = true
    var lastPosition: UInt8 = 255
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
       
        var i = 0
        for img in imgLeds{
            img.tag = i
            i++
        }
        
        for img in imgLeds{
            print(img)
        }
        
        // Watch Bluetooth connection
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("connectionChanged:"), name: BLEServiceChangedStatusNotification, object: nil)
        
        // Start the Bluetooth discovery process
        btDiscoverySharedInstance
        
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: BLEServiceChangedStatusNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.stopTimerTXDelay()
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Valid position range: 0 to 180
    func sendPosition(position: UInt8) {
        // 1
        if !allowTX {
            return
        }
        
        // 2
        // Validate value
//        if position == lastPosition {
//            return
//        }
            // 3
//        else if ((position < 0) || (position > 180)) {
//            return
//        }
        
        // 4
        // Send position to BLE Shield (if service exists and is connected)
        if let bleService = btDiscoverySharedInstance.bleService {
            bleService.writePosition(position)
            lastPosition = position
            
            // 5
            // Start delay timer
            allowTX = false
            if timerTXDelay == nil {
                timerTXDelay = NSTimer.scheduledTimerWithTimeInterval(0.05,
                    target: self,
                    selector: Selector("timerTXDelayElapsed"),
                    userInfo: nil,
                    repeats: false)
            }
        }
    }
    
    
    func connectionChanged(notification: NSNotification) {
        // Connection status changed. Indicate on GUI.
        let userInfo = notification.userInfo as! [String: Bool]
        
        dispatch_async(dispatch_get_main_queue(), {
            // Set image based on connection status
            if let isConnected: Bool = userInfo["isConnected"] {
                if isConnected {
                    self.imgBluetoothStatus.image = UIImage(named: "Bluetooth_Connected")
                    
                    // Send current slider position //change TODO!
//                    self.sendPosition(UInt8(0))
                } else {
                    self.imgBluetoothStatus.image = UIImage(named: "Bluetooth_Disconnected")
                }
            }
        });
    }
    
    func timerTXDelayElapsed() {
        self.allowTX = true
        self.stopTimerTXDelay()
        
//         Send current slider position  TODO!
//        self.sendPosition(UInt8(0))
    }
    
    func stopTimerTXDelay() {
        if self.timerTXDelay == nil {
            return
        }
        
        timerTXDelay?.invalidate()
        self.timerTXDelay = nil
    }
    

    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        let touch = touches.first
        let location : CGPoint = (touch?.locationInView(self.view))!
        
        for img in imgLeds{
            if (img.frame.contains(location)){
                print("Hit!: ", location, img.tag)
                img.image = UIImage(named: "img-led-on.png")
                self.sendPosition(UInt8(img.tag))
                

                break
            }
        }
        if(imgBluetoothStatus.frame.contains(location)){
            print("foind")
        }
        super.touchesBegan(touches, withEvent: event)
    }
    
    

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        let touch = touches.first
        let location : CGPoint = (touch?.locationInView(self.view))!
        
        for img in imgLeds{
            if (img.frame.contains(location)){
                print("Hit!: ", location, img.tag)
                img.image = UIImage(named: "img-led-on.png")
                self.sendPosition(UInt8(img.tag))
                break
            }
        }
        super.touchesMoved(touches, withEvent: event)
    }


}

