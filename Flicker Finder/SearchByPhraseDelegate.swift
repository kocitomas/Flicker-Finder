//
//  SearchByPhraseDelegate.swift
//  Flicker Finder
//
//  Created by Tomas Koci on 7/23/15.
//  Copyright (c) 2015 Tomas Koci. All rights reserved.
//

import Foundation
import UIKit

class SearchByPhraseDelegate: NSObject,UITextFieldDelegate{
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
