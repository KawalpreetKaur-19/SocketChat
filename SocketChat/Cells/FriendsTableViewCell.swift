//
//  FriendsTableViewCell.swift
//  ChatDemo
//
//  Created by Kawalpreet Kaur on 12/4/18.
//  Copyright © 2018 Kawalpreet Kaur. All rights reserved.
//

import UIKit

class FriendsTableViewCell: UITableViewCell {

    @IBOutlet weak var imageViewForFriends: UIImageView!
    @IBOutlet weak var lblForNAme: UILabel!
    
    @IBOutlet weak var lblForAvailability: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
