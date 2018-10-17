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
        UIColor.flatPlum,
        UIColor.flatPlum,
        UIColor.flatMaroonDark
    ]
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        if let wine = selectedWine {
            let wineName = wine["wineName"] as! String
            let year = wine["year"] as? String
            self.wineName.text = "\(year ?? "") \(wineName)"
            self.price.text = "$  \(wine["winePrice"] as! String)"
            self.type.text = wine["wineType"] as? String
            self.store.text = wine["storeName"] as? String
            self.notesTextView.text = wine["userNotes"] as? String
            if let likeIndex = wine["likeIndex"] as? Int {
                if likeIndex == 0 {
                    self.likeStatus.text = "Liked!"
                    self.likeStatus.textColor = .flatMint
                } else {
                    self.likeStatus.text = "Disliked!"
                    self.likeStatus.textColor = .flatRed
                }
            } else {
                self.likeStatus.text = "n/a"
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
        
        view.backgroundColor = .white
    }
}