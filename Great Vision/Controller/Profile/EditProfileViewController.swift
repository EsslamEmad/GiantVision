//
//  EditProfileViewController.swift
//  Great Vision
//
//  Created by Esslam Emad on 7/10/18.
//  Copyright © 2018 Alyom Apps. All rights reserved.
//

import UIKit
import SVProgressHUD
import PromiseKit
import RZTransitions

class EditProfileViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    let user = Auth.auth.user
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var passwordConfirmationTF: UITextField!
    @IBOutlet weak var nationalityTF: UITextField!
    @IBOutlet weak var ageTF: UITextField!
    @IBOutlet weak var sexTF: UITextField!
    @IBOutlet weak var addressTF: UITextField!
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var heightTF: UITextField!
    @IBOutlet weak var weightTf: UITextField!
    @IBOutlet weak var skinTF: UITextField!
    @IBOutlet weak var worksTV: UITextView!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        containerView.clipsToBounds = true
        editButton.clipsToBounds = true
        containerView.layer.cornerRadius = 15.0
        editButton.layer.cornerRadius = 15.0
        nameTF.text = user?.name
        emailTF.text = user?.email
        nationalityTF.text = user?.nationality
        ageTF.text = String(user!.age)
        addressTF.text = user?.address
        phoneTF.text = user?.phone
        heightTF.text = String(user!.height)
        weightTf.text = String(user!.weight)
        skinTF.text = user?.skin
        worksTV.text = user?.works
        if let url = URL(string: user!.photo){
            photo.kf.setImage(with: url)
        }
        photo.contentMode = .scaleAspectFill
        photo.clipsToBounds = true
        initializeToolbar()
        self.transitioningDelegate = RZTransitionsManager.shared()
        if Auth.auth.language == "ar" {
            backButton.setImage(UIImage(named: "right-arrow-2"), for: .normal)
            nameTF.textAlignment = .right
            passwordTF.textAlignment = .right
            passwordConfirmationTF.textAlignment = .right
            emailTF.textAlignment = .right
            nationalityTF.textAlignment = .right
            ageTF.textAlignment = .right
            sexTF.textAlignment = .right
            addressTF.textAlignment = .right
            phoneTF.textAlignment = .right
            heightTF.textAlignment = .right
            weightTf.textAlignment = .right
            skinTF.textAlignment = .right
            

        }
        self.hideKeyboardWhenTappedAround()
        ageTF.delegate = self
        heightTF.delegate = self
        weightTf.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        subscribeToKeyboardNotifications()
    }
    
    
    @IBAction func didPressBack(_ sender: Any) {
    }
    
    @IBAction func didPressEdit(_ sender: Any) {
        guard let name = nameTF.text, name != "", let email = emailTF.text, email.isEmail(), let password = passwordTF.text, let nationality = nationalityTF.text, nationality != "", let age = Int(ageTF.text ?? ""), let address = addressTF.text, address != "", let sex = sexTF.text, sex != "", let weight = Int(weightTf.text ?? ""), let height = Int(heightTF.text ?? ""), let phone = phoneTF.text, phone != "", let works = worksTV.text, works != "", let skin = skinTF.text, skin != "" else {
            self.showAlert(withMessage: NSLocalizedString("من فضلك أدخل جميع بياناتك!", comment: ""))
            return
        }
        guard passwordTF.text == passwordConfirmationTF.text else {
            self.showAlert(withMessage: NSLocalizedString("الرقم السري غير متطابق.", comment: ""))
            return
        }
        var user1 = User()
        if name != user?.name{
            user1.name = name
        }
        if email != user?.email{
            user1.email = email
        }
        if password != ""{
            user1.password = password
        }
        if nationality != user?.nationality{
            user1.nationality = nationality
        }
        if age != user?.age{
            user1.age = age
        }
        if address != user?.address{
            user1.address = address
        }
        let sexInt = sex == NSLocalizedString("ذكر", comment: "") ? 1 : 2
        if sexInt != user?.gender {
            user1.gender = sexInt
        }
        if phone != user?.phone {
            user1.phone = phone
        }
        if height != user?.height{
            user1.height = height
        }
        if weight != user?.weight{
            user1.weight = weight
        }
        if skin != user?.skin {
            user1.skin = skin
        }
        if works != user?.works {
            user1.works = works
        }
        
        if ImagePicked{
            SVProgressHUD.show()
            firstly{
                return API.CallApi(APIRequests.upload(image: photo.image!, file: nil))
                }.done {
                    let resp = try! JSONDecoder().decode(UploadResponse.self, from: $0)
                    user1.photo = resp.image
                    self.editUserRequest(user1: user1)
                }.catch {
                    self.showAlert(withMessage: $0.localizedDescription)
                    SVProgressHUD.dismiss()
            }
        } else {
            editUserRequest(user1: user1)
        }
        
    }
    
    func editUserRequest(user1: User) {
        firstly {
            return API.CallApi(APIRequests.editUser(variables: user1, id: Auth.auth.user!.id))
            }.done {
                Auth.auth.user = try! JSONDecoder().decode(User.self, from: $0)
                self.performSegue(withIdentifier: "back to profile", sender: nil)
            }.catch {
                self.showAlert(withMessage: $0.localizedDescription)
            }.finally {
                SVProgressHUD.dismiss()
        }
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
        sexTF.text = user?.gender == 1 ? NSLocalizedString("ذكر", comment: "") : NSLocalizedString("أنثى", comment: "")
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
            photo.image = selectedImage
            ImagePicked = true
        }
        dismiss(animated: true, completion: nil)
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

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}


extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
