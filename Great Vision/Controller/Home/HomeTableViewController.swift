//
//  HomeTableViewController.swift
//  Great Vision
//
//  Created by Esslam Emad on 4/10/18.
//  Copyright © 2018 Alyom Apps. All rights reserved.
//

import UIKit
import Kingfisher
import RZTransitions
import SideMenu
import PromiseKit

class HomeTableViewController: UITableViewController {

    
    var categories = [Category]()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categories = Auth.auth.categories
        self.transitioningDelegate = RZTransitionsManager.shared()
        firstly{
            return API.CallApi(APIRequests.getCategories)
            }.done {
                Auth.auth.categories = try! JSONDecoder().decode([Category].self, from: $0)
            }.catch { error in
            }.finally {
                self.tableView.reloadData()
        }

        
    }
    
    @IBAction func unwindToHome(_ unwindSegue: UIStoryboardSegue) {
        
    }
    
    @IBAction func didPressSideMenu(_ sender: Any) {
        let sideMenu = storyboard?.instantiateViewController(withIdentifier: "SideMenu") as! UISideMenuNavigationController
        if Auth.auth.language == "en"{
            sideMenu.leftSide = true
        }
        present(sideMenu, animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categories.count + 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row{
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Header", for: indexPath) as! HomeHeaderTableViewCell
            
            if Auth.auth.language == "en"{
                let buttonConstraint = NSLayoutConstraint(item: cell.sideMenuButton, attribute: .left, relatedBy: .equal, toItem: cell.contentView, attribute: .left, multiplier: 1.0, constant: 8)
                let logoConstraint = NSLayoutConstraint(item: cell.logoImage, attribute: .right, relatedBy: .equal, toItem: cell.contentView, attribute: .right, multiplier: 1.0, constant: 70.0)
                cell.contentView.addConstraint(buttonConstraint)
                cell.contentView.addConstraint(logoConstraint)
            }
            else {
                let buttonConstraint = NSLayoutConstraint(item: cell.sideMenuButton, attribute: .right, relatedBy: .equal, toItem: cell.contentView, attribute: .right, multiplier: 1.0, constant: -8)
                let logoConstraint = NSLayoutConstraint(item: cell.logoImage, attribute: .left, relatedBy: .equal, toItem: cell.contentView, attribute: .left, multiplier: 1.0, constant: -70.0)
                cell.contentView.addConstraint(buttonConstraint)
                cell.contentView.addConstraint(logoConstraint)
            }
            
            
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Category") as! CategoryTableViewCell
            if let url = URL(string: categories[indexPath.row - 1].photo){
                cell.photo.kf.indicatorType = .activity
                cell.photo.kf.setImage(with: url)
            }
            cell.name.text = categories[indexPath.row - 1].title
            
            if Auth.auth.language == "en"{
                
            }
            
            return cell
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 130
        default:
            return 190
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row != 0 else {
            return
        }
        switch categories[indexPath.row - 1].id {
        case 1:
            performSegue(withIdentifier: "show acting", sender: nil)
        case 2:
            performSegue(withIdentifier: "show fashion", sender: nil)
        case 3:
            performSegue(withIdentifier: "show voice", sender: nil)
        default: return
        }
    }
    
    

}
