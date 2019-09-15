//
//  ViewController.swift
//  QuotesApp
//
//  Created by Absoluit on 11/08/2019.
//  Copyright © 2019 Absoluit. All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds

class ListContoller: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var quotesTableView: UITableView!
    @IBOutlet weak var bannerView: GADBannerView!
    
    var databaseRef: DatabaseReference!
    var quotesArray = NSArray()
    
    var quoteType = ""
    var alert = UIAlertController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = quoteType
        databaseRef = Database.database().reference()
        self.getQuotesFromFirebase()
        self.showLoader()
        
        bannerView.adUnitID = AdsIDS.bannerTest
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
    }
    
    @IBAction func backAction(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func showLoader(){
        alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating()
        
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: false, completion: nil)
    }
    
    func getQuotesFromFirebase(){
        databaseRef.child("\(quoteType)").observe(.value) { (data) in
            self.alert.dismiss(animated: true, completion: nil)
            if !(data.value is NSNull){
                self.quotesArray = data.value as! NSArray
                self.quotesTableView.reloadData()
            }
        }
    }

    // MARK:-
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quotesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.alert.dismiss(animated: true, completion: nil)
        let cell = self.quotesTableView.dequeueReusableCell(withIdentifier: "ListCell") as! ListCell
        let tempDict = quotesArray[indexPath.row] as! NSDictionary
        
        cell.detailsLbl.text = tempDict["title"] as! String
        cell.authorLbl.text = tempDict["author"] as! String
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.quotesTableView.deselectRow(at: indexPath, animated: true)
        
        let tempDict = quotesArray[indexPath.row] as! NSDictionary
        
        let objDetailsVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailsVC") as! DetailsVC
        objDetailsVC.quoteDict = tempDict
        self.navigationController?.pushViewController(objDetailsVC, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
//        let tempDict = quotesArray[indexPath.row] as! NSDictionary
//
//        let tempStr = tempDict["title"] as! NSString
//        let rect = tempStr.boundingRect(with: CGSize.init(width: self.view.frame.width-10, height: 500), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: nil, context: nil)
//        print(rect.height)
//
//        return rect.height + 50
        
    }
}

