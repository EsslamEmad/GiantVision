//
//  SideMenu.swift
//  Great Vision
//
//  Created by Esslam Emad on 7/10/18.
//  Copyright © 2018 Alyom Apps. All rights reserved.
//

import UIKit
import RZTransitions

class SideMenu: UITableViewController {

    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var contactUsButton: UIButton!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var aboutUsButton: UIButton!
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var languageButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let imgurl = URL(string: Auth.auth.user!.photo) {
            profilePicture.kf.setImage(with: imgurl)
            profilePicture.clipsToBounds = true
            profilePicture.layer.cornerRadius = profilePicture.frame.width / 2.0
        }
        nameLabel.text = Auth.auth.user?.name
        emailLabel.text = Auth.auth.user?.email
        self.transitioningDelegate = RZTransitionsManager.shared()
    }

    override func viewDidDisappear(_ animated: Bool) {
       // self.dismiss(animated: true, completion: nil)
    }
    

    @IBAction func unwindToSideMenu(_ unwindSegue: UIStoryboardSegue) {
       
    }
    
    @IBAction func didPressHome(_ sender: Any){
        performMainSegue()
    }
    @IBAction func didPressProfile(_ sender: Any){
        performProfileSegue()
    }
    
    @IBAction func didPressSignOut(_ sender: Any) {
        let alert = UIAlertController(title: NSLocalizedString("تسجيل الخروج", comment: ""), message: NSLocalizedString("هل أنت متأكد من رغبتك في تسجيل الخروج؟", comment: ""), preferredStyle: .alert)
        let yesAction = UIAlertAction(title: NSLocalizedString("نعم", comment: ""), style: .default, handler: {(UIAlertAction) in
            Auth.auth.user = nil
            self.performLoginSegue()
        })
        let noAction = UIAlertAction(title: NSLocalizedString("لا", comment: ""), style: .cancel, handler: nil)
        alert.addAction(yesAction)
        alert.addAction(noAction)
        present(alert, animated:  true, completion: nil)
    }
    
    @IBAction func didPressLanguage(_ sender: Any) {
        let alert = UIAlertController(title: NSLocalizedString("اللغة", comment: ""), message: NSLocalizedString("إختر اللغة!", comment: ""), preferredStyle: .actionSheet)
        let eng = UIAlertAction(title: "English", style: .default, handler: {(UIAlertAction) -> Void in
            guard Language.language != .english else{
                return
            }
            Language.language = .english
            self.showAlert(error: false, withMessage: "Please, restart the application to change the language!", completion: nil)
        })
        let ar = UIAlertAction(title: "عربي", style: .default, handler: {(UIAlertAction) -> Void in
            guard Language.language != .arabic else {
                return
            }
            Language.language = .arabic
            self.showAlert(error: false, withMessage: "من فضلك، أعد تشغيل التطبيق لتغيير اللغة", completion: nil)
        })
        let cancel = UIAlertAction(title: NSLocalizedString("إلغاء", comment: ""), style: .cancel, handler: nil)
        alert.addAction(eng)
        alert.addAction(ar)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func performLoginSegue(animated: Bool = true) {
        guard let window = UIApplication.shared.keyWindow else { return }
        guard let rootViewController = window.rootViewController else { return }
        self.dismiss(animated: true, completion: nil)
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        vc.view.frame = rootViewController.view.frame
        vc.view.layoutIfNeeded()
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = vc
        })
    }
    func performMainSegue(animated: Bool = true) {
        guard let window = UIApplication.shared.keyWindow else { return }
        guard let rootViewController = window.rootViewController else { return }
        self.dismiss(animated: true, completion: nil)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MainViewController")
        vc.view.frame = rootViewController.view.frame
        vc.view.layoutIfNeeded()
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = vc
        })
    }
    func performProfileSegue(animated: Bool = true) {
        guard let window = UIApplication.shared.keyWindow else { return }
        guard let rootViewController = window.rootViewController else { return }
        self.dismiss(animated: true, completion: nil)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ProfileViewController")
        vc.view.frame = rootViewController.view.frame
        vc.view.layoutIfNeeded()
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = vc
        })
    }
}
