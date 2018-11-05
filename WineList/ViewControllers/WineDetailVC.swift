//
//  WineDetailVC.swift
//  WineList
//
//  Created by Jon Boling on 6/3/18.
//  Copyright © 2018 Walt Boling. All rights reserved.
//

import UIKit
import ChameleonFramework
import CloudKit

class WineDetailVC: UIViewController {
    var selectedWine: CKRecord?
    var wines = [CKRecord]()
    let backgroundColor: [UIColor] = [
        UIColor.white,
        UIColor.flatWhite,
        UIColor.flatWhite
    ]
    var nameString: String?
    var yearString: String?
    var indexToPass: Int?
    var priceToPass: String?
    var notesToPass: String?
    
    @IBOutlet weak var wineImageView: UIImageView!
    @IBOutlet weak var wineName: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var store: UILabel!
    @IBOutlet weak var notes: UILabel!
    @IBOutlet weak var likeStatus: UILabel!
    @IBOutlet weak var year: UILabel!
    @IBOutlet weak var noImageLabel: UILabel!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var thumbsUpDownImgView: UIImageView!
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    @IBAction func editWineWasTapped(_ sender: Any) {
        performSegue(withIdentifier: "toAddWineVC", sender: self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
          likeStatus.isHidden = true
    
        if let wine = selectedWine {
            let wineName = wine["wineName"] as! String
            nameString = wineName
            let year = wine["year"] as? String
            yearString = year
            self.wineName.text = "\(year ?? "") \(wineName)"
            self.priceToPass = "$  \(wine["winePrice"] as! String)"
            self.price.text = priceToPass
            self.type.text = wine["wineType"] as? String
            self.store.text = wine["storeName"] as? String
            notesToPass = wine["userNotes"] as? String
            self.notesTextView.text = notesToPass
            if let likeIndex = wine["likeIndex"] as? Int {
                if likeIndex == 0 {
                    //self.likeStatus.text = "Liked!"
                    //self.likeStatus.textColor = .flatMint
                    indexToPass = 0
                    self.thumbsUpDownImgView.image = UIImage(named: "greenThumbsUpIcon.png")
                } else if likeIndex == 1 {
                   // self.likeStatus.text = "Disliked!"
                    //self.likeStatus.textColor = .flatRed
                    indexToPass = 1
                    thumbsUpDownImgView.image = UIImage(named: "redThumbsDownIcon.png")
                } else {
                    indexToPass = nil
                    thumbsUpDownImgView.isHidden = true
                    likeStatus.isHidden = true
                }
            } else {
                self.likeStatus.text = "n/a"
                self.thumbsUpDownImgView.isHidden = true
            }
            
            //fetch wine image and configure imageview
            if let wineImage = wine["photo"] as? CKAsset {
                self.wineImageView.image = UIImage(contentsOfFile: wineImage.fileURL.path)
                self.wineImageView.contentMode = UIView.ContentMode.scaleAspectFit
                noImageLabel.isHidden = true
            } else {
                self.wineImageView.image = #imageLiteral(resourceName: "WineListIconBW")
                noImageLabel.isHidden = false
            }
            
            let privateDatabase = CKContainer.default().privateCloudDatabase
            let reference = CKRecord.Reference(recordID: wine.recordID, action: .deleteSelf)
            let query = CKQuery(recordType: "Wines", predicate: NSPredicate(format:"selectedWine == %@", reference))
            privateDatabase.perform(query, inZoneWith: nil) { (results: [CKRecord]?, error: Error?) in
                if let wines = results {
                    self.wines = wines
                    /*DispatchQueue.main.async(execute: {
                        self.wineName.text = wine["wineName"] as? String
                    })*/
                }
            }
        }
        
        view.backgroundColor = GradientColor(.topToBottom, frame: view.frame, colors: backgroundColor)
    }
    
    
    //how to refactor this code to cut down on redundancy?
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAddWineVC" {
            let controller = segue.destination as! NewWineVC
            if selectedWine != nil {
                controller.passedWineName = nameString
                controller.passedPrice = price.text
                controller.passedYear = yearString
                controller.passedStoreName = store.text
                controller.passedWineType = type.text
                controller.passedNotes = notesTextView.text
                if let likeIndex = indexToPass {
                    controller.passedIndex = likeIndex
                }
                if let wineImage = wineImageView.image {
                    controller.passedImage = wineImage
                }
            }
        }
    }
}
