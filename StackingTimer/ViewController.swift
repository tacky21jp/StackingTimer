//
//  ViewController.swift
//  StackingTimer
//
//  Created by Minoru Taki on 2019/04/05.
//  Copyright © 2019 tacky21jp. All rights reserved.
//

import UIKit
import GoogleMobileAds

class ViewController: UIViewController, AmazonAdViewDelegate, GADRewardBasedVideoAdDelegate {
    
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
    @IBOutlet weak var ResetButton: BGButton!
    
    @IBOutlet weak var TimerLabel: UILabel!
    @IBOutlet weak var MessageLabel: UILabel!
    @IBOutlet weak var ImageTouchLeft: UIImageView!
    @IBOutlet weak var ImageTouchRight: UIImageView!
    
    // For Amazon Ad
    @IBOutlet var amazonAdView: AmazonAdView!
    
    // For Google AdMob
    let AdMobID = "ca-app-pub-5694788749236517/8403644297"
    let TEST_ID = "ca-app-pub-3940256099942544/1712485313"
    let simulation = false
    var AdUnitID:String? = nil
    var rewardBasedAd: GADRewardBasedVideoAd!
    var adRequestInProgress = false
    var adRedy = false
    var challengeCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Amazon Affiliate Loading
        loadAmazonAd()
        
        // Google AdMob Loading
        if simulation {
            AdUnitID = TEST_ID
        } else{
            AdUnitID = AdMobID
        }
        rewardBasedAd = GADRewardBasedVideoAd.sharedInstance()
        rewardBasedAd.delegate = self
        rewardBasedAd.load(GADRequest(), withAdUnitID: AdUnitID!)

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
            ImageTouchLeft.isHidden = true
            ImageTouchRight.isHidden = true
        } else if(status == 2){
            timer.invalidate()
            MessageLabel.text = ""
            ReadyButton.setTitle("Set",for: .normal)
            ReadyButton2.setTitle("Set",for: .normal)
            ReadyButton.isEnabled = false
            ReadyButton2.isEnabled = false
            pushFlag1 = false
            pushFlag1 = false
            status = 0

        }
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
        challengeCount+=1
        ReadyButton.isEnabled = true
        ReadyButton2.isEnabled = true
        ReadyButton.setTitle("Set",for: .normal)
        ReadyButton2.setTitle("Set",for: .normal)

        if challengeCount > 7 && rewardBasedAd.isReady == true {
            rewardBasedAd.present(fromRootViewController: self)
            setupRewardBasedVideoAd()
            challengeCount = 0
        }
    }
    
    // Amazon Affiliate
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil, completion: { (context) -> Void in
            // Reload Amazon Ad upon rotation.
            // Important: Amazon expandable rich media ads target landscape and portrait mode separately.
            // If your app supports device rotation events, your app must reload the ad when rotating between portrait and landscape mode.
            self.loadAmazonAd();
        });
    }
    
    @IBAction func loadAmazonAd(){
        if ((amazonAdView) != nil) {
            amazonAdView.removeFromSuperview()
            amazonAdView = nil
        }
        
        // Initialize Auto Ad Size View
        let adFrame: CGRect = CGRect(x: 0, y: (ResetButton.frame.origin.y + ResetButton.frame.size.height + 5) / 2, width: UIScreen.main.bounds.size.width, height: 90);
        amazonAdView = AmazonAdView.init(frame: adFrame)
        amazonAdView.autoresizingMask = [.flexibleWidth, .flexibleLeftMargin, .flexibleRightMargin, .flexibleBottomMargin]
        amazonAdView.setHorizontalAlignment(.center)
        amazonAdView.setVerticalAlignment(.fitToContent)
        
        // Register the ViewController with the delegate to receive callbacks.
        amazonAdView.delegate = self
        
        // Set Ad Loading Options & Load Ad
        let options = AmazonAdOptions()
        options.isTestRequest = true
        amazonAdView.loadAd(options)
    }
    
    // MARK: AmazonAdViewDelegate
    func viewControllerForPresentingModalView() -> UIViewController {
        return self
    }
    
    func adViewDidLoad(_ view: AmazonAdView!) -> Void {
        // Add the newly created Amazon Ad view to our view.
        self.view.addSubview(amazonAdView)
    }
    
    func adViewDidFail(toLoad view: AmazonAdView!, withError: AmazonAdError!) -> Void {
        Swift.print("Ad Failed to load. Error code \(withError.errorCode): \(withError.errorDescription)")
    }
    
    func adViewWillExpand(_ view: AmazonAdView!) -> Void {
        Swift.print("Ad will expand")
    }
    
    func adViewDidCollapse(_ view: AmazonAdView!) -> Void {
        Swift.print("Ad has collapsed")
    }

    // Google AdMob
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didRewardUserWith reward: GADAdReward) {
        print("Reward received with currency: \(reward.type), amount \(reward.amount).")
        adRequestInProgress = false
    }
    
    func rewardBasedVideoAdDidReceive(_ rewardBasedVideoAd:GADRewardBasedVideoAd) {
        print("Reward based video ad is received.")
        adRequestInProgress = false
        adRedy = true
    }
    
    func rewardBasedVideoAdDidOpen(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Opened reward based video ad.")
    }
    
    func rewardBasedVideoAdDidStartPlaying(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Reward based video ad started playing.")
    }
    
    func rewardBasedVideoAdDidCompletePlaying(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Reward based video ad has completed.")
    }
    
    func rewardBasedVideoAdDidClose(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Reward based video ad is closed.")
        setupRewardBasedVideoAd()
    }
    
    func rewardBasedVideoAdWillLeaveApplication(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Reward based video ad will leave application.")
    }
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didFailToLoadWithError error: Error) {
        print("Reward based video ad failed to load.")
        adRequestInProgress = false
    }
    
    func setupRewardBasedVideoAd(){
        if !adRequestInProgress && rewardBasedAd?.isReady == false {
            rewardBasedAd?.load(GADRequest(),withAdUnitID: AdUnitID! )
            adRequestInProgress = true
        } else {
            print("Error: setup RewardBasedVideoAd")
        }
    }
}

