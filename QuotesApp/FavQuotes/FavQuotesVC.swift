//
//  FavQuotesVC.swift
//  QuotesApp
//
//  Created by Absoluit on 19/10/2019.
//  Copyright © 2019 Absoluit. All rights reserved.
//

import UIKit
import GoogleMobileAds

class FavQuotesVC: UIViewController, UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate {

    @IBOutlet weak var favQuotesTableView: UITableView!
    @IBOutlet weak var bannerView: GADBannerView!
    
    var favQuotesArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bannerView.adUnitID = AdsIDS.bannerLive
        bannerView.rootViewController = self
        bannerView.delegate = self
        bannerView.load(GADRequest())
        
        if UserDefaults.standard.value(forKey: "LikedItems") != nil{
            let array = UserDefaults.standard.value(forKey: "LikedItems") as! NSArray
            if array.count != 0{
                favQuotesArray.addObjects(from: array as! [Any])
            }else{
                print("no fav quotes are available")
            }
        }else{
            print("fav quotes are null")
        }
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
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
        return favQuotesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.favQuotesTableView.dequeueReusableCell(withIdentifier: "FavCell") as! FavCell
        let tempDict = favQuotesArray[indexPath.row] as! NSDictionary
        
        cell.detailsLbl.text = tempDict["Description"] as? String ?? ""
        cell.authorLbl.text = tempDict["Author"] as? String ?? "Unknown"
        
        cell.likeBtn.setImage(UIImage.init(named: "like-list-gray"), for: .normal)
        
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
    
    //MARK:- Cell button actions
    @objc func likeAction(sender: UIButton){
        print("like action at: \(sender.tag)")
        
        let tempDict = favQuotesArray[sender.tag] as! NSDictionary
        
        print(favQuotesArray.count)
        self.favQuotesArray.remove(tempDict)
        print(favQuotesArray.count)
        UserDefaults.standard.setValue(favQuotesArray, forKey: "LikedItems")
        UserDefaults.standard.synchronize()
        self.favQuotesTableView.reloadData()
    }
    
    @objc func downloadAction(sender: UIButton){
        let cell = self.favQuotesTableView.cellForRow(at: IndexPath.init(row: sender.tag, section: 0)) as! FavCell
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
        let toCopy = (favQuotesArray[sender.tag] as! NSDictionary)["Description"] as! String
        UIPasteboard.general.string = toCopy
        self.view.makeToast("Copied", duration: 1.0, position: .bottom)
    }
    
    @objc func shareAction(sender: UIButton){
        let toShare = (favQuotesArray[sender.tag] as! NSDictionary)["Description"] as! String
        let appURL = "https://itunes.apple.com/app/id1476205913"
        let message = "\(toShare)\n\(appURL)"
        
        let messageToShare = [ message ]
        let activityViewController = UIActivityViewController(activityItems: messageToShare , applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
    }
}
