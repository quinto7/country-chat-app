//
//  RoundTextField.swift
//  snapchat-clone
//
//  Created by Quinto Cossio on 16/9/16.
//  Copyright © 2016 Quinto Cossio. All rights reserved.
//

import UIKit

@IBDesignable
class RoundTextField: UITextField{
    
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
    
    @IBInspectable var placeholderColor: UIColor?{
        didSet{
            
            //Forma de evitar un crash, es una especie de if let de Swift 3.Si hay un attributed String se usa rawString. Si es nil se usa un emptyString("")
            let rawString = attributedPlaceholder?.string != nil ? attributedPlaceholder!.string : ""
            
            let str = NSAttributedString(string: rawString, attributes: [NSForegroundColorAttributeName: placeholderColor!])
            attributedPlaceholder = str
        }
    }
}
