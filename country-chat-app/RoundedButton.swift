//
//  RoundedButton.swift
//  snapchat-clone
//
//  Created by Quinto Cossio on 16/9/16.
//  Copyright © 2016 Quinto Cossio. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedButton:UIButton{
    
    @IBInspectable var cornerRadius: CGFloat = 0{
        didSet{
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0{
        didSet{
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor:UIColor?{
        didSet{
            layer.borderColor = borderColor?.cgColor
        }
    }
    
    @IBInspectable var bgColor:UIColor?{
        didSet{
            backgroundColor = bgColor
        }
    }
}
