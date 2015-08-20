//
//  LongitudeDelegate.swift
//  Flicker Finder
//
//  Created by Tomas Koci on 7/23/15.
//  Copyright (c) 2015 Tomas Koci. All rights reserved.
//

import Foundation
import UIKit

class LongitudeDelegate: NSObject,UITextFieldDelegate{
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text as NSString
        let updatedText = currentText.stringByReplacingCharactersInRange(range, withString: string)
        
        let updatedLongitude = (updatedText as NSString).doubleValue
        
        if(updatedLongitude < 179 && updatedLongitude > -179){
            return true
        }
        return false
    }
}