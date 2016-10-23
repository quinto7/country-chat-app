//
//  RoundedImageView.swift
//  country-chat-app
//
//  Created by Quinto Cossio on 18/9/16.
//  Copyright © 2016 Quinto Cossio. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedImageView: UIImageView{
    
    @IBInspectable var cornerRadius:CGFloat = 0{
        didSet{
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
            
        }
    }
    
    
    
//    //TODO : Put shadows to the picture and a placeholder
//    
//    layer.shadowColor = UIColor(red: SHADOW_COLOR, green: SHADOW_COLOR, blue: SHADOW_COLOR, alpha: 0.5).cgColor
//    layer.shadowOpacity = 0.8
//    layer.shadowRadius = frame.size.width / 2
    
    
    
}
