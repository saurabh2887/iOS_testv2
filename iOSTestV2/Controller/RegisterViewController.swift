//
//  RegisterViewController.swift
//  iOSTestV2
//
//  Created by Saurabh Anand on 7/14/18.
//  Copyright © 2018 Saurabh Anand. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {

    @IBOutlet weak var userNameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    var viewModel : UserViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }

    // MARK: - Actions

    // This is called when Register button is pressed, username and passwords are mandatory fields to call the function from view model and after success, move to next view
    @IBAction func registerPressed(_ sender: UIButton) {
        if (userNameTextField.text?.count)! > 0{
            if (passwordTextField.text?.count)! > 0{
                viewModel.register(username: userNameTextField.text!, password: passwordTextField.text!) { (isSuccess, errorMsg) in
                    if errorMsg.count > 0{
                        self.showAlert(errorMsg: errorMsg)
                    }
                    else if isSuccess == true{
                        self.navigationController?.popToRootViewController(animated: true)
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
        let destinationVC = segue.destination as! AccountManagerViewController
        
        destinationVC.viewModel = viewModel

    }

}
