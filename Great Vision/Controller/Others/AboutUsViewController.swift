//
//  AboutUsViewController.swift
//  Great Vision
//
//  Created by Esslam Emad on 7/10/18.
//  Copyright © 2018 Alyom Apps. All rights reserved.
//

import UIKit
import SVProgressHUD
import PromiseKit
import RZTransitions

class AboutUsViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        SVProgressHUD.show()
        firstly{
            return API.CallApi(APIRequests.getPage(id: 1))
            }.done {
                let page = try! JSONDecoder().decode(Page.self, from: $0)
                self.titleLabel.text = page.title
                self.contentLabel.text = page.content
            }.catch {
                self.showAlert(withMessage: $0.localizedDescription)
            }.finally {
                SVProgressHUD.dismiss()
        }
        self.transitioningDelegate = RZTransitionsManager.shared()
        if Auth.auth.language == "ar" {
            backButton.setImage(UIImage(named: "right-arrow"), for: .normal)
        }
    }
    
    @IBAction func didPressBack(_ sender: Any) {
        performMainSegue()
    }
    func performMainSegue(animated: Bool = true){
        guard let window = UIApplication.shared.keyWindow else { return }
        guard let rootViewController = window.rootViewController else { return }
        self.dismiss(animated: true, completion: nil)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MainViewController")
        vc.view.frame = rootViewController.view.frame
        vc.view.layoutIfNeeded()
        
        UIView.transition(with: window, duration: 0.3, options: .curveEaseInOut, animations: {
            window.rootViewController = vc
        })
    }
    
}

