//
//  AddWineVC.swift
//  WineList
//
//  Created by Jon Boling on 6/3/18.
//  Copyright © 2018 Walt Boling. All rights reserved.
//

import UIKit
import AVFoundation
import ChameleonFramework
import CloudKit



class AddWineVC: UIViewController, UITextFieldDelegate, UITextViewDelegate, AVCapturePhotoCaptureDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //var captureSession = AVCaptureSession()
    let imagePicker = UIImagePickerController()
    var backCamera = AVCaptureDevice.default(for: AVMediaType.video) //modified from vid since i dont want any other camera option available
    //var photoOutput: AVCapturePhotoOutput?
    //var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    //var image: UIImage?
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
    
    @IBOutlet weak var wineTypeTextField: UITextField!
    @IBOutlet weak var wineNameTextField: UITextField!
    @IBOutlet weak var storeNameTextField: UITextField!
    @IBOutlet weak var notesTextView: UITextView! {
        didSet {
            notesTextView?.addDoneCancelToolbar()
        }
    }
    @IBOutlet weak var priceTextField: UITextField! {
        didSet {
            priceTextField?.addDoneCancelToolbar()
        }
    }
    
    @IBOutlet weak var formScrollView: UIScrollView!
    @IBOutlet weak var metaScrollView: UIScrollView!
    
    @IBOutlet weak var snapPhotoButton: UIButton!
    @IBOutlet weak var retakeButton: UIButton!
    @IBOutlet weak var saveWineButton: UIButton!
    
    //@IBOutlet weak var captureImageView: UIView!
    @IBOutlet weak var photoCapturePreview: UIImageView!
    
    @IBAction func selectImgTapped(_ sender: UIButton) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func takePhotoTapped(_ sender: UIButton) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        imagePicker.cameraCaptureMode = .photo
        imagePicker.modalPresentationStyle = .fullScreen
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func saveWineWasTapped(_ sender: Any) {
        saveThatWine()
        saveWineButton.titleLabel?.text = "Saved!"
        /*if let url = imageURL { // had to finagle this code a bit, but it's supposed to delete the URL if the saved image is canceled
            //let fileManager = FileManager()
            do {
                if FileManager.default.fileExists(atPath: url.absoluteString!) {
                    try FileManager.default.removeItem(at: url as URL)
                }
            } catch {
                print("error")
            }
        }*/
        
        //need some code to check here and make sure wine was saved to database before popping to root controller
        //sleep(2) // temp attempt to give a delay between save and pop to let DB refresh
        navigationController?.popToRootViewController(animated: true)
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            photoCapturePreview.contentMode = .scaleAspectFit
            photoCapturePreview.image = pickedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
        
    //icloud saving actions coded here, called in saveWineWasTapped
    func saveThatWine() {
        if wineNameTextField?.text != "" {
            let newWine = CKRecord(recordType: "Wines")
            newWine["wineName"] = wineNameTextField?.text as CKRecordValue?
            newWine["wineType"] = wineTypeTextField?.text as CKRecordValue?
            newWine["storeName"] = storeNameTextField?.text as CKRecordValue?
            newWine["winePrice"] = priceTextField?.text as CKRecordValue?
           // newWine["likeStatus"] =
            newWine["userNotes"] = notesTextView?.text as CKRecordValue?
            
            let photo = photoCapturePreview.image
            if let asset = createAsset(from: UIImageJPEGRepresentation(photo!, 1.0)!) {
                newWine["photo"] = asset as CKRecordValue
            }
            
            //newWine["wineImage"] = image as? CKRecordValue
            /*if let url = imageURL {
                let imageAsset = CKAsset(fileURL: url as URL)
                newWine["wineImage"] = imageAsset
            }*/
           /* else {
                let fileURL = NSBundle.mainBundle().URLForResource("no_image", withExtension: "png")
                let imageAsset = CKAsset(fileURL: fileURL)
                noteRecord.setObject(imageAsset, forKey: "wineImage")
            }*/
            
            let privateDatabase = CKContainer.default().privateCloudDatabase
            privateDatabase.save(newWine, completionHandler: { (record: CKRecord?, error: Error?) in
                if error == nil {
                    print("wine saved!")
                } else {
                    print("Error: \(error.debugDescription)")
                }
            })
        }
    }
    
    func saveImageLocally() {
        let imageData = UIImageJPEGRepresentation(photoCapturePreview.image!, 0.8)! as NSData
        let path = documentsDirectoryPath.appendingPathComponent(tempImageName)
        imageURL = NSURL(fileURLWithPath: path)
        imageData.write(to: imageURL as URL, atomically: true)
    }
    
    //text input controlls
        
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == wineNameTextField {
            textField.resignFirstResponder()
            priceTextField.becomeFirstResponder()
        } else if textField == priceTextField {
            textField.didEnterInput()
            wineTypeTextField.becomeFirstResponder()
        } else if textField == wineTypeTextField {
            textField.resignFirstResponder()
            storeNameTextField.becomeFirstResponder()
        } else if textField == storeNameTextField {
            textField.resignFirstResponder()
            notesTextView.becomeFirstResponder()
        }
        
        return true
    }
        
    func textFieldDidBeginEditing(_ textField: UITextField) {
        metaScrollView.setContentOffset(CGPoint(x: 0, y: 100), animated: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        metaScrollView.setContentOffset(CGPoint(x: 0, y: -60), animated: true)
        //formScrollView.setZoomScale(0.75, animated: true)
    }
   
    func textViewDidBeginEditing(_ textView: UITextView) {
        metaScrollView.setContentOffset(CGPoint(x: 0, y: 150), animated: true)
        if notesTextView.text == notePlaceholderText {
            notesTextView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        metaScrollView.setContentOffset(CGPoint(x: 0, y: -60), animated: true)
        if notesTextView.text.isEmpty {
            notesTextView.text = notePlaceholderText
        }
    }
    
    func configureTextFields() {
        //let borderColor = UIColor.flatWhite
        self.wineNameTextField.delegate = self
        //self.wineNameTextField.layer.borderColor = borderColor.cgColor
        //self.wineNameTextField.layer.borderWidth = 0.0
        self.wineTypeTextField.delegate = self
        //self.wineTypeTextField.layer.borderColor = borderColor.cgColor
       // self.wineTypeTextField.layer.borderWidth = 1.0
        self.storeNameTextField.delegate = self
        //self.storeNameTextField.layer.borderColor = borderColor.cgColor
        //self.storeNameTextField.layer.borderWidth = 1.0
        self.priceTextField.delegate = self
        //self.priceTextField.layer.borderColor = borderColor.cgColor
        //self.priceTextField.layer.borderWidth = 1.0
        self.notesTextView.delegate = self
        //self.notesTextView.layer.borderColor = borderColor.cgColor
        //self.notesTextView.layer.borderWidth = 1.0
        //notesTextView.layer.backgroundColor = UIColor.flatWhiteDark.cgColor
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //standard photo capture code
        //captureImageView.contentMode = .scaleAspectFill
       // previewLayer!.frame = captureImageView.bounds
        self.navigationController?.isNavigationBarHidden = false
    }
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //runCamera()
        //setupInputOutput()
        //retakeButton.isHidden = true
        configureTextFields()
        imagePicker.delegate = self
        
        notesTextView.text = notePlaceholderText
    
        view.backgroundColor = GradientColor(.topToBottom, frame: view.frame, colors: backgroundColor)
        let navBar = self.navigationController?.navigationBar
        navBar?.tintColor = .white
        navBar?.barTintColor = GradientColor(.topToBottom, frame: view.frame, colors: backgroundColor)
        navBar?.titleTextAttributes = [NSAttributedStringKey.font: UIFont(name: "Raleway-Regular", size: 18)!, .foregroundColor: UIColor.white]
        
        //wineNameTextField.placeHolderColor = .flatWhite
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

    
    
    


}

