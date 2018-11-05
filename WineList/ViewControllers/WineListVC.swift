//
//  WineListVC.swift
//  WineList
//
//  Created by Jon Boling on 6/3/18.
//  Copyright © 2018 Walt Boling. All rights reserved.
//

import UIKit
import ChameleonFramework
import CloudKit
import PKHUD 


class WineListVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {
    
    let colors:[UIColor] = [
        UIColor.flatPlum,
        UIColor.flatMaroon
    ]
    
    var wines = [CKRecord]()
    var filteredWines = [CKRecord]()
    var sortOptions = ["None","Price", "Type", "Store", "Liked", "Year"]
    let searchController = UISearchController(searchResultsController: nil)
    var refresh = UIRefreshControl()
    //var progressHUD: Any?
    var floatIn = false
    
    @IBOutlet weak var wineListTableView: UITableView!
    @IBOutlet weak var sortOptionsPickerView: UIPickerView!
    @IBOutlet weak var addWineBtn: UIButton!
    @IBOutlet weak var filterButton: UIBarButtonItem!
    @IBOutlet weak var toolbar: UIToolbar!
    
    @IBAction func filterButtonWasTapped(_ sender: Any) {
        if sortOptionsPickerView.isHidden == true {
             sortOptionsPickerView.isHidden = false
            sortOptionsPickerView.backgroundColor = .white
            
        } else {
            sortOptionsPickerView.isHidden = true
        }
       
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toWineDetail" {
            if let indexPath = self.wineListTableView.indexPathForSelectedRow {
                //let wine = wines[indexPath.row]
                let wine = filteredWines[indexPath.row]
                let controller = segue.destination as! WineDetailVC
                
                controller.selectedWine = wine
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        
        if let indexPath = wineListTableView.indexPathForSelectedRow {
            wineListTableView.deselectRow(at: indexPath, animated: true)
        }
        
         loadWines()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        HUD.dimsBackground = false
        HUD.show(.labeledProgress(title: "", subtitle: "Loading Wines"), onView: self.view)
        
        wineListTableView.register(WineCell.self, forCellReuseIdentifier: "wineCell")
        
        sortOptionsPickerView.isHidden = true
        
        configureSearchBar()
        configureFloatingBtn()
        configureVisual()
        
        refresh = UIRefreshControl()
        refresh.attributedTitle = NSAttributedString(string: "Pull to load Lists")
        refresh.addTarget(self, action: #selector(WineListVC.loadWines), for: .valueChanged)
        wineListTableView.addSubview(refresh)
    }
    
    @objc func loadWines() {
        let privateDatabase = CKContainer.default().privateCloudDatabase
        let query = CKQuery(recordType: "Wines", predicate: NSPredicate(format: "TRUEPREDICATE", argumentArray: nil))
        //HUD.flash(.progress) - prob need to add comp. handlr w/ hide code
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        privateDatabase.perform(query, inZoneWith: nil) { (results: [CKRecord]?, error: Error?) in
            
            if let wines = results {
                self.wines = wines
                self.filteredWines = wines
                DispatchQueue.main.async(execute: {
                    self.wineListTableView.reloadData()
                    self.refresh.endRefreshing()
                    HUD.hide()
                })
            }
        }
    }
    
    //setting up search bar
    func configureSearchBar() {
        filteredWines = wines
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        wineListTableView.tableHeaderView = searchController.searchBar
    }
    
    func configureVisual() {
        //background
        view.backgroundColor = .white
        wineListTableView.backgroundColor = .white
        
        //toolbar
        toolbar.barTintColor = UIColor.flatPlum
        toolbar.tintColor = .white
        
        //navBar
        let navBar = self.navigationController?.navigationBar
        navBar?.tintColor = .white
        navBar?.barTintColor = GradientColor(.topToBottom, frame: view.frame, colors: colors)
        navBar?.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Raleway-Regular", size: 18)!, .foregroundColor: UIColor.white]
        
        //buttons
        
    }
    
    @IBAction func addWineWasTapped(_ sender: Any) {
        performSegue(withIdentifier: "toAddWine", sender: self)
    }
    
    
    func configureFloatingBtn() {
        addWineBtn.layer.cornerRadius = addWineBtn.frame.height / 2
        addWineBtn.layer.masksToBounds = true
        addWineBtn.tintColor = UIColor.white
        addWineBtn.backgroundColor = UIColor.flatPlumDark
        addWineBtn.layer.zPosition = 1
        addWineBtn.layer.shadowColor = UIColor.darkGray.cgColor
        addWineBtn.layer.shadowOffset = CGSize(width: 1.0, height: 5.0)
        addWineBtn.layer.shadowOpacity = 0.4
        addWineBtn.layer.masksToBounds = false
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text! == "" {
            filteredWines = wines
        } else if let searchStr = searchController.searchBar.text?.lowercased() {
            filteredWines = wines.filter({ (($0["wineName"]?.description.lowercased().contains(searchStr))! || ($0["year"]?.description.contains(searchStr))! || ($0["wineType"]?.description.contains(searchStr))!)
                //how to include more search options in same function
            })
        }
        
        self.wineListTableView.reloadData()
    }
    
    //MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return wines.count
        return filteredWines.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath ) -> UITableViewCell {
        let wineCell = tableView.dequeueReusableCell(withIdentifier: "wineCell", for: indexPath) as! WineCell
        //let wine = wines[indexPath.row]
        let wine = filteredWines[indexPath.row]
        var yearLabel: String?
       // var likeLabel: String?
        var typeLabel: String?
       // let detailString: String?
        var priceLabel: String?
        var storeLabel: String?
       
       if let wineName = wine["wineName"] as? String {
            wineCell.backgroundColor = .clear
            wineCell.wineNameLabel.text = wineName
            wineCell.wineNameLabel.textColor = UIColor.flatPlum
            wineCell.wineNameLabel.font = UIFont(name: "Raleway-Regular", size: 19)
            wineCell.wineNameLabel.text = "\(wineName)"
            if let year = wine["year"] as? String {
                yearLabel = year
            }
            
            if let type = wine["wineType"] as? String {
                typeLabel = type
            }
        
        wineCell.yearAndTypeLabel.text = "\(yearLabel ?? "") \(typeLabel ?? "")"
        wineCell.yearAndTypeLabel.textColor = UIColor.flatGrayDark
        wineCell.yearAndTypeLabel.font = UIFont(name: "Raleway-Light", size: 16)
        
        if let winePrice = wine["winePrice"] as? String {
            if winePrice != "" {
                priceLabel = "$\(winePrice)"
            }
        }
        if let storeName = wine["storeName"] as? String {
            if priceLabel != nil && storeName != "" {
                storeLabel = "at \(storeName)"
            }
            else {
                storeLabel = storeName
            }
        }
        
        
        wineCell.priceAndStoreLabel.text = "\(priceLabel ?? "") \(storeLabel ?? "")"
        wineCell.priceAndStoreLabel.textColor = UIColor.flatGrayDark
        wineCell.priceAndStoreLabel.font = UIFont(name: "Raleway-Light", size: 16)
        
            if let like = wine["likeIndex"] as? Int {
                if like == 0 {
                   // likeLabel = "Liked!"
                    //wineCell.detailTextLabel?.textColor = .flatMintDark
                    wineCell.thumbsUpOrDown.image = UIImage(named: "greenThumbsUpIcon.png")
                    wineCell.thumbsUpOrDown.contentMode = .scaleAspectFit
                } else if like == 1 {
                    //likeLabel = "Disliked!"
                    //wineCell.detailTextLabel?.textColor = .flatRed
                    wineCell.thumbsUpOrDown.image = UIImage(named: "redThumbsDownIcon.png")
                    wineCell.thumbsUpOrDown.contentMode = .scaleAspectFit
                } else {
                    /*sets an invisible dummy image so that text looks uniform throughout list
                    wineCell.imageView?.image = UIImage(named: "thumbsUpIcon.png")
                    wineCell.imageView?.alpha = 0.0
                    wineCell.imageView?.contentMode = .scaleAspectFit*/
                    wineCell.thumbsUpOrDown.isHidden = true
                    wineCell.thumbsBackground.isHidden = true
                }
            }
        
        if let wineImage = wine["photo"] as? CKAsset {
            wineCell.wineImageView.image = UIImage(contentsOfFile: wineImage.fileURL.path)
            wineCell.wineImageView.contentMode = .scaleAspectFit
        } else {
            wineCell.wineImageView.image = #imageLiteral(resourceName: "WineListIconBW")
        }
            //detailString = "\(typeLabel ?? "") \(likeLabel ?? "")"
            //detailString = "\(yearLabel ?? "") \(typeLabel ?? "")"
            /*wineCell.detailTextLabel?.text = detailString!//
            wineCell.detailTextLabel?.textColor = UIColor.darkText
            wineCell.detailTextLabel?.font = UIFont(name: "Raleway-Light", size: 13)*/
        }
        
        wineCell.layer.borderColor = UIColor.flatGray.cgColor
        wineCell.layer.borderWidth = 0.3
        
        return wineCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toWineDetail", sender: self)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //let selectedRecordID = wines[indexPath.row].recordID
            let selectedRecordID = filteredWines[indexPath.row].recordID
            
            let privateDatabase = CKContainer.default().privateCloudDatabase
            
            privateDatabase.delete(withRecordID: selectedRecordID) { (recordID, error) -> Void in
                if error != nil {
                    print(error!)
                } else {
                    OperationQueue.main.addOperation({ () -> Void in
                        //self.wines.remove(at: indexPath.row)
                        self.filteredWines.remove(at: indexPath.row)
                        self.wineListTableView.reloadData()
                    })
                }
            }
        }
    }
}

/*extension UITableViewDelegate {
}*/

extension WineListVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sortOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return sortOptions[row]
    }
}
