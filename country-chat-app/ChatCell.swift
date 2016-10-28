//
//  ChatCell.swift
//  country-chat-app
//
//  Created by Quinto Cossio on 22/10/16.
//  Copyright © 2016 Quinto Cossio. All rights reserved.
//

import UIKit

class ChatCell: UITableViewCell {

    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var lastMessageLbl: UILabel!
    @IBOutlet weak var userImage: RoundedImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
