//
//  SigningTableViewController.swift
//  Great Vision
//
//  Created by Esslam Emad on 30/9/18.
//  Copyright © 2018 Alyom Apps. All rights reserved.
//

import UIKit
import SVProgressHUD
import RZTransitions
import PromiseKit

class SigningTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    var signingIn = true
    var user = User()
    
    @IBOutlet weak var blackView: UIView!
    @IBOutlet weak var whiteView: UIView!
    @IBOutlet weak var signIngButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginStackView: UIStackView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var eyeButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var forgtoPasswordButton: UIButton!
    @IBOutlet weak var fieldView: UIView!
    @IBOutlet weak var registerFieldsView: UIView!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var nationalityTF: UITextField!
    @IBOutlet weak var ageTF: UITextField!
    @IBOutlet weak var sexTF: UITextField!
    @IBOutlet weak var addressTF: UITextField!
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var heightTF: UITextField!
    @IBOutlet weak var weightTF: UITextField!
    @IBOutlet weak var skinTF: UITextField!
    @IBOutlet weak var worksTV: UITextView!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var finishRegisterButton: UIButton!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var passwordConfirmationTF: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        blackView.layer.cornerRadius = 30
        whiteView.layer.cornerRadius = 30
        fieldView.layer.cornerRadius = 15
        loginButton.layer.cornerRadius = 15
        registerFieldsView.layer.cornerRadius = 15
        finishRegisterButton.layer.cornerRadius = 15
        profilePicture.layer.cornerRadius = 15
        profilePicture.layer.borderWidth = 1
        profilePicture.layer.borderColor = UIColor.darkGray.cgColor
        worksTV.layer.cornerRadius = 15.0
        worksTV.layer.borderWidth = 1
        worksTV.layer.borderColor = UIColor.darkGray.cgColor
        initializeToolbar()
        self.transitioningDelegate = RZTransitionsManager.shared()
        
        if Auth.auth.language == "ar" {
            nameTF.textAlignment = .right
            emailTextField.textAlignment = .right
            passwordTF.textAlignment = .right
            passwordTextField.textAlignment = .right
            passwordConfirmationTF.textAlignment = .right
            emailTF.textAlignment = .right
            nationalityTF.textAlignment = .right
            ageTF.textAlignment = .right
            sexTF.textAlignment = .right
            addressTF.textAlignment = .right
            phoneTF.textAlignment = .right
            heightTF.textAlignment = .right
            weightTF.textAlignment = .right
            skinTF.textAlignment = .right

        }
        
        heightTF.delegate = self
        weightTF.delegate = self
        ageTF.delegate = self
        hideKeyboardWhenTappedAround()
    }
    
    var centerX: NSLayoutConstraint!
    override func viewDidAppear(_ animated: Bool) {
       subscribeToKeyboardNotifications()
        guard !ImagePicked else {
            return
        }
        if Auth.auth.language == "ar"{
            centerX = NSLayoutConstraint(item: whiteView, attribute: .centerX, relatedBy: .equal, toItem: blackView, attribute: .centerX, multiplier: 1.5, constant: -5)}
        else {
            centerX = NSLayoutConstraint(item: whiteView, attribute: .centerX, relatedBy: .equal, toItem: blackView, attribute: .centerX, multiplier: 0.5, constant: 5)
        }
        blackView.addConstraint(centerX)
        didPressSignIn(nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        
    }

    @IBAction func didPressSignIn(_ sender: UIButton?){
        signingIn = true
        self.blackView.removeConstraint(centerX)
        if Auth.auth.language == "ar"{
            centerX = NSLayoutConstraint(item: whiteView, attribute: .centerX, relatedBy: .equal, toItem: blackView, attribute: .centerX, multiplier: 1.5, constant: -5)}
        else {
            centerX = NSLayoutConstraint(item: whiteView, attribute: .centerX, relatedBy: .equal, toItem: blackView, attribute: .centerX, multiplier: 0.5, constant: 5)
        }
        self.blackView.addConstraint(self.centerX)
        UIView.animate(withDuration: 0.3, animations: {
            self.signIngButton.setTitleColor(.black, for: .normal)
            self.registerButton.setTitleColor(.white, for: .normal)
            self.blackView.layoutIfNeeded()
            self.registerFieldsView.alpha = 0
            self.finishRegisterButton.alpha = 0
        }, completion: { finished in
            self.tableView.reloadData()
        })
    }
    @IBAction func didPressRegister(_ sender: UIButton){
        signingIn = false
        
        self.blackView.removeConstraint(centerX)
        if Auth.auth.language == "ar"{
            centerX = NSLayoutConstraint(item: whiteView, attribute: .centerX, relatedBy: .equal, toItem: blackView, attribute: .centerX, multiplier: 0.5, constant: 5)
        }
        else {
            centerX = NSLayoutConstraint(item: whiteView, attribute: .centerX, relatedBy: .equal, toItem: blackView, attribute: .centerX, multiplier: 1.5, constant: -5)
        }
        self.blackView.addConstraint(self.centerX)
        UIView.animate(withDuration: 0.3, animations: {
            self.registerButton.setTitleColor(.black, for: .normal)
            self.signIngButton.setTitleColor(.white, for: .normal)
            self.blackView.layoutIfNeeded()
            self.loginStackView.alpha = 0
            
        }, completion: { finished in
            self.tableView.reloadData()
        })
    }
    
    @IBAction func didPressEye(_ sender: Any){
        passwordTextField.togglePasswordVisibility()
    }
    
    @IBAction func didPressLogin(_ sender: Any){
        guard let email = emailTextField.text, email.isEmail(), let password = passwordTextField.text, password != "" else {
            self.showAlert(withMessage: NSLocalizedString("من فضلك أدخل البريد الإلكتروني و الرقم السري الخاص بك بشكل صحيح.", comment: ""))
            return
        }
        SVProgressHUD.show()
        firstly{
            return API.CallApi(APIRequests.login(email: email, password: password))
            }.done {
                Auth.auth.user = try! JSONDecoder().decode(User.self, from: $0)
                self.performMainSegue()
            }.catch {
                self.showAlert(withMessage: $0.localizedDescription)
            }.finally {
                SVProgressHUD.dismiss()
        }
    }
    
    @IBAction func didPressForgotPassword(_ sender: Any){
        let alert = UIAlertController(title: "", message: NSLocalizedString("من فضلك أدخل بريدك الإلكتروني..", comment: ""), preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = NSLocalizedString("البريد الإلكتروني", comment: "")
        }
        let resetPasswordAction = UIAlertAction(title: NSLocalizedString("إستعادة كلمة المرور", comment: ""), style: .default, handler: { (UIAlertAction) in
            if let textField = alert.textFields?.first{
                guard let email = textField.text, email != "", email.isEmail() else {
                    self.showAlert(error: true, withMessage: NSLocalizedString("من فضلك أدخل بريدك الإلكتروني!", comment: ""), completion: nil)
                    return
                }
                SVProgressHUD.show()
                firstly{
                    return API.CallApi(APIRequests.forgotPassword(email: textField.text!))
                    }.done {
                        let resp = try! JSONDecoder().decode(ResponseMessage.self, from: $0)
                        self.showAlert(error: false, withMessage: resp.message, completion: nil)
                    }.catch {
                        self.showAlert(withMessage: $0.localizedDescription)
                    }.finally {
                        SVProgressHUD.dismiss()
                }
                
            }
        })
        let cancelAction = UIAlertAction(title: NSLocalizedString("إلغاء", comment: ""), style: .cancel, handler: nil)
        alert.addAction(resetPasswordAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func didFinishRegister(_ sender: Any) {
        guard registerAuthentication() else {
            return
        }
        SVProgressHUD.show()
        firstly{
            return API.CallApi(APIRequests.upload(image: profilePicture.image!, file: nil))
            }.done {
                let resp = try! JSONDecoder().decode(UploadResponse.self, from: $0)
                self.user.photo = resp.image
                firstly {
                    return API.CallApi(APIRequests.register(user: self.user))
                    }.done {
                        Auth.auth.user = try! JSONDecoder().decode(User.self, from: $0)
                        self.performMainSegue()
                        }.catch {
                        self.showAlert(withMessage: $0.localizedDescription)
                    }.finally {
                        SVProgressHUD.dismiss()
                }
            }.catch {
                self.showAlert(withMessage: $0.localizedDescription)
                SVProgressHUD.dismiss()
        }
    }
    
    func registerAuthentication() -> Bool {
        guard let name = nameTF.text, name != "", let email = emailTF.text, email.isEmail(), let password = passwordTF.text, password != "", let nationality = nationalityTF.text, nationality != "", let age = Int(ageTF.text ?? ""), let address = addressTF.text, address != "", let sex = sexTF.text, sex != "", let weight = Int(weightTF.text ?? ""), let height = Int(heightTF.text ?? ""), let phone = phoneTF.text, phone != "", let works = worksTV.text, works != "", let skin = skinTF.text, skin != "", ImagePicked else {
            self.showAlert(withMessage: NSLocalizedString("من فضلك أدخل جميع بياناتك!", comment: ""))
            return false
        }
        guard passwordTF.text == passwordConfirmationTF.text else {
            self.showAlert(withMessage: NSLocalizedString("الرقم السري غير متطابق.", comment: ""))
            return false
        }
        let formatter: NumberFormatter = NumberFormatter()
        formatter.locale = NSLocale(localeIdentifier: "EN") as Locale
        
        
        
        /*guard let ageNum = formatter.number(from: age), let ageInt = Int(ageNum), let weightNum = formatter.number(from: weight), let weightInt = Int(truncating: weightNum), let heightNum = formatter.number(from: height), let heightInt = Int(truncating: heightNum) else {
            self.showAlert(withMessage: NSLocalizedString("من فضلك أدخل جميع بياناتك!", comment: ""))
            return false
        }*/
        
        user.name = name
        user.email = email
        user.password = password
        user.age = age
        user.address = address
        user.gender = sex == NSLocalizedString("ذكر", comment: "") ? 1 : 2
        user.nationality = nationality
        user.height = height
        user.weight = weight
        user.skin = skin
        user.works = works
        user.phone = phone
        return true
    }
    
    
    func performMainSegue(animated: Bool = true){
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
    
    // MARK: - Table view data source

    
    
    var height1 = 320
    var height2 = 70
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            guard signingIn else {
                return 0
            }
            return CGFloat(height1)
        case 1:
            return CGFloat(height2)
        case 2:
            guard signingIn else {
                return 0
            }
            let height3 = UIScreen.main.bounds.height - CGFloat(height2 + height1 + 75)
            return height3 > 310.0 ? height3 : 310.0
        case 3:
            guard !signingIn else {
                return 0
            }
            let height3 = UIScreen.main.bounds.height - CGFloat(height2 + 50)
            return height3
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        var centerXChanging: NSLayoutConstraint!
        switch indexPath.row {
        
        case 2:
            centerXChanging = NSLayoutConstraint(item: self.loginStackView, attribute: .centerX, relatedBy: .equal, toItem: self.tableView, attribute: .centerX, multiplier: 1, constant: -1000)
            self.tableView.addConstraint(centerXChanging)
            self.tableView.layoutIfNeeded()
            self.tableView.removeConstraint(centerXChanging)
            centerXChanging = NSLayoutConstraint(item: self.loginStackView, attribute: .centerX, relatedBy: .equal, toItem: self.tableView, attribute: .centerX, multiplier: 1, constant: 0)
            self.tableView.addConstraint(centerXChanging)
            UIView.animate(withDuration: 0.8, animations: {
                self.loginStackView.alpha = 1
                self.tableView.layoutIfNeeded()
            })
        case 3:
            centerXChanging = NSLayoutConstraint(item: self.registerFieldsView, attribute: .centerX, relatedBy: .equal, toItem: self.tableView, attribute: .centerX, multiplier: 1, constant: 1000)
            self.tableView.addConstraint(centerXChanging)
            self.tableView.layoutIfNeeded()
            self.tableView.removeConstraint(centerXChanging)
            centerXChanging = NSLayoutConstraint(item: self.registerFieldsView, attribute: .centerX, relatedBy: .equal, toItem: self.tableView, attribute: .centerX, multiplier: 1, constant: 0)
            self.tableView.addConstraint(centerXChanging)
            UIView.animate(withDuration: 0.8, animations: {
                self.registerFieldsView.alpha = 1
                self.finishRegisterButton.alpha = 1
                self.tableView.layoutIfNeeded()
            })
        default: UIView.animate(withDuration: 0.5, animations: {
            self.tableView.layoutIfNeeded()
        })
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
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
        sexTF.text = NSLocalizedString("ذكر", comment: "")
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
        default:
            sexTF.text = NSLocalizedString("أنثى", comment: "")
        }
    }
    
    @objc func dismissPicker() {
        view.endEditing(true)
    }
    
    //Mark: Image Picker
    
    @IBAction func PickImage(recognizer: UITapGestureRecognizer) {
        
        let alert = UIAlertController(title: "", message: NSLocalizedString("اختر طريقة رفع الصورة.", comment: ""), preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: NSLocalizedString("الكاميرا", comment: ""), style: .default, handler: {(UIAlertAction) -> Void in
            SVProgressHUD.show()
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.allowsEditing = false
                picker.sourceType = .camera
                self.present(picker, animated: true, completion: {() -> Void in SVProgressHUD.dismiss()})
            }
            else{
                SVProgressHUD.dismiss()
                self.showAlert(withMessage: NSLocalizedString("التطبيق لا يستطيع الوصول إلى الكاميرا الخاصة بك", comment: ""))
            }
        })
        let photoAction = UIAlertAction(title: NSLocalizedString("مكتبة الصور", comment: ""), style: .default, handler: {(UIAlertAction) -> Void in
            SVProgressHUD.show()
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.allowsEditing = false
                picker.sourceType = .photoLibrary
                self.present(picker, animated: true, completion: {() -> Void in SVProgressHUD.dismiss()})
            }
            else{
                SVProgressHUD.dismiss()
                self.showAlert(withMessage: NSLocalizedString("التطبيق لا يستطيع الوصول إلى مكتبة الصور الخاصة بك", comment: ""))
            }
        })
        let cancelAction = UIAlertAction(title: NSLocalizedString("إلغاء", comment: ""), style: .cancel, handler: nil)
        
        alert.addAction(cameraAction)
        alert.addAction(photoAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    var ImagePicked = false
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        if let selectedImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage{
            profilePicture.image = selectedImage
            profilePicture.contentMode = .scaleAspectFill
            profilePicture.clipsToBounds = true
            ImagePicked = true
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let aligh : NSTextAlignment = Auth.auth.language == "ar" ? .right : .left
        textField.textAlignment = textField.text?.count == 0 ? aligh : NSTextAlignment.natural
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.textAlignment = NSTextAlignment.natural
        return true
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

//Mark: toggling text field security without losing characters
extension UITextField {
    func togglePasswordVisibility() {
        isSecureTextEntry = !isSecureTextEntry
        
        if let existingText = text, isSecureTextEntry {
            /* When toggling to secure text, all text will be purged if the user
             continues typing unless we intervene. This is prevented by first
             deleting the existing text and then recovering the original text. */
            deleteBackward()
            
            if let textRange = textRange(from: beginningOfDocument, to: endOfDocument) {
                replace(textRange, withText: existingText)
            }
        }
        
        /* Reset the selected text range since the cursor can end up in the wrong
         position after a toggle because the text might vary in width */
        if let existingSelectedTextRange = selectedTextRange {
            selectedTextRange = nil
            selectedTextRange = existingSelectedTextRange
        }
    }
}

extension String {
    func isEmail() -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: self)
    }
    
    
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}


