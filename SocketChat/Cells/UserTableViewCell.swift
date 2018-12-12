//
//  UserTableViewCell.swift
//  ChatDemo
//
//  Created by Kawalpreet Kaur on 12/4/18.
//  Copyright © 2018 Kawalpreet Kaur. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {

    @IBOutlet weak var lblForMessage: UILabel!
    @IBOutlet weak var lblForTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
