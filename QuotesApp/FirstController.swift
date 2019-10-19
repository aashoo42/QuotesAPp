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


class FirstController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, GADBannerViewDelegate {

    @IBOutlet weak var quoteCollectionView: UICollectionView!
    @IBOutlet weak var bannerView: GADBannerView!
    
    var categoryArray = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bannerView.adUnitID = AdsIDS.bannerTest
        bannerView.rootViewController = self
        bannerView.delegate = self
        bannerView.load(GADRequest())
        
        bannerView.isHidden = true
        
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
        return self.categoryArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.quoteCollectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
        
        let tempDict = categoryArray[indexPath.row] as! NSDictionary
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
        let objListContoller = self.storyboard?.instantiateViewController(withIdentifier: "ListContoller") as! ListContoller
        let tempDict = categoryArray[indexPath.row] as! NSDictionary
        objListContoller.quoteDict = tempDict
        self.navigationController?.pushViewController(objListContoller, animated: true)
    }
    
    // MAKR:- GADBannerViewDelegate
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.isHidden = false
    }
    
    // MARK:- API
    func getQuotesCategories(){
        let urlStr = "\(BASE_URL)\(CATEGORIES_API)"
        Alamofire.request(urlStr, method: .get).responseJSON { (response) in
            print(response.result.value)
            if (response.response?.statusCode == 200) && (response.result.value != nil){
                let jsonReponse = response.result.value as! NSDictionary
                self.categoryArray = jsonReponse["Result"] as! NSArray
                self.quoteCollectionView.reloadData()
            }
        }
    }
}


let BASE_URL = "http://www.apiqoutes.somee.com/qoutesapp/"
let IMAGE_URL = "http://www.apiqoutes.somee.com"

let CATEGORIES_API = "Categories"
