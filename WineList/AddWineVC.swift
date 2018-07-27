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



class AddWineVC: UIViewController {
    
    var captureSession = AVCaptureSession()
    var backCamera = AVCaptureDevice.default(for: AVMediaType.video) //modified from vid since i dont want any other camera option available
    var photoOutput: AVCapturePhotoOutput?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    var image: UIImage?
    
    let backgroundColor: [UIColor] = [
        UIColor.flatMaroonDark,
        UIColor.flatMaroonDark,
        UIColor.flatPlum
        
        /*UIColor.flatWhite,
        UIColor.flatSand,
        UIColor.flatSand,
        //wont lighten correctlyUIColor.flatYellow.lighten(byPercentage: 0.5)!*/
    ]
    
    
    @IBOutlet weak var snapPhotoButton: UIButton!
    
    @IBOutlet weak var retakeButton: UIButton!
    
    @IBOutlet weak var captureImageView: UIView!
    
    @IBOutlet weak var photoCapturePreview: UIImageView!
    
    @IBAction func didTakePhoto(_ sender: UIButton) {
        let settings = AVCapturePhotoSettings()
        photoOutput?.capturePhoto(with: settings, delegate: self)
        captureSession.stopRunning()
        snapPhotoButton.isHidden = true
        retakeButton.isHidden = false
        
        
        
        //standard photo capture code (not working how I want)
        /*
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [
            kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
            kCVPixelBufferWidthKey as String: 160,
            kCVPixelBufferHeightKey as String: 160
        ]
        settings.previewPhotoFormat = previewFormat
        cameraOutput?.capturePhoto(with: settings, delegate: self)
    }*/
    
        //standard photo capture code (not working how i want)
        /*
    var session: AVCaptureSession?
    var cameraOutput: AVCapturePhotoOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?*/
    }
    
    @IBAction func retakeImageWasTapped(_ sender: UIButton) {
        //photoCapturePreview.image = nil
        if photoOutput != nil {
            /*captureSession.removeOutput(photoOutput!)
            runCamera()*/
            captureSession.startRunning()
            retakeButton.isHidden = true
            snapPhotoButton.isHidden = false
            
        } else {
            return
        }
            
        
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
    
        view.backgroundColor = GradientColor(.topToBottom, frame: view.frame, colors: backgroundColor)
       
        //standard photocapture code
        /*
        let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
        session = AVCaptureSession()
        session!.sessionPreset = AVCaptureSession.Preset.photo

        var error: NSError?
        var input: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: backCamera!)
        } catch let error1 as NSError {
            error = error1
            input = nil
            print(error!.localizedDescription)
        }
        
        if error == nil && session!.canAddInput(input) {
            session!.addInput(input)
        }
        
        cameraOutput = AVCapturePhotoOutput()
        //stillImageOutput?. = [AVVideoCodecKey: AVVideoCodecJPEG]
        
        if session!.canAddOutput(cameraOutput!) {
            session!.addOutput(cameraOutput!)
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session!)
        previewLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        captureImageView.layer.addSublayer(previewLayer!)
        session!.startRunning()
        
        self.view.insertSubview(photoCapturePreview, aboveSubview: captureImageView)
    
        
        
        
        */
    
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
       
    }
    
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

extension AddWineVC: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            image = UIImage(data:imageData)
            //photoCapturePreview.image = image
        }
    }
}
