//
//  FirstController.swift
//  QuotesApp
//
//  Created by Absoluit on 17/08/2019.
//  Copyright © 2019 Absoluit. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import GoogleMobileAds


class FirstController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, GADBannerViewDelegate {

    @IBOutlet weak var optionsTableView: UITableView!
    @IBOutlet weak var quoteCollectionView: UICollectionView!
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var optionsView: UIView!
    
    var categoryArray = NSArray()
    var optionsArray = ["Favorite Quotes",
                        "Random Quotes",
                        "Rate Our App",
                        "Share with Friends",
                        "Privacy Policy" ]
    
    var searchedArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bannerView.adUnitID = AdsIDS.bannerTest
        bannerView.rootViewController = self
        bannerView.delegate = self
        bannerView.load(GADRequest())
        
        bannerView.isHidden = true
        optionsView.isHidden = true
        
        optionsView.layer.masksToBounds = true
        optionsView.layer.cornerRadius = 5.0
        optionsView.layer.borderWidth = 0.5
        optionsView.layer.borderColor = UIColor.lightGray.cgColor
        
        self.getQuotesCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    // MARK:- UICollectionView
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.searchedArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.quoteCollectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
        
        let tempDict = searchedArray[indexPath.row] as! NSDictionary
        cell.categoryTitleLbl.text = tempDict["Name"] as? String ?? ""
        cell.categoryDetailsLbl.text = tempDict["Description"] as? String ?? ""
        
        var imageName = tempDict["Image"] as? String ?? ""
        if imageName != ""{ // set image here
            imageName = imageName.replacingOccurrences(of: "~", with: "")
            let imageURL = "\(IMAGE_URL)\(imageName)"
            
            cell.categoryImg.af_setImage(withURL: URL.init(string: imageURL)!)
        }else{
            let tempImage = indexPath.row%6
            cell.categoryImg.image = UIImage.init(named: "\(tempImage+1)")
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.optionsView.isHidden = true
        
        let objListContoller = self.storyboard?.instantiateViewController(withIdentifier: "ListContoller") as! ListContoller
        let tempDict = searchedArray[indexPath.row] as! NSDictionary
        objListContoller.quoteDict = tempDict
        self.navigationController?.pushViewController(objListContoller, animated: true)
    }
    
    // MARK:-
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return optionsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init()
        cell.textLabel?.text = optionsArray[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0{ // Favorite Quotes
            self.openFavQuotesVC()
        }else if indexPath.row == 1{ // Random Quotes
            self.openRandomQuotesVC()
        }else if indexPath.row == 2{ // Rate Our App
            self.autoReviewWithinApp()
        }else if indexPath.row == 3{ // Share with Friends
            self.shareWithFriends()
        }else if indexPath.row == 4{ //Privacy Policy
            self.showPrivacyPolicy()
        }
        self.optionsView.isHidden = true
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height/CGFloat(self.optionsArray.count)
    }
    
    // MARK:- UITextField
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    // MARK:- UITextField
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let inputStr = textField.text! + string
        if string.count == 0 && range.length > 0 {
            // don't call api when back pressed
            self.searchedArray.removeAllObjects()
            self.searchedArray.addObjects(from: self.categoryArray as! [Any])
            self.quoteCollectionView.reloadData()
        }
        else{
            if string != " "{ // call api when an alphabet added
                print("Search : \(inputStr)")
                
                self.searchedArray.removeAllObjects()
                
                for i in 0..<categoryArray.count{
                    let tempDict = categoryArray[i] as! NSDictionary
                    let name = tempDict["Name"] as! String
                    if name.lowercased().contains(inputStr.lowercased()){
                        self.searchedArray.add(tempDict)
                        self.quoteCollectionView.reloadData()
                    }
                }
            }else{ // don't call api when space pressed
                print("Blank space added...")
            }
        }
        return true
    }
    
    // MARK:- IBAction
    @IBAction func optionsAction(_ sender: UIButton) {
        optionsView.isHidden = !optionsView.isHidden
    }
    
    // MAKR:- GADBannerViewDelegate
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.isHidden = false
    }
    
    // MARK:- API
    func getQuotesCategories(){
        let urlStr = "\(BASE_URL)\(CATEGORIES_API)"
        Alamofire.request(urlStr, method: .get).responseJSON { (response) in
//            print(response.result.value)
            if (response.response?.statusCode == 200) && (response.result.value != nil){
                let jsonReponse = response.result.value as! NSDictionary
                self.categoryArray = jsonReponse["Result"] as! NSArray
                self.searchedArray.addObjects(from: self.categoryArray as! [Any])
                self.quoteCollectionView.reloadData()
            }
        }
    }
    
    // MARK:- Options Action
    func autoReviewWithinApp(){
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    func shareWithFriends(){
        let appURL = "https://itunes.apple.com/app/id1476205913"
        let message = "Hey checkout this amazing app for free random quotes \n\(appURL)"
        
        let messageToShare = [ message ]
        let activityViewController = UIActivityViewController(activityItems: messageToShare , applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func showPrivacyPolicy(){
        guard let url = URL(string: "http://www.convergebox.com/quickcups/privacy-policy/") else { return }
        UIApplication.shared.open(url)
    }
    
    func openFavQuotesVC(){
        let objFavQuotesVC = self.storyboard?.instantiateViewController(withIdentifier: "FavQuotesVC") as! FavQuotesVC
        self.navigationController?.pushViewController(objFavQuotesVC, animated: true)
    }
    
    func openRandomQuotesVC(){
        let objRandomQuotesVC = self.storyboard?.instantiateViewController(withIdentifier: "RandomQuotesVC") as! RandomQuotesVC
        self.navigationController?.pushViewController(objRandomQuotesVC, animated: true)
    }
    
}


let BASE_URL = "http://www.apiqoutes.somee.com/qoutesapp/"
let IMAGE_URL = "http://www.apiqoutes.somee.com"

let CATEGORIES_API = "Categories"
let RANDOM_QUOTE_API = "randomqoutes"
