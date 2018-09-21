//
//  NewWineVC.swift
//  WineList
//
//  Created by Jon Boling on 9/19/18.
//  Copyright © 2018 Walt Boling. All rights reserved.
//

import UIKit
import AVFoundation
import TextFieldEffects
import ChameleonFramework
import CloudKit
import Photos

class NewWineVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVCapturePhotoCaptureDelegate, UITextFieldDelegate, UITextViewDelegate {

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
    
    @IBAction func SaveBtnTapped(_ sender: Any) {
        saveThatWine()
        saveWineButton.titleLabel?.text = "Saved!"
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func takePhotoWasTapped(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
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
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        configureTextFields()
        
        imagePicker.delegate = self
        
        notesTextView.text = notePlaceholderText
        notesTextView.textColor = .lightGray
        
        view.backgroundColor = .white
            //GradientColor(.topToBottom, frame: view.frame, colors: backgroundColor)
        let navBar = self.navigationController?.navigationBar
        navBar?.tintColor = .white
        navBar?.barTintColor = GradientColor(.topToBottom, frame: view.frame, colors: backgroundColor)
        navBar?.titleTextAttributes = [NSAttributedStringKey.font: UIFont(name: "Raleway-Regular", size: 18)!, .foregroundColor: UIColor.white]
        
        takePhotoBtn.layoutIfNeeded()
        takePhotoBtn.subviews.first?.alpha = 0.7
        choosePhotoBtn.layoutIfNeeded()
        choosePhotoBtn.subviews.first?.alpha = 0.7
        
        
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
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
            // newWine["likeStatus"] =
            newWine["userNotes"] = notesTextView?.text as CKRecordValue?
            newWine["likeIndex"] = likeWineControl.selectedSegmentIndex as CKRecordValue?
            
            let photo = wineImageView.image
            if let asset = createAsset(from: UIImageJPEGRepresentation(photo!, 1.0)!) {
                //need a print statement here to see if this is even executing or failing
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
        }
    }

    //text input controlls
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == wineNameTextField {
            textField.resignFirstResponder()
            yearTextField.becomeFirstResponder()
        } else if textField == yearTextField {
            textField.didEnterInput()
            priceTextField.becomeFirstResponder()
        } else if textField == priceTextField {
            textField.didEnterInput()
            wineTypeTextField.becomeFirstResponder()
        } else if textField == wineTypeTextField {
            textField.resignFirstResponder()
            storeTextField.becomeFirstResponder()
        } else if textField == storeTextField {
            textField.resignFirstResponder()
            notesTextView.becomeFirstResponder()
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x: 0, y: 140), animated: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x: 0, y: -25), animated: true)
        //formScrollView.setZoomScale(0.75, animated: true)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        scrollView.setContentOffset(CGPoint(x: 0, y: 240), animated: true)
        notesTextView.layer.borderColor = UIColor.lightGray.cgColor
        notesTextView.layer.borderWidth = 1.0
        if notesTextView.text == notePlaceholderText {
            notesTextView.text = ""
            notesTextView.textColor = .flatPlum
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        scrollView.setContentOffset(CGPoint(x: 0, y: -25), animated: true)
        notesTextView.layer.borderColor = UIColor.clear.cgColor
        if notesTextView.text.isEmpty {
            notesTextView.text = notePlaceholderText
            notesTextView.textColor = .lightGray
        }
    }
    
    func configureTextFields() {
        //let borderColor = UIColor.flatWhite
        wineNameTextField.delegate = self
        wineNameTextField.textColor = .flatPlum
        //self.wineNameTextField.layer.borderColor = borderColor.cgColor
        //self.wineNameTextField.layer.borderWidth = 0.0
        yearTextField.delegate = self
        yearTextField.textColor = .flatPlum
        wineTypeTextField.delegate = self
        wineTypeTextField.textColor = .flatPlum
        //self.wineTypeTextField.layer.borderColor = borderColor.cgColor
        // self.wineTypeTextField.layer.borderWidth = 1.0
        storeTextField.delegate = self
        storeTextField.textColor = .flatPlum
        //self.storeTextField.layer.borderColor = borderColor.cgColor
        //self.storeTextField.layer.borderWidth = 1.0
        priceTextField.delegate = self
        priceTextField.textColor = .flatPlum
        //self.priceTextField.layer.borderColor = borderColor.cgColor
        //self.priceTextField.layer.borderWidth = 1.0
        notesTextView.delegate = self
        notesTextView.textColor = .flatPlum
        //self.notesTextView.layer.borderColor = borderColor.cgColor
        //self.notesTextView.layer.borderWidth = 1.0
        //notesTextView.layer.backgroundColor = UIColor.flatWhiteDark.cgColor
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

}
