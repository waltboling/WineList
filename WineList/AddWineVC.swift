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



class AddWineVC: UIViewController, UITextFieldDelegate, UITextViewDelegate, AVCapturePhotoCaptureDelegate {
    
    var captureSession = AVCaptureSession()
    var backCamera = AVCaptureDevice.default(for: AVMediaType.video) //modified from vid since i dont want any other camera option available
    var photoOutput: AVCapturePhotoOutput?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    var image: UIImage?
    var wines = [CKRecord]()
    var imageURL: NSURL!
    let documentsDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
    let tempImageName = "temp_image.jpg"
    
    /*var wineName: CKRecord?
    var wineType: CKRecord?
    var winePrice: CKRecord?
    var storeLocation: CKRecord?
    var likeStatus: CKRecord?
    var userNotes: CKRecord?
    var wineImage: CKAsset?*/
    
    let backgroundColor: [UIColor] = [
        UIColor.flatMaroonDark,
        UIColor.flatMaroonDark,
        UIColor.flatPlum
    ]
    
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
    
    @IBOutlet weak var captureImageView: UIView!
    @IBOutlet weak var photoCapturePreview: UIImageView!
    
    
    @IBAction func saveWineWasTapped(_ sender: Any) {
        saveThatWine()
        saveWineButton.titleLabel?.text = "Saved!"
        if let url = imageURL { // had to finagle this code a bit, but it's supposed to delete the URL if the saved image is canceled
            //let fileManager = FileManager()
            do {
                if FileManager.default.fileExists(atPath: url.absoluteString!) {
                    try FileManager.default.removeItem(at: url as URL)
                }
            } catch {
                print("error")
            }
        }
        
        navigationController?.popToRootViewController(animated: true)
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
            
            //newWine["wineImage"] = image as? CKRecordValue
            if let url = imageURL {
                let imageAsset = CKAsset(fileURL: url as URL)
                newWine["wineImage"] = imageAsset
            }
           /* else {
                let fileURL = NSBundle.mainBundle().URLForResource("no_image", withExtension: "png")
                let imageAsset = CKAsset(fileURL: fileURL)
                noteRecord.setObject(imageAsset, forKey: "wineImage")
            }*/
            
            let publicDatabase = CKContainer.default().publicCloudDatabase
            publicDatabase.save(newWine, completionHandler: { (record: CKRecord?, error: Error?) in
                if error == nil {
                    print("wine saved!")
                } else {
                    print("Error: \(error.debugDescription)")
                }
            })
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        
        /*if let imageData = photo.fileDataRepresentation() {
            image = UIImage(data: imageData)
            //photoCapturePreview.image = image
        }*/
        print("HERE")
    }
    
    
    //originally had this in the extension delegate. not getting called
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
           image = UIImage(data: imageData)
            //photoCapturePreview.image = image
            saveImageLocally()
        }
    }
    
    func saveImageLocally() {
        let imageData = UIImageJPEGRepresentation(image!, 0.8)! as NSData
        let path = documentsDirectoryPath.appendingPathComponent(tempImageName)
        imageURL = NSURL(fileURLWithPath: path)
        imageData.write(to: imageURL as URL, atomically: true)
    }
    
    
    @IBAction func didTakePhoto(_ sender: UIButton) {
        let settings = AVCapturePhotoSettings()
        photoOutput?.capturePhoto(with: settings, delegate: self)
        captureSession.stopRunning()
        snapPhotoButton.isHidden = true
        retakeButton.isHidden = false
    }
    
    @IBAction func retakeImageWasTapped(_ sender: UIButton) {
        //photoCapturePreview.image = nil
        if photoOutput != nil {
            /*captureSession.removeOutput(photoOutput!)
            runCamera()*/
            imageURL = nil
            captureSession.startRunning()
            retakeButton.isHidden = true
            snapPhotoButton.isHidden = false
            
        } else {
            return
        }
    }
        
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
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        metaScrollView.setContentOffset(CGPoint(x: 0, y: -60), animated: true)
    }
    
    func configureTextFields() {
        self.wineNameTextField.delegate = self
        self.wineTypeTextField.delegate = self
        self.storeNameTextField.delegate = self
        self.priceTextField.delegate = self
        self.notesTextView.delegate = self
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
        
        runCamera()
        setupInputOutput()
        retakeButton.isHidden = true
        configureTextFields()
    
        view.backgroundColor = GradientColor(.topToBottom, frame: view.frame, colors: backgroundColor)
    }
    
    func runCamera() {
        setupCaptureSession()
        setupDevice()
        
        setupPreviewLayer()
        startRunningCaptureSession()
    }
    
    func setupCaptureSession() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }
    
    func setupDevice() {
    } // no code here atm bc i'm only allowing for back camera to be used
    
    func setupInputOutput() {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: backCamera!)
            captureSession.addInput(captureDeviceInput)
            photoOutput = AVCapturePhotoOutput()
            photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
            captureSession.addOutput(photoOutput!)
        } catch {
            print(error)
        }
    }
    
    func setupPreviewLayer() {
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        cameraPreviewLayer?.frame = captureImageView.bounds
        captureImageView.layer.insertSublayer(cameraPreviewLayer!, at: 0)
    }
    
    func startRunningCaptureSession() {
        captureSession.startRunning()
        
    }

        //standard photo capture code
        /*
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil else {
            print("Fail to capture photo: \(String(describing: error))")
            return
        }
        
        // Check if the pixel buffer could be converted to image data
        guard let imageData = photo.fileDataRepresentation() else {
            print("Fail to convert pixel buffer")
            return
        }
        
        // Check if UIImage could be initialized with image data
        guard let capturedImage = UIImage.init(data: imageData , scale: 1.0) else {
            print("Fail to convert image data to UIImage")
            return
        }
        
        // Get original image width/height
        let imgWidth = capturedImage.size.width
        let imgHeight = capturedImage.size.height
        // Get origin of cropped image
        let imgOrigin = CGPoint(x: (imgWidth - imgHeight)/2, y: (imgHeight - imgHeight)/2)
        // Get size of cropped iamge
        let imgSize = CGSize(width: imgHeight, height: imgWidth)
        
        // Check if image could be cropped successfully
        //the current cropping settings ensures that the preview image previews in the captureImageView
        guard let imageRef = capturedImage.cgImage?.cropping(to: CGRect(origin: captureImageView.frame.origin, size: captureImageView.frame.size)) else {
            print("Fail to crop image")
            return
        }
        
        // Convert cropped image ref to UIImage
       let imageToSave = UIImage(cgImage: imageRef, scale: 1.0, orientation: .up)
        UIImageWriteToSavedPhotosAlbum(imageToSave, nil, nil, nil)
        
        // Stop video capturing session (Freeze preview)
        session?.stopRunning()
        self.photoCapturePreview.image = imageToSave
    }
    
    */
    
    


}

/*extension AddWineVC: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            image = UIImage(data: imageData)
            photoCapturePreview.image = image
        }
    }
}*/
