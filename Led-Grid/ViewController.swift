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
    
    var lightPanelMode: UInt8 = 100 //default to live User mode
    
    var redSliderVal: UInt8 = 125
    var greenSliderVal: UInt8 = 75
    var blueSliderVal: UInt8 = 25
    
    @IBAction func redSlider(sender: UISlider) {
        redSliderVal = UInt8(sender.value)
        print("red",sender.value)
    }
    @IBAction func greenSlider(sender: UISlider) {
        greenSliderVal = UInt8(sender.value)
        print("green",sender.value)
    }

    @IBAction func blueSlider(sender: UISlider) {
        blueSliderVal = UInt8(sender.value)
        print("blue",sender.value)
    }
    
    @IBAction func toggleRainbow(sender: UISwitch) {
        if (sender.on) { lightPanelMode = UInt8(101) }
        else { lightPanelMode = UInt8(100) }
        sendPosition(UInt8(0))
        print("toggle Rainbow: ", sender.on, "lightPanelMode:", lightPanelMode)
    }
    var timerTXDelay: NSTimer?
    var allowTX = true
    var lastPosition: UInt8 = 255
    var sendPosNum: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        //setup view 
        var i = 0
        for img in imgLeds{
            img.tag = i
            img.image = UIImage(named: "image-led-grid-blue.png")
            i++
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
  
//        var r: UInt32 = 50
//        var g : UInt32 = 128
//        var b : UInt32 = 255
//        
//        var final : UInt32 = UInt32(position)
//        final = (final << 24)
//        r = (r << 16)
//        g = (g << 8)
//        
//        final = final | r | g | b
//        
//        var strFinal = "" as String
//        strFinal += NSString(format: "%8X", final) as String
//        print(strFinal)

        // 4
        // Send position to BLE Shield (if service exists and is connected)
        if let bleService = btDiscoverySharedInstance.bleService {
//          bleService.writePosition(final)
            bleService.writePosition(blueSliderVal)
            bleService.writePosition(greenSliderVal)
            bleService.writePosition(redSliderVal)
            bleService.writePosition(position)
            bleService.writePosition(lightPanelMode)
        
            print(sendPosNum)
            sendPosNum++
            
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
                img.image = UIImage(named: "image-led-grid-green.png")
                self.sendPosition(UInt8(img.tag))
                
                //setup timer for removing img
                _ = NSTimer.scheduledTimerWithTimeInterval(1,
                    target: self,
                    selector: ("resetImage:"),
                    userInfo: img,
                    repeats: false)

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
                img.image = UIImage(named: "image-led-grid-green.png")
                self.sendPosition(UInt8(img.tag))
                
                //setup timer for removing img
                _ = NSTimer.scheduledTimerWithTimeInterval(1,
                    target: self,
                    selector: ("resetImage:"),
                    userInfo: img,
                    repeats: false)
                
                break
            }
        }
        super.touchesMoved(touches, withEvent: event)
    }

    //1 second delay then erase image change
    func resetImage(timer: NSTimer){
        let tag = timer.userInfo?.tag
//        print("resenting timer tag: ", tag)
        for img in imgLeds{
            if (img.tag == tag){
                img.image = UIImage(named: "image-led-grid-blue.png")
                break
            }
        }
        

    }

}

