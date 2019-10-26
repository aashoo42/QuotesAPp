//
//  ViewController.swift
//  QuotesApp
//
//  Created by Absoluit on 11/08/2019.
//  Copyright © 2019 Absoluit. All rights reserved.
//

import UIKit
import Alamofire
import GoogleMobileAds

class ListContoller: UIViewController, UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate {

    @IBOutlet weak var quotesTableView: UITableView!
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var titleLbl: UILabel!
    
    var interstitial: GADInterstitial!
    
    var quoteDict = NSDictionary()
    var quotesArray = NSMutableArray()
    
    var quoteType = ""
    var alert = UIAlertController()
    
    var pageNumber = 1
    var categoryID = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = quoteType
        self.showLoader()
        
        // banner settings
        bannerView.adUnitID = AdsIDS.bannerLive
        bannerView.rootViewController = self
        bannerView.delegate = self
        bannerView.load(GADRequest())
        
        // interstitial settings
        interstitial = GADInterstitial(adUnitID: AdsIDS.interstitialLive)
        let request = GADRequest()
        interstitial.load(request)
        
        self.titleLbl.text = "\(quoteDict["Name"] as? String ?? "Quotes") Quotes"
        
        categoryID = quoteDict["Id"] as? Int ?? 0
        self.getQuotesByCategoryIDApi(pageNumber: pageNumber)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
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
    
    @IBAction func backAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    // MARK:- GADBannerView
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        self.bannerView.isHidden = false
    }
    
    //MARK:- API
    func getQuotesByCategoryIDApi(pageNumber: Int){
        let getPath = "\(BASE_URL)Qoutes?categoryId=\(categoryID)&pageNumber=\(pageNumber)"
        print("getPath: \(getPath)")
        Alamofire.request(getPath, method: .get, parameters: nil).responseJSON { (response) in
            self.alert.dismiss(animated: true, completion: nil)
            print(response.result.value)
            if response.result.value != nil{
                let responseDict = response.result.value as! NSDictionary
                if (responseDict["StatusCode"] as! Int) == 200{
                    if !(responseDict["Result"] is NSNull) && (responseDict["Result"] != nil){
                        self.pageNumber = self.pageNumber + 1
                        
                        let dataArray = responseDict["Result"] as! NSArray
                        self.quotesArray.addObjects(from: dataArray as! [Any])
                        self.quotesTableView.reloadData()
                    }
                }else{
                    print("status code is different")
                }

            }else{
                
            }
        }
    }
    
    // MARK:- UITableView
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
        
        cell.detailsLbl.text = tempDict["Description"] as? String ?? ""
        cell.authorLbl.text = tempDict["Author"] as? String ?? "Unknown"
        
        if indexPath.row == (quotesArray.count - 3){
            self.showLoader()
            self.getQuotesByCategoryIDApi(pageNumber: pageNumber)
        }
        
        if UserDefaults.standard.value(forKey: "LikedItems") != nil{
            let likedArray = UserDefaults.standard.value(forKey: "LikedItems") as! NSArray
            let newDict = (UIApplication.shared.delegate as! AppDelegate).checkNullValues(tempDict: tempDict)
            if likedArray.contains(newDict){
                cell.likeBtn.setImage(UIImage.init(named: "like-list-gray"), for: .normal)
            }else{
                cell.likeBtn.setImage(UIImage.init(named: "like-list"), for: .normal)
            }
        }
        
        cell.likeBtn.tag = indexPath.row
        cell.downloadBtn.tag = indexPath.row
        cell.copyBtn.tag = indexPath.row
        cell.shareBtn.tag = indexPath.row
        
        cell.likeBtn.removeTarget(self, action: #selector(likeAction(sender:)), for: .touchUpInside)
        cell.downloadBtn.removeTarget(self, action: #selector(downloadAction(sender:)), for: .touchUpInside)
        cell.copyBtn.removeTarget(self, action: #selector(copyAction(sender:)), for: .touchUpInside)
        cell.shareBtn.removeTarget(self, action: #selector(shareAction(sender:)), for: .touchUpInside)
        
        cell.likeBtn.addTarget(self, action: #selector(likeAction(sender:)), for: .touchUpInside)
        cell.downloadBtn.addTarget(self, action: #selector(downloadAction(sender:)), for: .touchUpInside)
        cell.copyBtn.addTarget(self, action: #selector(copyAction(sender:)), for: .touchUpInside)
        cell.shareBtn.addTarget(self, action: #selector(shareAction(sender:)), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 350
    }
    
    // MARK:- Cell button actions
    @objc func likeAction(sender: UIButton){
        print("like action at: \(sender.tag)")
        
        let tempDict = quotesArray[sender.tag] as! NSDictionary
        let dictToSave = (UIApplication.shared.delegate as! AppDelegate).checkNullValues(tempDict: tempDict)
        
        if UserDefaults.standard.value(forKey: "LikedItems") == nil{ // firstValue
            let array = [dictToSave]
            UserDefaults.standard.setValue(array, forKey: "LikedItems")
            UserDefaults.standard.synchronize()
        }else{ // already saved values
            let alreadyArray = UserDefaults.standard.value(forKey: "LikedItems") as! NSArray
            let cellIndexPath = IndexPath.init(row: sender.tag, section: 0)
            let newArray = NSMutableArray()
            
            if alreadyArray.contains(dictToSave){
                // remove saved item
                newArray.remove(dictToSave)
                let cell = quotesTableView.cellForRow(at: cellIndexPath) as! ListCell
                cell.likeBtn.setImage(UIImage.init(named: "like-list"), for: .normal)
            }else{
                // add new item
                newArray.addObjects(from: alreadyArray as! [Any])
                newArray.add(dictToSave)
                let cell = quotesTableView.cellForRow(at: cellIndexPath) as! ListCell
                cell.likeBtn.setImage(UIImage.init(named: "like-list-gray"), for: .normal)
            }
            UserDefaults.standard.setValue(newArray, forKey: "LikedItems")
            UserDefaults.standard.synchronize()
        }
    }
    
    @objc func downloadAction(sender: UIButton){
        if interstitial.isReady{
            interstitial.present(fromRootViewController: self)
        }else{
            let cell = self.quotesTableView.cellForRow(at: IndexPath.init(row: sender.tag, section: 0)) as! ListCell
            let size = CGSize.init(width: cell.frame.width, height: cell.topView.frame.height)
            UIGraphicsBeginImageContextWithOptions(size, cell.contentView.isOpaque, 0.0)
            cell.contentView.drawHierarchy(in: cell.contentView.bounds, afterScreenUpdates: false)
            let snapshotImageFromMyView = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            UIImageWriteToSavedPhotosAlbum(snapshotImageFromMyView!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    //MARK: - Add image to Library
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "There is some error occured while saving your quote image", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Try Again!", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your quote image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }

    
    @objc func copyAction(sender: UIButton){
        if interstitial.isReady{
            interstitial.present(fromRootViewController: self)
        }else{
            let toCopy = (quotesArray[sender.tag] as! NSDictionary)["Description"] as! String
            UIPasteboard.general.string = toCopy
            self.view.makeToast("Copied", duration: 1.0, position: .bottom)
        }
    }
    
    @objc func shareAction(sender: UIButton){
        if interstitial.isReady{
            interstitial.present(fromRootViewController: self)
        }else{
            let toShare = (quotesArray[sender.tag] as! NSDictionary)["Description"] as! String
            let appURL = "https://itunes.apple.com/app/id1476205913"
            let message = "\(toShare)\n\(appURL)"
            
            let messageToShare = [ message ]
            let activityViewController = UIActivityViewController(activityItems: messageToShare , applicationActivities: nil)
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
}

