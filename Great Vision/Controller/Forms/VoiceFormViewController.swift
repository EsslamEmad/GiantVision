//
//  VoiceFormViewController.swift
//  Great Vision
//
//  Created by Esslam Emad on 9/10/18.
//  Copyright © 2018 Alyom Apps. All rights reserved.
//

import UIKit
import SVProgressHUD
import PromiseKit
import RZTransitions
import AVFoundation

class VoiceFormViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    
    
    let user = Auth.auth.user!
    var voice = Voice()
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer : AVAudioPlayer!
    var meterTimer:Timer!
    var isRecording = false
    var isPlaying = false
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var nationalityTF: UITextField!
    @IBOutlet weak var ageTF: UITextField!
    @IBOutlet weak var sexTF: UITextField!
    @IBOutlet weak var addressTF: UITextField!
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var recordPhoto: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        containerView.clipsToBounds = true
        sendButton.clipsToBounds = true
        containerView.layer.cornerRadius = 15.0
        sendButton.layer.cornerRadius = 15.0
        recordPhoto.clipsToBounds = true
        recordPhoto.layer.cornerRadius = 15.0
        recordPhoto.layer.borderColor = UIColor.darkGray.cgColor
        recordPhoto.layer.borderWidth = 1.0
        playButton.layer.cornerRadius = 32.0
        playButton.clipsToBounds = true
        playButton.alpha =  1
        playButton.isEnabled = false
        initializeToolbar()
        self.transitioningDelegate = RZTransitionsManager.shared()
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(AVAudioSession.Category.playAndRecord, mode: .default, options: .defaultToSpeaker)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.recordPhoto.isUserInteractionEnabled = true
                    } else {
                        self.showAlert(withMessage: NSLocalizedString("التطبيق لا يستطيع استخدام المايكروفون الخاص بك", comment: ""))
                        self.recordPhoto.isUserInteractionEnabled = false
                    }
                }
            }
        } catch {
            self.showAlert(withMessage: NSLocalizedString("التطبيق لا يستطيع استخدام المايكروفون الخاص بك", comment: ""))
            self.recordPhoto.isUserInteractionEnabled = false
        }
        if Auth.auth.language == "ar" {
            backButton.setImage(UIImage(named: "right-arrow-2"), for: .normal)
            nameTF.textAlignment = .right
            nationalityTF.textAlignment = .right
            ageTF.textAlignment = .right
            sexTF.textAlignment = .right
            addressTF.textAlignment = .right
            phoneTF.textAlignment = .right
            
        }
        
        self.hideKeyboardWhenTappedAround()

        ageTF.delegate = self
        

    }
    
    override func viewDidAppear(_ animated: Bool) {
        subscribeToKeyboardNotifications()
    }
    
    
    @IBAction func didPressSend(_ sender: Any) {
        guard let name = nameTF.text, name != "", let nationality = nationalityTF.text, nationality != "", let age = Int(ageTF.text ?? ""), let address = addressTF.text, address != "", let phone = phoneTF.text, phone  != "", isRecorded else {
            self.showAlert(withMessage: NSLocalizedString("من فضلك قم بإكمال البيانات الخاصة بك!", comment: ""))
            return
        }
        voice.name = name
        voice.nationality = nationality
        voice.age = age
        voice.address = address
        voice.phone = phone
        voice.id = user.id
        
        
        
        sendRequest()
        
        
    }
    
    func sendRequest() {
        SVProgressHUD.show()
        firstly{
            return API.CallApi(APIRequests.upload(image: nil, file: audioFilename))
            }.done {
                let resp = try! JSONDecoder().decode(UploadResponse.self, from: $0)
                self.voice.soundFile = resp.image
                firstly{
                    return API.CallApi(APIRequests.addVoice(voice: self.voice))
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
            }.catch {
                self.showAlert(withMessage: $0.localizedDescription)
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
        voice.gender = user.gender
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
            voice.gender = 1
        default:
            sexTF.text = NSLocalizedString("أنثى", comment: "")
            voice.gender = 2
        }
    }
    
    @objc func dismissPicker() {
        view.endEditing(true)
    }
    
    
    
    
    //Mark: Image Picker
    
    @IBAction func didPressRecord(recognizer: UITapGestureRecognizer) {
        if isRecording{
            finishRecording(success: true)
        }else {
            startRecording()
        }
    }
    var audioFilename: URL!
    func startRecording() {
        audioFilename = getDocumentsDirectory().appendingPathComponent("record.m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.isMeteringEnabled = true
            audioRecorder.record()
            meterTimer = Timer.scheduledTimer(timeInterval: 0.1, target:self, selector:#selector(self.updateAudioMeter(timer:)), userInfo:nil, repeats:true)
            playButton.isEnabled = false
            recordPhoto.image = UIImage(named: "stop")
            isRecording = true
        } catch {
            finishRecording(success: false)
        }
    }
    
    @objc func updateAudioMeter(timer: Timer)
    {
        if audioRecorder.isRecording
        {
            
            let sec = Double(audioRecorder.currentTime)
            guard sec <= 30.0 else {
                finishRecording(success: true)
                timerLabel.text = "30.0 / 30.0"
                return
            }
            let milsec = Double(round(10*sec)/10)
            let fraction = milsec.truncatingRemainder(dividingBy: 1.0)
            let secs = milsec - fraction
           // let melSec = (audioRecorder.currentTime * 100.0).truncatingRemainder(dividingBy: 100)
            
            timerLabel.text = "\(Int(secs)).\(Int(fraction * 10)) / 30.0"
            audioRecorder.updateMeters()
        }
    }
    
    var isRecorded = false
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        meterTimer.invalidate()
        isRecording = false
        
        recordPhoto.image = UIImage(named: "undo-button-2")
        if !success{
            self.showAlert(withMessage: NSLocalizedString("التطبيق لم يستطع إكمال التسجيل، من فضلك أعد المحاولة.", comment: ""))
        }
        else {
            playButton.isEnabled = true
            isRecorded = true
        }
    }
    
    func Play()
    {
        do
        {
            audioPlayer = try AVAudioPlayer(contentsOf: audioFilename)
            audioPlayer.delegate = self
            recordPhoto.isUserInteractionEnabled = false
            playButton.setImage(UIImage(named: "pause-button-2"), for: .normal)
            playButton.backgroundColor = UIColor(red: 81.0/255.0, green: 165.0/255.0, blue: 187.0/255.0, alpha: 1.0)
            audioPlayer.play()
            isPlaying = true
        }
        catch{
            print("Error")
        }
    }
    
    @IBAction func didPressPlay(_ sender: Any)
    {
        if(isPlaying)
        {
            Pause()
        }
        else
        {
            if FileManager.default.fileExists(atPath: audioFilename.path)
            {
                Play()
            }
            else
            {
                self.showAlert(withMessage: NSLocalizedString("لم يتم العثور على الملف الصوتي", comment: ""))
            }
        }
    }
    
    func Pause(){
        audioPlayer.stop()
        recordPhoto.isUserInteractionEnabled = true
        playButton.setImage(UIImage(named: "play-button"), for: .normal)
        playButton.backgroundColor = .white
        isPlaying = false
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Pause()
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


