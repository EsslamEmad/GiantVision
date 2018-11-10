//
//  CategoryTableViewCell.swift
//  Great Vision
//
//  Created by Esslam Emad on 4/10/18.
//  Copyright © 2018 Alyom Apps. All rights reserved.
//

import UIKit

class CategoryTableViewCell: UITableViewCell {

    @IBOutlet weak var view: UIView!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var bigArrow: UIImageView!
    @IBOutlet weak var smallArrow: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let path = UIBezierPath()
        if Auth.auth.language == "ar" {
        
            bigArrow.image = UIImage(named: "path_960")
            smallArrow.image = UIImage(named: "path_959")
            
            let constraint1 = NSLayoutConstraint(item: view, attribute: .right, relatedBy: .equal, toItem: self.contentView, attribute: .right, multiplier: 1, constant: 0)
            let constraint2 = NSLayoutConstraint(item: view, attribute: .left, relatedBy: .equal, toItem: smallArrow, attribute: .left, multiplier: 1, constant: 25)
            let constraint3 = NSLayoutConstraint(item: smallArrow, attribute: .left, relatedBy: .equal, toItem: bigArrow, attribute: .left, multiplier: 1, constant: 26)
            let constraint4 = NSLayoutConstraint(item: photo, attribute: .right, relatedBy: .equal, toItem: self.contentView, attribute: .right, multiplier: 1, constant: -96)
            let constraint5 = NSLayoutConstraint(item: photo, attribute: .left, relatedBy: .equal, toItem: self.contentView, attribute: .left, multiplier: 1, constant: 0)
            
            self.contentView.addConstraint(constraint1)
            self.contentView.addConstraint(constraint2)
            self.contentView.addConstraint(constraint3)
            self.contentView.addConstraint(constraint4)
            self.contentView.addConstraint(constraint5)
            self.contentView.layoutIfNeeded()
            path.move(to: CGPoint(x: 54, y: 0))
            path.addLine(to: CGPoint(x: view.frame.width, y: 0))
            path.addLine(to: CGPoint(x: self.view.frame.width, y: self.bounds.height))
            path.addLine(to: CGPoint(x: 54, y: self.bounds.height))
            path.addLine(to: CGPoint(x: 0, y: self.bounds.height / 2))
        }
        else {
            
            let constraint1 = NSLayoutConstraint(item: view, attribute: .left, relatedBy: .equal, toItem: self.contentView, attribute: .left, multiplier: 1, constant: 0)
            let constraint2 = NSLayoutConstraint(item: view, attribute: .right, relatedBy: .equal, toItem: smallArrow, attribute: .left, multiplier: 1, constant: 55)
            let constraint3 = NSLayoutConstraint(item: smallArrow, attribute: .right, relatedBy: .equal, toItem: bigArrow, attribute: .right, multiplier: 1, constant: -26)
            let constraint4 = NSLayoutConstraint(item: photo, attribute: .left, relatedBy: .equal, toItem: self.contentView, attribute: .left, multiplier: 1, constant: 96)
            let constraint5 = NSLayoutConstraint(item: photo, attribute: .right, relatedBy: .equal, toItem: self.contentView, attribute: .right, multiplier: 1, constant: 0)
            self.contentView.addConstraint(constraint1)
            self.contentView.addConstraint(constraint2)
            self.contentView.addConstraint(constraint3)
            self.contentView.addConstraint(constraint4)
            self.contentView.addConstraint(constraint5)
            self.contentView.layoutIfNeeded()
            path.move(to: CGPoint(x: self.view.frame.width - 54, y: 0))
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 0, y: self.bounds.height))
            path.addLine(to: CGPoint(x: self.view.frame.width - 54, y: self.bounds.height))
            path.addLine(to: CGPoint(x: self.view.frame.width, y: self.bounds.height / 2))
        }
        path.close()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        
        view.layer.mask = shapeLayer
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
