//
//  ContactUsViewController.swift
//  Great Vision
//
//  Created by Esslam Emad on 7/10/18.
//  Copyright © 2018 Alyom Apps. All rights reserved.
//

import UIKit
import SVProgressHUD
import PromiseKit
import RZTransitions

class ContactUsViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var messageTV: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        containerView.clipsToBounds = true
        sendButton.clipsToBounds = true
        containerView.layer.cornerRadius = 15.0
        sendButton.layer.cornerRadius = 15.0
        messageTV.layer.borderColor = UIColor.darkGray.cgColor
        messageTV.layer.borderWidth = 1.0
        messageTV.layer.cornerRadius = 5.0
        self.transitioningDelegate = RZTransitionsManager.shared()
        if Auth.auth.language == "ar" {
            backButton.setImage(UIImage(named: "right-arrow-2"), for: .normal)
            nameTF.textAlignment = .right
            emailTF.textAlignment = .right
        }
        self.hideKeyboardWhenTappedAround()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        subscribeToKeyboardNotifications()
    }
    
    @IBAction func didPressBack(_ sender: Any){
        performMainSegue()
    }
    
    @IBAction func didPressSend(_ sender: Any){
        guard let name = nameTF.text, name != "", let email = emailTF.text, email.isEmail(), let message = messageTV.text, message != "" else {
            self.showAlert(withMessage: NSLocalizedString("قم بإدخال البيانات بشكل كامل", comment: ""))
            return
        }
        SVProgressHUD.show()
        firstly{
            return API.CallApi(APIRequests.contactUs(name: name, email: email, message: message))
            }.done {
                let resp = try! JSONDecoder().decode(ResponseMessage.self, from: $0)
                self.showAlert(error: false, withMessage: resp.message, completion: {(UIAlertAction) in
                    self.dismiss(animated: true, completion: nil)
                })
                self.performMainSegue()
            }.catch {
                self.showAlert(withMessage: $0.localizedDescription)
            }.finally {
                SVProgressHUD.dismiss()
        }
    }
    
    func performMainSegue(animated: Bool = true){
        guard let window = UIApplication.shared.keyWindow else { return }
        guard let rootViewController = window.rootViewController else { return }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MainViewController")
        vc.view.frame = rootViewController.view.frame
        vc.view.layoutIfNeeded()
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = vc
        })
    }
    

}
