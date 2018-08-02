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
    //var wine: CKRecord?
    var selectedWine: CKRecord?
    var wines = [CKRecord]()
    /*let backgroundRose: [UIColor] = [
        UIColor.flatRed,
        UIColor.flatWatermelon,
        UIColor.flatWatermelon,
        UIColor.flatRed
    ]*/
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //wineName.text = selectedWine!["wineName"] as? String
        if let wine = selectedWine {
            self.wineName.text = wine["wineName"] as? String
            self.price.text = wine["winePrice"] as? String
            self.type.text = wine["wineType"] as? String
            self.store.text = wine["storeName"] as? String
            self.notes.text = wine["userNotes"] as? String
            self.likeStatus.text = "n/a"
            self.year.text = "n/a"
            //fetch wine image and configure imageview. need to code check for no img
            if let wineImage: CKAsset = wine["wineImage"] as? CKAsset {
                self.wineImageView.image = UIImage(contentsOfFile: wineImage.fileURL.path)
                self.wineImageView.contentMode = UIViewContentMode.scaleAspectFit
                noImageLabel.isHidden = true
            }
            
            let publicDatabase = CKContainer.default().publicCloudDatabase
            let reference = CKReference(recordID: wine.recordID, action: .deleteSelf)
            let query = CKQuery(recordType: "Wines", predicate: NSPredicate(format:"selectedWine == %@", reference))
            publicDatabase.perform(query, inZoneWith: nil) { (results: [CKRecord]?, error: Error?) in
                if let wines = results {
                    self.wines = wines
                    /*DispatchQueue.main.async(execute: {
                        self.wineName.text = wine["wineName"] as? String
                    })*/
                }
            }
        }
        
        view.backgroundColor = GradientColor(.topToBottom, frame: view.frame, colors: backgroundColor)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
