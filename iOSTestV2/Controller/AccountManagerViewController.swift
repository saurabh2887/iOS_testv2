//
//  AccountManagerViewController.swift
//  iOSTestV2
//
//  Created by Saurabh Anand on 7/14/18.
//  Copyright © 2018 Saurabh Anand. All rights reserved.
//

import UIKit

class AccountManagerViewController: UIViewController {

    @IBOutlet weak var ageTextField: UITextField!
    
    @IBOutlet weak var heightInFeetTextField: UITextField!
    
    @IBOutlet weak var heightInInchesTextField: UITextField!
    
    @IBOutlet weak var likeJavaScriptsTextField: UITextField!
    
    @IBOutlet weak var magicNumberTextField: UITextField!
    
    @IBOutlet weak var magicHashTextField: UITextField!
    
    var viewModel : UserViewModel!
    
    let pickerView = UIPickerView()
    
    let pickerData = ["Unspecified", "Yes", "No"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        likeJavaScriptsTextField.inputView = pickerView
        pickerView.delegate = self
        
        ageTextField.delegate = self
        magicNumberTextField.delegate = self
        heightInFeetTextField.delegate = self
        heightInInchesTextField.delegate = self
        
        // On load should fetch latest data from backend
        fetchUserDetails()
    }
    
    //Observing the UIApplicationWillEnterForeground notification, to refresh the app when enters foreground
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(AccountManagerViewController.fetchUserDetails) , name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
    }
    
    //Removing the observer on UIApplicationWillEnterForeground notification
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    // MARK: - Actions

    // This is called when Save button is pressed, this method will prepare dictionary to pass the user enterd data to view model to save the data to the backend and in core data
    @IBAction func savePressed(_ sender: UIButton) {
        
        var userDictionary = [String:Any]()
        
        if (ageTextField.text?.count)! > 0{
            userDictionary["age"] = Int(ageTextField.text!)
        }
        
        if  (heightInFeetTextField.text?.count)! > 0{
            userDictionary["feet"] = Int(heightInFeetTextField.text!)
        }
        
        if (heightInInchesTextField.text?.count)! > 0{
            if Int(heightInInchesTextField.text!)! < 12{
                userDictionary["inches"] = Int(heightInInchesTextField.text!)
            }
            else{
                showAlert(errorMsg: "Invalid entry in inches field.")
                heightInInchesTextField.becomeFirstResponder()
            }
        }
        
        if (likeJavaScriptsTextField.text?.count)! > 0{
            userDictionary["likeJavaScripts"] = (likeJavaScriptsTextField.text! == "Yes")
        }
        
        if (magicNumberTextField.text?.count)! > 0{
            userDictionary["magicNumber"] = Int(magicNumberTextField.text!)
        }
        
        if (magicHashTextField.text?.count)! > 0{
            userDictionary["magicHash"] = magicHashTextField.text!
        }
        
        viewModel.saveUserDetails(userDictionary: userDictionary) { (isSuccess, errorMsg) in
            if errorMsg.count > 0{
                self.showAlert(errorMsg: errorMsg)
            }
        }
    }
    
    // This will return to Log In page
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    // MARK: - fetching user data
    
    //This method will call fetch method from view model to fetch user data and nce returned, values are set in UI
    @objc func fetchUserDetails(){
        viewModel.fetchUserDetails { (isSuccess, errorMsg) in
            if errorMsg.count > 0{
                self.showAlert(errorMsg: errorMsg)
            }
            else if isSuccess == true{
                if let age = self.viewModel.userDetails?.age{
                    self.ageTextField.text = String(age)
                }
                
                if let height = self.viewModel.userDetails?.height{
                    let totalInches = Double(height) / 2.54
                    
                    self.heightInFeetTextField.text = String(Int(totalInches) / 12)
                    self.heightInInchesTextField.text = String(Int(totalInches) % 12)
                }
                
                if let likeJavaScripts = self.viewModel.userDetails?.likeJavaScript{
                    self.likeJavaScriptsTextField.text = (likeJavaScripts == true) ? "Yes" : "No"
                }
                
                if let magicNumber = self.viewModel.userDetails?.magicNumber{
                    self.magicNumberTextField.text = String(magicNumber)
                }
                
                if let magicHash = self.viewModel.userDetails?.magicHash{
                    self.magicHashTextField.text = magicHash
                }
            }
        }
    }
    
    func showAlert(errorMsg :String){
        let alert = UIAlertController(title: "Alert", message: errorMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}

// MARK: - UIPickerView DataSource and Delegate for like java scripts field

extension AccountManagerViewController: UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate{
    
    // MARK: - Picker View Data source methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView( _ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    // MARK: - Picker View Delegate methods

    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if row == 0{
            likeJavaScriptsTextField.text = ""
        } else{
            likeJavaScriptsTextField.text = pickerData[row]
        }
    }
    
    
    // MARK: - Text field Delegate methods

    // Restrict age, height, magic number fields to enter only numbers
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard CharacterSet(charactersIn: "0123456789").isSuperset(of: CharacterSet(charactersIn: string)) else {
            return false
        }
        return true
    }
    
}
