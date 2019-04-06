//
//  ViewController.swift
//  StackingTimer
//
//  Created by Minoru Taki on 2019/04/05.
//  Copyright © 2019 tacky21jp. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var nowTime: Double = Double()
    var elapsedTime: Double = Double()
    var displayTime: Double = Double()
    var savedTime: Double = Double()
    
    var timer: Timer = Timer()
    var status = 0
    var pushFlag1:Bool = false
    var pushFlag2:Bool = false

    @IBOutlet weak var ReadyButton: BGButton!
    @IBOutlet weak var ReadyButton2: BGButton!
    
    @IBOutlet weak var TimerLabel: UILabel!
    @IBOutlet weak var MessageLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func OnTouchDown(_ sender: Any) {
        let btn = sender as! BGButton
        if( btn == ReadyButton){
            pushFlag1 = true
        } else if( btn == ReadyButton2){
            pushFlag2 = true
        } else {
            return
        }
        
        if(status==0 && pushFlag1 && pushFlag2){
            status = 1
            TimerLabel.text = "00:00.00"
            MessageLabel.text = "★Ready★"
        } else if(status == 2){
            timer.invalidate()
            MessageLabel.text = ""
            ReadyButton.setTitle("Set",for: .normal)
            ReadyButton2.setTitle("Set",for: .normal)
            pushFlag1 = false
            pushFlag1 = false
            status = 0

        }
        /*
        if(MessageLabel.text == "Ready"){
            TimerLabel.text = "00:00.00"
            MessageLabel.text = "★Ready★"
        } else {
            timer.invalidate()
            MessageLabel.text = "Ready"
        }
        */
    }
    
    @IBAction func OnTouchUp(_ sender: Any) {
        let btn = sender as! BGButton
        if( btn == ReadyButton){
            pushFlag1 = false
        } else if( btn == ReadyButton2){
            pushFlag2 = false
        } else {
            return
        }
        
        if(status==1 && !pushFlag1 && !pushFlag2){
            MessageLabel.text = "Go!"
            nowTime = NSDate.timeIntervalSinceReferenceDate
            timer = Timer.scheduledTimer(timeInterval: 1/100, target: self, selector: #selector(stopWatch), userInfo: nil, repeats: true)
            
            ReadyButton.setTitle("Stop",for: .normal)
            ReadyButton2.setTitle("Stop",for: .normal)
            status = 2
            
        } else if(status == 2){
            elapsedTime = NSDate.timeIntervalSinceReferenceDate
            displayTime = (elapsedTime + savedTime) - nowTime
            reloadText()
        }
        
        /*
        if(MessageLabel.text == "★Ready★"){
            nowTime = NSDate.timeIntervalSinceReferenceDate
            timer = Timer.scheduledTimer(timeInterval: 1/100, target: self, selector: #selector(stopWatch), userInfo: nil, repeats: true)

            ReadyButton.setTitle("Stop",for: .normal)
        } else if(ReadyButton.currentTitle == "Stop"){
            elapsedTime = NSDate.timeIntervalSinceReferenceDate
            displayTime = (elapsedTime + savedTime) - nowTime
            
            reloadText()
            //ReadyButton.setTitle("Ready",for: .normal)
        }
         */
    }
    
    func reloadText(){
        let min = Int(displayTime / 60)
        let sec = Int(floor(displayTime)) % 60
        let decimal = Int((displayTime - Double(floor(displayTime))) * 100)
        
        let minText = String(format: "%02d", min)
        let secText = String(format: "%02d", sec)
        let decimalText = String(format: "%02d", decimal)
        
        TimerLabel.text = "\(minText):\(secText).\(decimalText)"
    }
    
    @objc func stopWatch(){
        elapsedTime = NSDate.timeIntervalSinceReferenceDate
        displayTime = (elapsedTime + savedTime) - nowTime
        
        reloadText()
    }
    
    @IBAction func OnReset(_ sender: Any) {
        timer.invalidate()
        TimerLabel.text = "00:00.00"
        MessageLabel.text = ""
        status = 0
    }
}

