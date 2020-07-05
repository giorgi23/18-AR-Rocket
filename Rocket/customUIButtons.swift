//
//  customUIButtons.swift
//  Rocket
//
//  Created by Giorgi Jashiashvili on 7/4/20.
//  Copyright © 2020 Giorgi Jashiashvili. All rights reserved.
//

import UIKit

class customUIButtons: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func awakeFromNib() {
        super.awakeFromNib()
        customizeButtons()
    }
    
    func customizeButtons() {
        backgroundColor = UIColor.blue
        layer.cornerRadius = 10.0
        layer.borderWidth = 2.0
        layer.borderColor = UIColor.white.cgColor
        
    }

}
