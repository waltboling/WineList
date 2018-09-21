//
//  ViewController.swift
//  WineList
//
//  Created by Jon Boling on 6/2/18.
//  Copyright © 2018 Walt Boling. All rights reserved.
//

import UIKit
import ChameleonFramework

class MainMenuVC: UIViewController {
    let colors:[UIColor] = [
        UIColor.flatPlum,
        UIColor.flatMaroonDark
    ]
    
    @IBOutlet weak var mainTitleLabel: UILabel!
    
    @IBOutlet weak var addNewWineButton: UIButton!
    
    @IBOutlet weak var goToWineListButton: UIButton!
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = GradientColor(.topToBottom, frame: view.frame, colors: colors)
        //createMainTitleLabel()
        configureButtons(button: addNewWineButton)
        configureButtons(button: goToWineListButton)
        //self.navigationController?.isNavigationBarHidden = true
        
    }
    
    //cant get custom font to work
    func createMainTitleLabel() {
        mainTitleLabel.text = "WineList"
        mainTitleLabel.font = UIFont(name: "Raleway-Regular", size: 40)
    }
    
    func configureButtons(button: UIButton) {
        button.layoutIfNeeded()
        button.subviews.first?.contentMode = .scaleAspectFit
    }
    
    @IBAction func wineListWasTapped(_ sender: Any) {
        performSegue(withIdentifier: "toWineList", sender: self)
    }
    
    @IBAction func addWineWasTapped(_ sender: Any) {
        performSegue(withIdentifier: "toNewWineVC", sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

