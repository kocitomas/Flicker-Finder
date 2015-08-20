//
//  LattitudeDelegate.swift
//  Flicker Finder
//
//  Created by Tomas Koci on 7/23/15.
//  Copyright (c) 2015 Tomas Koci. All rights reserved.
//

import Foundation
import UIKit

class LattitudeDelegate: NSObject,UITextFieldDelegate{
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text as NSString
        let updatedText = currentText.stringByReplacingCharactersInRange(range, withString: string)
        
        let updatedLattitude = (updatedText as NSString).doubleValue
        
        if(updatedLattitude < 89 && updatedLattitude > -89){
            return true
        }
        return false
    }
}