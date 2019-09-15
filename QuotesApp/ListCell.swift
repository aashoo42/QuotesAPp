//
//  QuoteCell.swift
//  QuotesApp
//
//  Created by Absoluit on 11/08/2019.
//  Copyright © 2019 Absoluit. All rights reserved.
//

import UIKit

class ListCell: UITableViewCell {

    @IBOutlet weak var detailsLbl: UILabel!
    @IBOutlet weak var authorLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
