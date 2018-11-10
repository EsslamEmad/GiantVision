//
//  LanguageSetViewController.swift
//  Fariqak
//
//  Created by Esslam Emad on 16/5/18.
//  Copyright © 2018 Esslam Emad. All rights reserved.
//

import UIKit
import Foundation
import RZTransitions

class LanguageSetViewController: UIViewController {
    
    @IBOutlet weak var arButton: UIButton!
    @IBOutlet weak var enButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arButton.clipsToBounds = true
        enButton.clipsToBounds = true
        arButton.layer.cornerRadius = 25
        enButton.layer.cornerRadius = 25
        self.transitioningDelegate = RZTransitionsManager.shared()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func arSet(_ sender: Any?){
        Language.language = Language.arabic
        performMainSegue()
        
    }
    @IBAction func enSet(_ sender: Any?){
        Language.language = Language.english
        performMainSegue()
    }
    
    func performMainSegue (animated: Bool = true)
    {
        guard let window = UIApplication.shared.keyWindow else { return }
        guard let rootViewController = window.rootViewController else { return }
        //self.dismiss(animated: true, completion: nil)
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        vc.view.frame = rootViewController.view.frame
        vc.view.layoutIfNeeded()
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = vc
        })    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
}
