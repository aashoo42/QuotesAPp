//
//  AppDelegate.swift
//  QuotesApp
//
//  Created by Absoluit on 11/08/2019.
//  Copyright © 2019 Absoluit. All rights reserved.
//

import UIKit
import StoreKit
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        return true
    }
    
    func autoReviewWithinApp(){
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    
    // MARK:-
    func checkNullValues(tempDict: NSDictionary) -> NSDictionary{
        let authorValue = tempDict["Author"] as? String ?? ""
        let categoryIdValue = tempDict["CategoryId"] as? Int ?? -1
        let categoryNameValue = tempDict["CategoryName"] as? String ?? ""
        let descriptionValue = tempDict["Description"] as? String ?? ""
        let idValue = tempDict["Id"] as? Int ?? -1
        let imageValue = tempDict["Image"] as? String ?? ""
        
        let dictToReturn = NSDictionary.init(dictionary: ["Author": authorValue,
                                                          "CategoryId": categoryIdValue,
                                                          "CategoryName": categoryNameValue,
                                                          "Description": descriptionValue,
                                                          "Id": idValue,
                                                          "Image":imageValue])
        return dictToReturn
    }
}



struct AdsIDS {
    static var bannerLive = "ca-app-pub-6003953631891874/9501173666"
    static var bannerTest = "ca-app-pub-3940256099942544/2934735716"
    static var interstitialLive = "ca-app-pub-6003953631891874/4739801579"
    static var interstitialTest = "ca-app-pub-3940256099942544/4411468910"
}
