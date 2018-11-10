//
//  ProfileViewController.swift
//  Great Vision
//
//  Created by Esslam Emad on 6/10/18.
//  Copyright © 2018 Alyom Apps. All rights reserved.
//

import UIKit
import RZTransitions
import SideMenu

class ProfileViewController: UIViewController {

    
    @IBOutlet weak var ProfilePicture: UIImageView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var nationalityLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var phonePhoto: UIImageView!
    @IBOutlet weak var nationalityPhoto: UIImageView!
    @IBOutlet weak var heightPhoto: UIImageView!
    @IBOutlet weak var weightPhoto: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let user = Auth.auth.user
        ProfilePicture.clipsToBounds = true
        editButton.clipsToBounds = true
            ProfilePicture.layer.cornerRadius = ProfilePicture.frame.width / 2
        editButton.layer.cornerRadius = editButton.frame.width / 2
        if let url = URL(string: user!.photo){
            ProfilePicture.kf.setImage(with: url)
        }
        nameLabel.text = user!.name
        emailLabel.text = user!.email
        phoneLabel.text = user!.phone
        nationalityLabel.text = user!.nationality
        heightLabel.text = String(user!.height)
        weightLabel.text = String(user!.weight)
        self.transitioningDelegate = RZTransitionsManager.shared()
        
        if Auth.auth.language == "ar"{
            phonePhoto.image = UIImage(named: "path_958")
            nationalityPhoto.image = UIImage(named: "Path 958")
            heightPhoto.image = UIImage(named: "path_958")
            weightPhoto.image = UIImage(named: "Path 958")
        }

    }
    
    @IBAction func didPressEdit(_ sender: Any) {
        
    }
    
    @IBAction func didPressSideMenu(_ sender: Any) {
        let sideMenu = storyboard?.instantiateViewController(withIdentifier: "SideMenu") as! UISideMenuNavigationController
        if Auth.auth.language == "en"{
            sideMenu.leftSide = true
        }
        present(sideMenu, animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }

    @IBAction func unwindToProfile(_ unwindSegue: UIStoryboardSegue) {
        viewDidLoad()
    }
}
