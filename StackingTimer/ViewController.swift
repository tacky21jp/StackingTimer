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
    
    var startOrStop: Bool = false
    var timer: Timer = Timer()

    @IBOutlet weak var ReadyButton: BGButton!
    
    @IBOutlet weak var TimerLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func OnTouchDown(_ sender: Any) {
        if(ReadyButton.currentTitle == "Ready"){
            TimerLabel.text = "00:00.00"
            ReadyButton.setTitle("★Ready★",for: .normal)
        } else {
            //ReadyButton.setTitle("Stop",for: .normal)
            timer.invalidate()
            ReadyButton.setTitle("Ready",for: .normal)
        }
    }
    
    @IBAction func OnTouchUp(_ sender: Any) {
        if(ReadyButton.currentTitle == "★Ready★"){
            nowTime = NSDate.timeIntervalSinceReferenceDate
            timer = Timer.scheduledTimer(timeInterval: 1/100, target: self, selector: #selector(stopWatch), userInfo: nil, repeats: true)

            ReadyButton.setTitle("Stop",for: .normal)
        } else if(ReadyButton.currentTitle == "Stop"){
            elapsedTime = NSDate.timeIntervalSinceReferenceDate
            displayTime = (elapsedTime + savedTime) - nowTime
            
            reloadText()
            //ReadyButton.setTitle("Ready",for: .normal)
        }
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
        ReadyButton.setTitle("Ready",for: .normal)
        
    }
}

