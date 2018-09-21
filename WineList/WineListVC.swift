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
//import SVProgressHUD - maybe add this later to give some better progess UI

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
    
    @IBOutlet weak var wineListTableView: UITableView!
    
    @IBOutlet weak var sortOptionsPickerView: UIPickerView!
    
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
        loadWines()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        wineListTableView.backgroundColor = .clear
        //self.navigationController?.isNavigationBarHidden = false
        sortOptionsPickerView.isHidden = true
        
        configureSearchBar()
        
        toolbar.barTintColor = UIColor.flatPlum
        toolbar.tintColor = .white
        let navBar = self.navigationController?.navigationBar
        navBar?.tintColor = .white
        navBar?.barTintColor = GradientColor(.topToBottom, frame: view.frame, colors: colors)
        navBar?.titleTextAttributes = [NSAttributedStringKey.font: UIFont(name: "Raleway-Regular", size: 18)!, .foregroundColor: UIColor.white]
        
        refresh = UIRefreshControl()
        refresh.attributedTitle = NSAttributedString(string: "Pull to load Lists")
        refresh.addTarget(self, action: #selector(WineListVC.loadWines), for: .valueChanged)
        wineListTableView.addSubview(refresh)
        
        

        // Do any additional setup after loading the view.
    }
    
    @objc func loadWines() {
        let privateDatabase = CKContainer.default().privateCloudDatabase
        let query = CKQuery(recordType: "Wines", predicate: NSPredicate(format: "TRUEPREDICATE", argumentArray: nil))
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        privateDatabase.perform(query, inZoneWith: nil) { (results: [CKRecord]?, error: Error?) in
            if let wines = results {
                self.wines = wines
                self.filteredWines = wines
                DispatchQueue.main.async(execute: {
                    self.wineListTableView.reloadData()
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
    
    func updateSearchResults(for searchController: UISearchController) {
        
        if searchController.searchBar.text! == "" {
            filteredWines = wines
        } else if let searchStr = searchController.searchBar.text?.lowercased() {
            filteredWines = wines.filter({ (($0["wineName"]?.description.lowercased().contains(searchStr))! || ($0["year"]?.description.contains(searchStr))! )
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
        let wineCell = tableView.dequeueReusableCell(withIdentifier: "wineCell", for: indexPath)
        //let wine = wines[indexPath.row]
        let wine = filteredWines[indexPath.row]
        //let yearLabel: String?
        var likeLabel: String?
        var typeLabel: String?
        let detailString: String?
        if let wineName = wine["wineName"] as? String {
            wineCell.backgroundColor = .clear
            wineCell.textLabel?.text = wineName
            wineCell.textLabel?.textColor = GradientColor(.topToBottom, frame: view.frame, colors: colors)
            wineCell.textLabel?.font = UIFont(name: "Raleway-Regular", size: 17)
            if let year = wine["year"] as? String {
                wineCell.textLabel?.text = "\(year) \(wineName)"
            }
            if let type = wine["wineType"] as? String {
                typeLabel = type
            }
            if let like = wine["likeIndex"] as? Int {
                if like == 0 {
                    likeLabel = "Liked!"
                    wineCell.detailTextLabel?.textColor = .flatMintDark
                } else if like == 1 {
                    likeLabel = "Disliked!"
                    wineCell.detailTextLabel?.textColor = .flatRed
                }
            }
            detailString = "\(typeLabel ?? "") \(likeLabel ?? "")"
            
            wineCell.detailTextLabel?.text = detailString!
        }
        
        return wineCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toWineDetail", sender: self)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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
