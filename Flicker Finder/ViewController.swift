//
//  ViewController.swift
//  Flicker Finder
//
//  Created by Tomas Koci on 7/23/15.
//  Copyright (c) 2015 Tomas Koci. All rights reserved.
//

import UIKit
import Foundation

let BASE_URL = "https://api.flickr.com/services/rest/"
let METHOD_NAME = "flickr.photos.search"
let API_KEY = "c275d3736a57c592390577d6f3e51904"
let EXTRAS = "url_m"
let DATA_FORMAT = "json"
let NO_JSON_CALLBACK = "1"
let MIN_TAKEN_DATE  = "2005-12-31 11:11:11"
let BOUNDING_BOX_SIDE_LENGTH = 0.5


class ViewController: UIViewController {
    
    // Define outlets
    @IBOutlet weak var searchByPhraseTextField: UITextField!
    @IBOutlet weak var longitudeTextField: UITextField!
    @IBOutlet weak var lattitudeTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var flickDescriptionLabel: UILabel!
    
    // Initialize the text field delegates
    let searchByPhraseDelegate = SearchByPhraseDelegate()
    let lattitudeDelegate = LattitudeDelegate()
    let longitudeDelegate = LongitudeDelegate()
    
    // Initialize a tap recognizer to be used to hide the keyboard
    var tapRecognizer: UITapGestureRecognizer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Setup the main view background image
        // self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background4")!)
        
        // Set the delegates for the text fields
        self.searchByPhraseTextField.delegate = searchByPhraseDelegate
        self.lattitudeTextField.delegate = lattitudeDelegate
        self.longitudeTextField.delegate = longitudeDelegate
        
        // Setup the tap gesture recognizer
        self.tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        self.tapRecognizer?.numberOfTapsRequired    = 1
    
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add the tap recognizer and subscribe to keyboard notifications
        self.addKeyboardDismissRecognizer()
        self.subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Dismiss the tap recognizer and unsubscribe from keyboard notifications
        self.removeKeyboardDismissRecognizer()
        self.unsubscribeToKeyboardNotifications()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /* ============================================================
    * Methods for handling UI problems
    * ============================================================ */
    
    /* 1 - Dismissing the keyboard */
    func addKeyboardDismissRecognizer() {
        self.view.addGestureRecognizer(tapRecognizer!)
    }
    
    func removeKeyboardDismissRecognizer() {
        self.view.removeGestureRecognizer(tapRecognizer!)
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    /* 2 - Shifting the keyboard so it does not hide controls */
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        self.view.frame.origin.y -= self.getKeyboardHeight(notification)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y += self.getKeyboardHeight(notification)
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        
        return keyboardSize.CGRectValue().height
    }
    
    /* ============================================================ */
    
    @IBAction func searchByPhrase(sender: UIButton) {
        
        // capture the text in the searchByPhrase text field
        let searchPhrase = self.searchByPhraseTextField.text
        
        // STEP 1: setup NSURLRequest parameters
        let parameters = ["method":METHOD_NAME,
        "api_key":API_KEY,
        "text": searchPhrase,
        "format":DATA_FORMAT,
        "nojsoncallback": NO_JSON_CALLBACK,
        "extras":EXTRAS]
        
        // STEP 2: assemble NSURL 
        let myNSURL     = NSURL(string: assembleURL(BASE_URL, requestParameters: parameters))!
        
        // STEP 3: Initialize NSURLSession and NSURLRequest
        let mySession   = NSURLSession.sharedSession()
        let myRequest   = NSURLRequest(URL: myNSURL)
        
        // STEP 4: NSURLTask
        
        let myTask      = mySession.dataTaskWithRequest(myRequest){data,response,error in
            
            // STEP 5: Conditionally unwrap error message
            if let errorMessage = error{
                println("shit hit the fan!")
            }
            else{
                // STEP 6: Parse the received JSON
                var parsingError: NSError? = nil
                let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                
                // STEP 7: Extract the array of photos from the parsed result
                if let photos = parsedResult["photos"] as? NSDictionary{
                    
                    let photoArray      = photos["photo"] as! [[String:AnyObject]]
                    let noPhotos        = photoArray.count
                
                    // STEP 8: Check if phot array contains any photos
                    if(noPhotos != 0){
                    
                        let randomPhotoIndex    = arc4random_uniform(UInt32(noPhotos))
                        let randomPhoto         = photoArray[Int(randomPhotoIndex)]
                        let randomPhotoURL      = randomPhoto["url_m"] as! String
                        let randomPhotoNSURL    = NSURL(string: randomPhotoURL)!
                        let randomImage         = UIImage(data: NSData(contentsOfURL: randomPhotoNSURL)!)

                        let randomPhotoDescription = randomPhoto["title"] as! String
                    
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.imageView.image = randomImage
                            self.flickDescriptionLabel.text = randomPhotoDescription
                            self.flickDescriptionLabel.lineBreakMode = .ByWordWrapping
                            self.flickDescriptionLabel.numberOfLines = 0
                        })
                    }
                        
                    else{
                        dispatch_async(dispatch_get_main_queue(), {()->Void in
                            self.flickDescriptionLabel.text = "No image found!"
                        })
                    }
                }
                else{
                    dispatch_async(dispatch_get_main_queue(), {()->Void in
                        self.flickDescriptionLabel.text = "No image found!"
                    })
                }
            }
        }
        myTask.resume()
    }
    
    @IBAction func searchByLatLong(sender: UIButton) {
        // capture the text in the searchByLattitude and searchByLongitude text fields
        
        let lattitude   = self.lattitudeTextField.text
        let longitude   = self.longitudeTextField.text
        let searchText  = self.searchByPhraseTextField.text
        
        let bbox        = getBbox(lattitude, longitudeString: longitude)
        println(bbox)
        
        // STEP 1: setup NSURLRequest parameters
        let parameters = ["method":METHOD_NAME,
            "api_key":API_KEY,
            "bbox": bbox,
            "format":DATA_FORMAT,
            "nojsoncallback": NO_JSON_CALLBACK,
            "extras":EXTRAS,
            "min_taken_date": MIN_TAKEN_DATE,
            "text": searchText]
        
        // STEP 2: assemble NSURL
        let myNSURL     = NSURL(string: assembleURL(BASE_URL, requestParameters: parameters))!
        
        // STEP 3: Initialize NSURLSession and NSURLRequest
        let mySession   = NSURLSession.sharedSession()
        let myRequest   = NSURLRequest(URL: myNSURL)
        
        // STEP 4: NSURLTask
        
        let myTask      = mySession.dataTaskWithRequest(myRequest){data,response,error in
            
            // STEP 5: Conditionally unwrap error message
            if let errorMessage = error{
                println("shit hit the fan!")
            }
            else{
                // STEP 6: Parse the received JSON
                var parsingError: NSError? = nil
                let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                
                // STEP 7: Extract the array of photos from the parsed result
                if let photos = parsedResult["photos"] as? NSDictionary{
                    
                    let photoArray      = photos["photo"] as! [[String:AnyObject]]
                    let noPhotos        = photoArray.count
                    
                    // STEP 8: Check if phot array contains any photos
                    if(noPhotos != 0){
                        
                        let randomPhotoIndex    = arc4random_uniform(UInt32(noPhotos))
                        let randomPhoto         = photoArray[Int(randomPhotoIndex)]
                        let randomPhotoURL      = randomPhoto["url_m"] as! String
                        let randomPhotoNSURL    = NSURL(string: randomPhotoURL)!
                        let randomImage         = UIImage(data: NSData(contentsOfURL: randomPhotoNSURL)!)
                        
                        let randomPhotoDescription = randomPhoto["title"] as! String
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.imageView.image = randomImage
                            self.flickDescriptionLabel.text = randomPhotoDescription
                            self.flickDescriptionLabel.lineBreakMode = .ByWordWrapping
                            self.flickDescriptionLabel.numberOfLines = 0
                        })
                    }
                        
                    else{
                        dispatch_async(dispatch_get_main_queue(), {()->Void in
                            self.flickDescriptionLabel.text = "No image found!"
                        })
                    }
                }
                else{
                    dispatch_async(dispatch_get_main_queue(), {()->Void in
                        self.flickDescriptionLabel.text = "No image found!"
                    })
                }
            }
        }
        myTask.resume()
    }
    
    
    func getBbox(lattitudeString: String, longitudeString: String)->String{
        let lattitude    = (lattitudeString as NSString).doubleValue
        let longitude    = (longitudeString as NSString).doubleValue
        
        
        var bbox                = "\(longitude - BOUNDING_BOX_SIDE_LENGTH),\(lattitude - BOUNDING_BOX_SIDE_LENGTH),\(longitude + BOUNDING_BOX_SIDE_LENGTH),\(lattitude + BOUNDING_BOX_SIDE_LENGTH)"
        return bbox
    }
    
    
    
    
    func assembleURL(baseURL:String,requestParameters:[String:AnyObject])->String{
        var completeURL = baseURL + "?"
        for (key,value) in requestParameters{
            let stringValue             = "\(value)"
            let validatedStringValue    = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
            
            completeURL += key + "=" + "\(validatedStringValue)" + "&"
        }
        completeURL = completeURL.substringToIndex(completeURL.endIndex.predecessor())
        return completeURL
    }


}

