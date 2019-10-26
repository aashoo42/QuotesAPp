//
//  DetailsVC.swift
//  QuotesApp
//
//  Created by Absoluit on 11/08/2019.
//  Copyright © 2019 Absoluit. All rights reserved.
//

import UIKit
import GoogleMobileAds

class DetailsVC: UIViewController {
    
    var quoteDict = NSDictionary()
    
    @IBOutlet weak var detailsLbl: UILabel!
    @IBOutlet weak var authorLbl: UILabel!
    @IBOutlet weak var professionLbl: UILabel!
    
    var interstitial: GADInterstitial!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = quoteDict["author"] as! String
        
        self.detailsLbl.text = quoteDict["content"] as! String
        self.authorLbl.text = quoteDict["author"] as! String
        self.professionLbl.text = quoteDict["professtion"] as? String
        
        (UIApplication.shared.delegate as! AppDelegate).autoReviewWithinApp()
        
        interstitial = GADInterstitial(adUnitID: AdsIDS.interstitialLive)
        let request = GADRequest()
        interstitial.load(request)
    }
    
    @IBAction func backAction(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func moreAppsAction(_ sender: UIButton) {
        UIApplication.shared.openURL(NSURL(string: "https://apps.apple.com/us/developer/muhammad-ali/id1387762640")! as URL)
    }
    
    @IBAction func speakAction(_ sender: UIButton) {
//        if interstitial.isReady{
//            interstitial.present(fromRootViewController: self)
//        }else{
//            // Line 1. Create an instance of AVSpeechSynthesizer.
//            var speechSynthesizer = AVSpeechSynthesizer()
//            // Line 2. Create an instance of AVSpeechUtterance and pass in a String to be spoken.
//            var speechUtterance: AVSpeechUtterance = AVSpeechUtterance(string: "\(self.detailsLbl.text!) by \(self.authorLbl.text!)")
//            //Line 3. Specify the speech utterance rate. 1 = speaking extremely the higher the values the slower speech patterns. The default rate, AVSpeechUtteranceDefaultSpeechRate is 0.5
//            speechUtterance.rate = AVSpeechUtteranceMaximumSpeechRate / 3.0
//            // Line 4. Specify the voice. It is explicitly set to English here, but it will use the device default if not specified.
//            speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-US")
//            // Line 5. Pass in the urrerance to the synthesizer to actually speak.
//            speechSynthesizer.speak(speechUtterance)
//        }
    }
    
    @IBAction func shareAction(_ sender: UIButton) {
        if interstitial.isReady{
            interstitial.present(fromRootViewController: self)
        }else{
            let imageToShare = [ self.detailsLbl.text, self.authorLbl.text, self.professionLbl.text ]
            let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
            
            // present the view controller
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
}
