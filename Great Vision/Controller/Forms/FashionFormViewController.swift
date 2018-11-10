//
//  FashionFormViewController.swift
//  Great Vision
//
//  Created by Esslam Emad on 9/10/18.
//  Copyright © 2018 Alyom Apps. All rights reserved.
//

import UIKit
import SVProgressHUD
import PromiseKit
import RZTransitions

class FashionFormViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    
    let user = Auth.auth.user!
    var fashion = Fashion()
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var nationalityTF: UITextField!
    @IBOutlet weak var ageTF: UITextField!
    @IBOutlet weak var sexTF: UITextField!
    @IBOutlet weak var addressTF: UITextField!
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var heightTF: UITextField!
    @IBOutlet weak var weightTF: UITextField!
    @IBOutlet weak var skinTF: UITextField!
    @IBOutlet weak var hairTF: UITextField!
    @IBOutlet weak var eyeTF: UITextField!
    @IBOutlet weak var dressTF: UITextField!
    @IBOutlet weak var bootTF: UITextField!
    @IBOutlet weak var bodyTF: UITextField!
    @IBOutlet weak var AbayaTF: UITextField!
    @IBOutlet weak var jeansTF: UITextField!
    @IBOutlet weak var tshirtTF: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        containerView.clipsToBounds = true
        sendButton.clipsToBounds = true
        containerView.layer.cornerRadius = 15.0
        sendButton.layer.cornerRadius = 15.0
        initializeToolbar()
        self.transitioningDelegate = RZTransitionsManager.shared()
        if Auth.auth.language == "ar" {
            backButton.setImage(UIImage(named: "right-arrow-2"), for: .normal)
            nameTF.textAlignment = .right
            nationalityTF.textAlignment = .right
            ageTF.textAlignment = .right
            sexTF.textAlignment = .right
            addressTF.textAlignment = .right
            phoneTF.textAlignment = .right
            heightTF.textAlignment = .right
            weightTF.textAlignment = .right
            skinTF.textAlignment = .right
            hairTF.textAlignment = .right
            eyeTF.textAlignment = .right
            dressTF.textAlignment = .right
            bootTF.textAlignment = .right
            bodyTF.textAlignment = .right
            AbayaTF.textAlignment = .right
            jeansTF.textAlignment = .right
            tshirtTF.textAlignment = .right
        }
        self.hideKeyboardWhenTappedAround()
        ageTF.delegate = self
        heightTF.delegate = self
        weightTF.delegate = self
        tshirtTF.delegate = self
        jeansTF.delegate = self
        AbayaTF.delegate = self
        bootTF.delegate = self
        dressTF.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        subscribeToKeyboardNotifications()
    }
    
    @IBAction func didPressSend(_ sender: Any) {
        guard let name = nameTF.text, name != "", let nationality = nationalityTF.text, nationality != "", let age = Int(ageTF.text ?? ""), let address = addressTF.text, address != "", let phone = phoneTF.text, phone  != "", let height = Int(heightTF.text ?? ""), let weight = Int(weightTF.text ?? ""), let hair = hairTF.text, hair != "", let skin = skinTF.text, skin != "", let eye = eyeTF.text, eye != "", let dress = Int(dressTF.text ?? ""), let boot = Int(bootTF.text ?? ""), let body = bodyTF.text, body != "", let abaya = Int(AbayaTF.text ?? ""), let jeans = Int(jeansTF.text ?? ""), let tshirt  = Int(tshirtTF.text ?? "") else {
            self.showAlert(withMessage: NSLocalizedString("من فضلك قم بإكمال البيانات الخاصة بك!", comment: ""))
            return
        }
        fashion.name = name
        fashion.nationality = nationality
        fashion.age = age
        fashion.address = address
        fashion.phone = phone
        fashion.skin = skin
        fashion.hair = hair
        fashion.eye = eye
        fashion.dress = dress
        fashion.boot = boot
        fashion.height = height
        fashion.weight = weight
        fashion.body = body
        fashion.abaya = abaya
        fashion.jeans = jeans
        fashion.tshirt = tshirt
        fashion.id = user.id
        
        SVProgressHUD.show()
        
        sendRequest()
        
        
    }
    
    func sendRequest() {
        firstly{
            return API.CallApi(APIRequests.addFashion(fashion: fashion))
            }.done{ resp in
                self.showAlert(error: false, withMessage: NSLocalizedString("تم إرسال الإستمارة بنجاح", comment: ""), completion: {(UIAlertAction) in
                    self.dismiss(animated: true, completion: nil)
                })
                self.performMainSegue()
            }.catch {
                self.showAlert(withMessage: $0.localizedDescription)
            }.finally {
                SVProgressHUD.dismiss()
        }
    }
    
    @IBAction func didPressBack(_ sender: Any) {
        
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    //Mark: Sex Picker
    
    private let sexPicker = UIPickerView()
    private var inputAccessoryBar: UIToolbar!
    
    private func initializeSexPicker() {
        sexPicker.delegate = self
        sexPicker.dataSource = self
        sexTF.inputView = sexPicker
        sexTF.inputAccessoryView = inputAccessoryBar
        sexTF.text = user.gender == 1 ? NSLocalizedString("ذكر", comment: "") : NSLocalizedString("أنثى", comment: "")
        fashion.gender = user.gender
    }
    private func initializeToolbar() {
        inputAccessoryBar = UIToolbar(frame: CGRect(x: 0, y:0, width: view.frame.width, height: 44))
        let doneButton = UIBarButtonItem(title: NSLocalizedString("تم", comment: ""), style: .done, target: self, action: #selector(dismissPicker))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        inputAccessoryBar.items = [flexibleSpace, doneButton]
        initializeSexPicker()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch row {
        case 0:
            return NSLocalizedString("ذكر", comment: "")
        default:
            return NSLocalizedString("أنثى", comment: "")
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        switch row {
        case 0:
            sexTF.text = NSLocalizedString("ذكر", comment: "")
            fashion.gender = 1
        default:
            sexTF.text = NSLocalizedString("أنثى", comment: "")
            fashion.gender = 2
        }
    }
    
    @objc func dismissPicker() {
        view.endEditing(true)
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.keyboardType == .numberPad && string != "" {
            let numberStr: String = string
            let formatter: NumberFormatter = NumberFormatter()
            formatter.locale = Locale(identifier: "EN")
            if let final = formatter.number(from: numberStr) {
                textField.text =  "\(textField.text ?? "")\(final)"
            }
            return false
        }
        return true
    }
    
}

