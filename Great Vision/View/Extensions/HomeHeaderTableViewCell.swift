//
//  HomeHeaderTableViewCell.swift
//  Giant Vision
//
//  Created by Esslam Emad on 15/10/18.
//  Copyright © 2018 Alyom Apps. All rights reserved.
//

import UIKit

class HomeHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var sideMenuButton: UIButton!
    @IBOutlet weak var logoImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
