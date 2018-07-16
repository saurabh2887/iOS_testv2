//
//  WelcomeViewController.swift
//  iOSTestV2
//
//  Created by Saurabh Anand on 7/14/18.
//  Copyright © 2018 Saurabh Anand. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    @IBOutlet weak var userNameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    //setting up the lazy property to call when in use
    lazy var viewModel: UserViewModel = {
        return UserViewModel()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    //Observing the UIApplicationWillEnterForeground notification, to refresh the app when enters foreground
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(WelcomeViewController.refreshApp) , name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
    }
    
    //Removing the observer on UIApplicationWillEnterForeground notification
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    //as part of refresh, it will relog in and move to next view and refresh the user details
    @objc func refreshApp(){
        if let username = viewModel.userDetails?.username , let password = viewModel.userDetails?.password{
            viewModel.logIn(username: username, password: password) { (isSuccess, errorMsg) in
                if errorMsg.count > 0{
                    self.showAlert(errorMsg: errorMsg)
                }
                else if isSuccess == true{
                    self.performSegue(withIdentifier: "goToAccountManager", sender: self)
                }
            }
        }
    }

    // MARK: - Actions

    // This is called when log in button is pressed, username and passwords are mandatory fields to move to call the function from view model
    @IBAction func logInPressed(_ sender: UIButton) {
        if (userNameTextField.text?.count)! > 0{
            if (passwordTextField.text?.count)! > 0{
                viewModel.logIn(username: userNameTextField.text!, password: passwordTextField.text!) { (isSuccess, errorMsg) in
                    if errorMsg.count > 0{
                        self.showAlert(errorMsg: errorMsg)
                    }
                    else if isSuccess == true{
                        self.performSegue(withIdentifier: "goToAccountManager", sender: self)
                    }
                }
            }else{
                showAlert(errorMsg: "Please enter password.")
                passwordTextField.becomeFirstResponder()
            }
        }
        else{
            showAlert(errorMsg: "Please enter user name.")
            userNameTextField.becomeFirstResponder()
        }
        
    }
    
    func showAlert(errorMsg :String){
        let alert = UIAlertController(title: "Alert", message: errorMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if (segue.identifier == "goToRegister") {
            let destinationVC = segue.destination as! RegisterViewController
            destinationVC.viewModel = viewModel
            
        } else if (segue.identifier == "goToAccountManager") {
            let destinationVC = segue.destination as! AccountManagerViewController
            destinationVC.viewModel = viewModel
        }
    }
    
}

