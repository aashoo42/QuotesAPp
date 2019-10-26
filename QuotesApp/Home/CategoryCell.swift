//
//  CategoryCell.swift
//  QuotesApp
//
//  Created by Absoluit on 18/10/2019.
//  Copyright © 2019 Absoluit. All rights reserved.
//

import UIKit

class CategoryCell: UICollectionViewCell {
    
    @IBOutlet weak var categoryImg: UIImageView!
    @IBOutlet weak var categoryTitleLbl: UILabel!
    @IBOutlet weak var categoryDetailsLbl: UILabel!
    
    
    override func awakeFromNib() {
        layer.masksToBounds = true
        layer.cornerRadius = 10.0
        
        categoryImg.layer.masksToBounds = true
        categoryImg.layer.cornerRadius = categoryImg.frame.height/2
    }
}
