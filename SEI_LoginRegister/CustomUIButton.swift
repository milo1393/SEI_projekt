//
//  CustomUIButton.swift
//  SEI_LoginRegister
//
//  Created by Marko Milosavljevic on 26.06.21.
//

import UIKit

class CustomUIButton: UIButton {

    var title = "Input Text" //default value
    var color = UIColor(named: "primary")
    
    init(title: String, color: UIColor?, frame: CGRect) {
        self.title = title
        if let c = color {
            self.color = c
        }
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(title: String,color: UIColor?, coder: NSCoder) {
        if let c = color {
            self.color = c
        }
        self.title = title
        super.init(coder: coder)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit(){
        self.setTitle(title, for: .normal)
        self.backgroundColor = color
        self.setTitleColor(.white, for: .normal)
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        self.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
    }

}
