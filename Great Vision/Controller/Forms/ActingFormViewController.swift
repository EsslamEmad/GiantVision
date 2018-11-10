//
//  ActingFormViewController.swift
//  Great Vision
//
//  Created by Esslam Emad on 8/10/18.
//  Copyright © 2018 Alyom Apps. All rights reserved.
//

import UIKit
import SVProgressHUD
import PromiseKit
import RZTransitions

class ActingFormViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource {
    
    

    let user = Auth.auth.user!
    var acting = Acting()
    
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
    @IBOutlet weak var favActorsTV: UITextView!
    @IBOutlet weak var reasonTV: UITextView!
    @IBOutlet weak var photosView: UIImageView!
    @IBOutlet weak var photosCollection: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        containerView.clipsToBounds = true
        sendButton.clipsToBounds = true
        containerView.layer.cornerRadius = 15.0
        sendButton.layer.cornerRadius = 15.0
        initializeToolbar()
        photosCollection.dataSource = self
        photosCollection.delegate = self
        reasonTV.clipsToBounds = true
        favActorsTV.clipsToBounds = true
        reasonTV.layer.cornerRadius = 10.0
        favActorsTV.layer.cornerRadius = 10.0
        reasonTV.layer.borderColor = UIColor.darkGray.cgColor
        favActorsTV.layer.borderColor = UIColor.darkGray.cgColor
        reasonTV.layer.borderWidth = 1.0
        favActorsTV.layer.borderWidth = 1.0
        self.transitioningDelegate = RZTransitionsManager.shared()
        if Auth.auth.language == "ar" {
            backButton.setImage(UIImage(named: "right-arrow-2"), for: .normal)
            if Auth.auth.language == "ar" {
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
            }
        }
        self.hideKeyboardWhenTappedAround()
        ageTF.delegate = self
        weightTF.delegate = self
        heightTF.delegate = self
        bootTF.delegate = self
        dressTF.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        subscribeToKeyboardNotifications()
    }

    @IBAction func didPressSend(_ sender: Any) {
        guard let name = nameTF.text, name != "", let nationality = nationalityTF.text, nationality != "", let age = Int(ageTF.text ?? ""), let address = addressTF.text, address != "", let phone = phoneTF.text, phone  != "", let height = Int(heightTF.text ?? ""), let weight = Int(weightTF.text ?? ""), let hair = hairTF.text, hair != "", let skin = skinTF.text, skin != "", let eye = eyeTF.text, eye != "", let dress = Int(dressTF.text ?? ""), let boot = Int(bootTF.text ?? ""), let favActor = favActorsTV.text, favActor != "", let reason = reasonTV.text, reason != "" else {
            self.showAlert(withMessage: NSLocalizedString("من فضلك قم بإكمال البيانات الخاصة بك!", comment: ""))
            return
        }
        guard images.count == 3 else {
            self.showAlert(withMessage: NSLocalizedString("من فضلك قم برفع ٣ صور!", comment: ""))
            return
        }
        acting.name = name
        acting.nationality = nationality
        acting.age = age
        acting.address = address
        acting.phone = phone
        acting.skin = skin
        acting.hair = hair
        acting.eye = eye
        acting.dress = dress
        acting.boot = boot
        acting.favActor = favActor
        acting.reason = reason
        acting.height = height
        acting.weight = weight
        acting.id = user.id
        
        SVProgressHUD.setStatus(NSLocalizedString("من فضلك إنتظر قليلًا حتى يتم رفع الصور", comment: ""))
        SVProgressHUD.show()
        
            firstly{
                return API.CallApi(APIRequests.upload(image: images[0], file: nil))
                }.done {
                    let resp = try! JSONDecoder().decode(UploadResponse.self, from: $0)
                    self.acting.photos.append(resp.image)
                    firstly {
                        return API.CallApi(APIRequests.upload(image: self.images[1], file: nil))
                        }.done {
                            let resp1 = try! JSONDecoder().decode(UploadResponse.self, from: $0)
                            self.acting.photos.append(resp1.image)
                            firstly {
                                return API.CallApi(APIRequests.upload(image: self.images[2], file: nil))
                                }.done {
                                    let resp2 = try! JSONDecoder().decode(UploadResponse.self, from: $0)
                                    self.acting.photos.append(resp2.image)
                                    self.sendRequest()
                                }.catch {
                                    self.showAlert(withMessage: $0.localizedDescription)
                                    SVProgressHUD.dismiss()
                                }
                        }.catch {
                            self.showAlert(withMessage: $0.localizedDescription)
                            SVProgressHUD.dismiss()
                    }
                }.catch {
                    self.showAlert(withMessage: $0.localizedDescription)
                    SVProgressHUD.dismiss()
                }
        
        
    }
    
    func sendRequest() {
        firstly{
            return API.CallApi(APIRequests.addActing(acting: acting))
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
        acting.gender = user.gender
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
            acting.gender = 1
        default:
            sexTF.text = NSLocalizedString("أنثى", comment: "")
            acting.gender = 2
        }
    }
    
    @objc func dismissPicker() {
        view.endEditing(true)
    }
    
    
    //Mark: Image Picker
    
    @IBAction func PickImage(recognizer: UITapGestureRecognizer) {
        
        guard images.count < 3 else {
            self.showAlert(withMessage: NSLocalizedString("لا يمكنك إضافة المزيد من الصور", comment: ""))
            return
        }
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
            images.append(selectedImage)
            photosCollection.reloadData()
            ImagePicked = true
        }
        dismiss(animated: true, completion: nil)
    }
    
    //Mark: CollectionView Protocols

    var images = [UIImage]()
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = collectionView.dequeueReusableCell(withReuseIdentifier: "item", for: indexPath) as! ActingImageCollectionViewCell
        item.image.image = images[indexPath.item]
        item.deleteButton.tag = indexPath.item
        return item
    }
    
    @IBAction func didPressDelete(_ sender: UIButton) {
        images.remove(at: sender.tag)
        photosCollection.reloadData()
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
