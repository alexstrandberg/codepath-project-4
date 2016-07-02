//
//  CustomHeaderView.swift
//  Chirpy
//
//  Created by Alexander Strandberg on 7/1/16.
//  Copyright © 2016 Alexander Strandberg. All rights reserved.
//

import UIKit

class CustomHeaderView: UIView {
    
    @IBOutlet var label: UILabel!

    override func layoutSubviews() {
        super.layoutSubviews()
        label.preferredMaxLayoutWidth = label.bounds.width
    }
    

}
