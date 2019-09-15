//
//  FirstController.swift
//  QuotesApp
//
//  Created by Absoluit on 17/08/2019.
//  Copyright © 2019 Absoluit. All rights reserved.
//

import UIKit
import AVFoundation
import GoogleMobileAds

class FirstController: UIViewController,UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var bannerView: GADBannerView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bannerView.adUnitID = AdsIDS.bannerTest
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
    }
    
    //MARK:-
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.mainTableView.dequeueReusableCell(withIdentifier: "FirstCell") as! FirstCell
        if indexPath.row == 0{ // General
            cell.titleLbl.text = "General"
        }else if indexPath.row == 1{ // Love
            cell.titleLbl.text = "Love"
        }else{
            cell.titleLbl.text = "Coming Soon!"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.mainTableView.deselectRow(at: indexPath, animated: true)
        let obj = self.storyboard?.instantiateViewController(withIdentifier: "ListContoller") as! ListContoller
        if indexPath.row == 0{ // General
            obj.quoteType = "General"
            self.navigationController?.pushViewController(obj, animated: true)
        }else if indexPath.row == 1{ // Love
            obj.quoteType = "Love"
            self.navigationController?.pushViewController(obj, animated: true)
        }else{
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
