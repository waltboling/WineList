//
//  WineListVC.swift
//  WineList
//
//  Created by Jon Boling on 6/3/18.
//  Copyright © 2018 Walt Boling. All rights reserved.
//

import UIKit
import ChameleonFramework

class WineListVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let backgroundColors:[UIColor] = [
        UIColor.flatMaroon,
        UIColor.flatWatermelon
    ]
    
    let cellColorScheme1 = NSArray(ofColorsWith: ColorScheme.analogous, using: UIColor.flatPinkDark, withFlatScheme: true)!
    
    let cellColorScheme2 = NSArray(ofColorsWith: ColorScheme.analogous, using: UIColor.flatYellowDark, withFlatScheme: true)!
    
    let testArray = ["apple", "orange", "blue", "green"]

    
    @IBOutlet weak var wineListTableView: UITableView!
    
  
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath ) -> UITableViewCell {
        let wineCell = tableView.dequeueReusableCell(withIdentifier: "wineCell", for: indexPath)
        //var makeInt32 = Int(cellColorScheme.count)
        let randomIndex = Int(arc4random_uniform(UInt32(cellColorScheme1.count)))

        let randomColor = cellColorScheme1[randomIndex]
        wineCell.backgroundColor = .clear
        wineCell.textLabel?.text = "Bastide Miraflors 2008"
        wineCell.textLabel?.textColor = .white
        wineCell.textLabel?.font = UIFont(name: "Raleway-Light", size: 16)
        return wineCell
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.flatPlum
        wineListTableView.backgroundColor = .clear
        //self.navigationController?.isNavigationBarHidden = false

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

/*extension UITableViewDataSource {
    
}

extension UITableViewDelegate {
    
}*/
