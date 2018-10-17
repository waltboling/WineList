//
//  KeyboardExtension.swift
//  WineList
//
//  Created by Jon Boling on 7/27/18.
//  Copyright © 2018 Walt Boling. All rights reserved.
//

import Foundation
import UIKit

extension UITextView {
    func addDoneCancelToolbar(onDone: (target: Any, action: Selector)? = nil, onCancel: (target: Any, action: Selector)? = nil) {
        let onCancel = onCancel ?? (target: self, action: #selector(didCancelInput))
        let onDone = onDone ?? (target: self, action: #selector(didEnterInput))
        let toolbar: UIToolbar = UIToolbar()
        
        toolbar.barStyle = .default
        toolbar.items = [
            UIBarButtonItem(title: "Cancel", style: .plain, target: onCancel.target, action: onCancel.action),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Done", style: .done, target: onDone.target, action: onDone.action)
        ]
        toolbar.sizeToFit()
        
        self.inputAccessoryView = toolbar
    }
    
    // Default actions:
    @objc func didEnterInput() {
        self.resignFirstResponder()
        
    }
    
    @objc func didCancelInput() {
        self.resignFirstResponder()
    }
}

extension UITextField {
    func addDoneCancelToolbar(onDone: (target: Any, action: Selector)? = nil, onCancel: (target: Any, action: Selector)? = nil) {
        let onCancel = onCancel ?? (target: self, action: #selector(didCancelInput))
        let onDone = onDone ?? (target: self, action: #selector(didEnterInput))
        let toolbar: UIToolbar = UIToolbar()
        
        toolbar.barStyle = .default
        toolbar.items = [
            UIBarButtonItem(title: "Cancel", style: .plain, target: onCancel.target, action: onCancel.action),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Done", style: .done, target: onDone.target, action: onDone.action)
        ]
        toolbar.sizeToFit()
        
        self.inputAccessoryView = toolbar
    }
    
    // Default actions:
    /*@objc func didEnterInput(nextField: UITextField) {
        self.resignFirstResponder()
        nextField.becomeFirstResponder()
        
    }*/ // trying to get price field to act like the rest
    @objc func didEnterInput() {
        self.resignFirstResponder()
    }
    
    
    @objc func didCancelInput() {
        self.resignFirstResponder()
    }
    
    //to set diff placeholder color. doesnt seem to be working
    @IBInspectable var placeHolderColor: UIColor? {
            get {
                return self.placeHolderColor
            }
            set {
                self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
            }
        }
}
