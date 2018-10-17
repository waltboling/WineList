//
//  NewWineVC.swift
//  WineList
//
//  Created by Jon Boling on 9/19/18.
//  Copyright © 2018 Walt Boling. All rights reserved.
//

import UIKit
import AVFoundation
import PKHUD
import TextFieldFX
import ChameleonFramework
import CloudKit
import Photos

class NewWineVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVCapturePhotoCaptureDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    let imagePicker = UIImagePickerController()
    var backCamera = AVCaptureDevice.default(for: AVMediaType.video)
    var wines = [CKRecord]()
    var imageURL: NSURL!
    let documentsDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
    let tempImageName = "temp_image.jpg"
    let tempURL: URL? = nil
    let backgroundColor: [UIColor] = [
        UIColor.flatPlum,
        UIColor.flatPlum,
        UIColor.flatMaroonDark
    ]
    let navBarColor = UIColor.flatPlum
    var notePlaceholderText = "Add new note here..."
    let privateDatabase = CKContainer.default().privateCloudDatabase
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var likedLabel: UILabel!
    @IBOutlet weak var wineNameTextField: HoshiTextField!
    @IBOutlet weak var priceTextField: HoshiTextField! {
        didSet {
            priceTextField?.addDoneCancelToolbar()
        }
    }
    
    @IBOutlet weak var wineTypeTextField: HoshiTextField!
    @IBOutlet weak var storeTextField: HoshiTextField!
    @IBOutlet weak var yearTextField: HoshiTextField! {
        didSet {
            yearTextField?.addDoneCancelToolbar()
        }
    }
    
    @IBOutlet weak var notesTextView: UITextView! {
        didSet {
            notesTextView?.addDoneCancelToolbar()
        }
    }
    
    @IBOutlet weak var saveWineButton: UIButton!
    @IBOutlet weak var wineImageView: UIImageView!
    @IBOutlet weak var takePhotoBtn: UIButton!
    @IBOutlet weak var likeWineControl: UISegmentedControl!
    @IBOutlet weak var choosePhotoBtn: UIButton!
    
    @IBAction func SaveBtnTapped(_ sender: Any) {
        saveThatWine()
    }
    
    @IBAction func takePhotoWasTapped(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = UIImagePickerController.SourceType.camera
        imagePicker.cameraCaptureMode = .photo
        imagePicker.modalPresentationStyle = .fullScreen
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func choosePhotoWasTapped(_ sender: Any) {
        checkPermission()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func doneBtnTapped(_ sender: UIBarButtonItem) {
        saveThatWine()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTextFields()
        notesTextView.text = notePlaceholderText
        notesTextView.textColor = .lightGray
        configureVisual()
        
        imagePicker.delegate = self
    }
    
    func configureVisual() {
        //background
        view.backgroundColor = .white
        //navBar
        let navBar = self.navigationController?.navigationBar
        navBar?.tintColor = .white
        navBar?.barTintColor = GradientColor(.topToBottom, frame: view.frame, colors: backgroundColor)
        navBar?.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Raleway-Regular", size: 18)!, .foregroundColor: UIColor.white]
        navigationController?.title = "Add New Wine"
        
        //buttons
        takePhotoBtn.layer.borderColor = UIColor.flatGrayDark.cgColor
        takePhotoBtn.imageView?.contentMode = .scaleAspectFit
        choosePhotoBtn.layer.borderColor = UIColor.flatGrayDark.cgColor
        choosePhotoBtn.imageView?.contentMode = .scaleAspectFit
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            wineImageView.contentMode = .scaleAspectFit
            wineImageView.image = pickedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func saveThatWine() {
        if wineNameTextField?.text != "" {
            let newWine = CKRecord(recordType: "Wines")
            newWine["wineName"] = wineNameTextField?.text as CKRecordValue?
            newWine["year"] = yearTextField?.text as CKRecordValue?
            newWine["wineType"] = wineTypeTextField?.text as CKRecordValue?
            newWine["storeName"] = storeTextField?.text as CKRecordValue?
            newWine["winePrice"] = priceTextField?.text as CKRecordValue?
            newWine["userNotes"] = notesTextView?.text as CKRecordValue?
            newWine["likeIndex"] = likeWineControl.selectedSegmentIndex as CKRecordValue?
            
            let photo = wineImageView.image
            
            if let asset = createAsset(from: photo!.jpegData(compressionQuality: 1.0)!) {
                newWine["photo"] = asset as CKRecordValue
                print("wine image created")
            }
            
            privateDatabase.save(newWine, completionHandler: { (record: CKRecord?, error: Error?) in
                if error == nil {
                    print("wine saved!")
                } else {
                    print("Error: \(error.debugDescription)")
                }
            })
            
            HUD.flash(.labeledSuccess(title: "", subtitle: "Wine Saved!"), delay: 1.0)
            navigationController?.popToRootViewController(animated: true)
        } else {
            showAlert(title: "Wine name is blank", message: "Please enter a wine name to continue")
        }
    }
    
    //text input controlls
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case wineNameTextField:
            textField.resignFirstResponder()
            yearTextField.becomeFirstResponder()
        case yearTextField:
            textField.didEnterInput()
            wineTypeTextField.becomeFirstResponder()
        case wineTypeTextField:
            textField.resignFirstResponder()
            priceTextField.becomeFirstResponder()
        case priceTextField:
            textField.didEnterInput()
            storeTextField.becomeFirstResponder()
        case storeTextField:
            textField.resignFirstResponder()
            notesTextView.becomeFirstResponder()
        default:
            print("there was an error with a text field")
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x: 0, y: 340), animated: true)
        /*switch textField {
         case priceTextField:
         scrollView.setContentOffset(CGPoint(x: 0, y: 240), animated: true)
         case wineTypeTextField:
         scrollView.setContentOffset(CGPoint(x: 0, y: 200), animated: true)
         case storeTextField:
         scrollView.setContentOffset(CGPoint(x: 0, y: 280), animated: true)
         default:
         scrollView.setContentOffset(CGPoint(x: 0, y: 140), animated: true)
         }*/
        
        /*if textField == priceTextField {
         scrollView.setContentOffset(CGPoint(x: 0, y: 200), animated: true)
         } else if textField == wineTypeTextField {
         scrollView.setContentOffset(CGPoint(x: 0, y: 180), animated: true)
         } else{
         scrollView.setContentOffset(CGPoint(x: 0, y: 140), animated: true)
         }*/
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x: 0, y: -25), animated: true)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        scrollView.setContentOffset(CGPoint(x: 0, y: 440), animated: true)
        notesTextView.layer.borderColor = UIColor.lightGray.cgColor
        notesTextView.layer.borderWidth = 1.0
        if notesTextView.text == notePlaceholderText {
            notesTextView.text = ""
            notesTextView.textColor = .flatPlum
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        notesTextView.layer.borderColor = UIColor.clear.cgColor
        if notesTextView.text.isEmpty {
            notesTextView.text = notePlaceholderText
            notesTextView.textColor = .lightGray
        }
    }
    
    func configureTextFields() {
        wineNameTextField.delegate = self
        wineNameTextField.textColor = .flatPlum
        yearTextField.delegate = self
        yearTextField.textColor = .flatPlum
        wineTypeTextField.delegate = self
        wineTypeTextField.textColor = .flatPlum
        storeTextField.delegate = self
        storeTextField.textColor = .flatPlum
        priceTextField.delegate = self
        priceTextField.textColor = .flatPlum
        notesTextView.delegate = self
        notesTextView.textColor = .flatPlum
        likedLabel.textColor = .flatPlum
    }
    
    func createAsset(from data: Data) -> CKAsset? {
        var asset: CKAsset? = nil
        let tempStr = ProcessInfo.processInfo.globallyUniqueString
        let fileName = "\(tempStr)_file.bin"
        let baseURL = URL(fileURLWithPath: NSTemporaryDirectory())
        let fileURL = baseURL.appendingPathComponent(fileName, isDirectory: false)
        
        do {
            try data.write(to: fileURL, options: .atomicWrite)
            asset = CKAsset(fileURL: fileURL)
            
        } catch {
            print("error creating asset: \(error)")
        }
        
        return asset
    }
    
    func checkPermission() {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            print("Access is granted by user")
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({
                (newStatus) in
                print("status is \(newStatus)")
                if newStatus ==  PHAuthorizationStatus.authorized {
                    /* do stuff here */
                    print("success")
                }
            })
            print("It is not determined until now")
        case .restricted:
            // same same
            print("User do not have access to photo album.")
        case .denied:
            // same same
            print("User has denied the permission.")
        }
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        //let settingsAction = UIAlertAction(title: "Settings", style: .default) {(action) in self.openSettings()}
        
        alertController.addAction(okAction)
        //alertController.addAction(settingsAction)
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
