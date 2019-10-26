//
//  RandomCell.swift
//  QuotesApp
//
//  Created by Absoluit on 26/10/2019.
//  Copyright © 2019 Absoluit. All rights reserved.
//

import UIKit

class RandomCell: UITableViewCell {

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var detailsLbl: UILabel!
    @IBOutlet weak var authorLbl: UILabel!
    
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var downloadBtn: UIButton!
    @IBOutlet weak var copyBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        topView.layer.masksToBounds = true
        topView.layer.cornerRadius = 15.0
        
        bottomView.layer.masksToBounds = true
        bottomView.layer.cornerRadius = 5.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
