//
//  RandomQuotesVC.swift
//  QuotesApp
//
//  Created by Absoluit on 19/10/2019.
//  Copyright © 2019 Absoluit. All rights reserved.
//

import UIKit
import Alamofire
import Toast_Swift
import GoogleMobileAds

class RandomQuotesVC: UIViewController, UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate {

    @IBOutlet weak var randomTableView: UITableView!
    @IBOutlet weak var bannerView: GADBannerView!
    
    var alert = UIAlertController()
    var randomArray = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bannerView.adUnitID = AdsIDS.bannerLive
        bannerView.rootViewController = self
        bannerView.delegate = self
        bannerView.load(GADRequest())
        
        self.getRandomQuotes()
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
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func refreshAction(_ sender: Any) {
        self.getRandomQuotes()
    }
    
    // MARK:- GADBannerView
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        self.bannerView.isHidden = false
    }
    
    // MARK:- UITableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return randomArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.randomTableView.dequeueReusableCell(withIdentifier: "RandomCell") as! RandomCell
        
        let tempDict = randomArray[indexPath.row] as! NSDictionary
        cell.detailsLbl.text = tempDict["Description"] as? String ?? ""
        cell.authorLbl.text = tempDict["Author"] as? String ?? "Unknown"

        
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

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 350
    }
    
    // MARK:- API
    func getRandomQuotes(){
        let urlStr = "\(BASE_URL)\(RANDOM_QUOTE_API)"
        self.showLoader()
        Alamofire.request(urlStr, method: .get).responseJSON { (response) in
            self.alert.dismiss(animated: true, completion: nil)
            //            print(response.result.value)
            if (response.response?.statusCode == 200) && (response.result.value != nil){
                let jsonReponse = response.result.value as! NSDictionary
                self.randomArray = jsonReponse["Result"] as! NSArray
                self.randomTableView.reloadData()
            }
        }
    }
    
    // MARK:- Cell button actions
    @objc func likeAction(sender: UIButton){
        print("like action at: \(sender.tag)")
        
        let tempDict = randomArray[sender.tag] as! NSDictionary
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
                let cell = randomTableView.cellForRow(at: cellIndexPath) as! RandomCell
                cell.likeBtn.setImage(UIImage.init(named: "like-list"), for: .normal)
            }else{
                // add new item
                newArray.addObjects(from: alreadyArray as! [Any])
                newArray.add(dictToSave)
                let cell = randomTableView.cellForRow(at: cellIndexPath) as! RandomCell
                cell.likeBtn.setImage(UIImage.init(named: "like-list-gray"), for: .normal)
            }
            UserDefaults.standard.setValue(newArray, forKey: "LikedItems")
            UserDefaults.standard.synchronize()
        }
    }
    
    @objc func downloadAction(sender: UIButton){
        let cell = self.randomTableView.cellForRow(at: IndexPath.init(row: sender.tag, section: 0)) as! RandomCell
        let size = CGSize.init(width: cell.frame.width, height: cell.topView.frame.height)
        UIGraphicsBeginImageContextWithOptions(size, cell.contentView.isOpaque, 0.0)
        cell.contentView.drawHierarchy(in: cell.contentView.bounds, afterScreenUpdates: false)
        let snapshotImageFromMyView = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        UIImageWriteToSavedPhotosAlbum(snapshotImageFromMyView!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
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
        let toCopy = (randomArray[sender.tag] as! NSDictionary)["Description"] as! String
        UIPasteboard.general.string = toCopy
        self.view.makeToast("Copied", duration: 1.0, position: .bottom)
    }
    
    @objc func shareAction(sender: UIButton){
        let toShare = (randomArray[sender.tag] as! NSDictionary)["Description"] as! String
        let appURL = "https://itunes.apple.com/app/id1476205913"
        let message = "\(toShare)\n\(appURL)"
        
        let messageToShare = [ message ]
        let activityViewController = UIActivityViewController(activityItems: messageToShare , applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
    }
}
