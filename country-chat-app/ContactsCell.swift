//
//  ContactsCell.swift
//  country-chat-app
//
//  Created by Quinto Cossio on 30/9/16.
//  Copyright © 2016 Quinto Cossio. All rights reserved.
//

import UIKit

class ContactsCell: UITableViewCell {

    @IBOutlet weak var userImage: RoundedImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var countryLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
