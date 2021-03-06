//
//  TimelineCell.swift
//  Chirpy
//
//  Created by Alexander Strandberg on 6/27/16.
//  Copyright © 2016 Alexander Strandberg. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class TimelineCell: UITableViewCell {
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var tweetText: TTTAttributedLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
