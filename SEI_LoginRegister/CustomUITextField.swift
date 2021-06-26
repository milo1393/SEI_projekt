//
//  CustomUITextField.swift
//  SEI_LoginRegister
//
//  Created by Marko Milosavljevic on 26.06.21.
//

import UIKit
import NoveFeatherIcons

class CustomUITextField: UITextField {
    
    let icon: UIImage
    var placeholderText = "Input Text" //default value
    
    init(icon: UIImage?, placeholder: String, frame: CGRect) {
        if let checkIcon = icon {
            self.icon = checkIcon
        } else {
            self.icon = UIImage()
        }
        self.placeholderText = placeholder
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(icon: UIImage?, placeholder: String, coder: NSCoder) {
        if let checkIcon = icon {
            self.icon = checkIcon
        } else {
            self.icon = UIImage()
        }
        self.placeholderText = placeholder
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func commonInit(){
        self.leftViewMode = .always
        self.placeholder = placeholderText
        self.autocapitalizationType = .none
        self.autocorrectionType = .no
        self.returnKeyType = .done
        self.layer.cornerRadius = 12
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.setIcon(icon,color: .lightGray) // add icon
        self.setRightPaddingPoints(10) //space in field (made with Extensions)
        self.backgroundColor = .white
    }
    
    func setIcon(_ image: UIImage?, color: UIColor) {
       let iconView = UIImageView(frame:
                      CGRect(x: 10, y: 5, width: 20, height: 20))
       iconView.image = image
       let iconContainerView: UIView = UIView(frame:
                      CGRect(x: 20, y: 20, width: 35, height: 30))
        iconView.tintColor = color
       iconContainerView.addSubview(iconView)
       leftView = iconContainerView
       leftViewMode = .always
    }
}
