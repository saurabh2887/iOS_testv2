//
//  UserViewModel.swift
//  iOSTestV2
//
//  Created by Saurabh Anand on 7/14/18.
//  Copyright © 2018 Saurabh Anand. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import Alamofire
import JWTDecode

class UserViewModel{
    
    var userDetails : User!
    
    var jwtToken : String?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let baseURL = "https://mirror-ios-test.herokuapp.com"

    var httpHeaders : [String:String] = ["Content-Type" : "application/json", "Accept": "application/json"]

    //This method will be called from RegisterViewController, when user enters username and password and clicks register button.
    //Alamofire apis are used to call service api with POST as http method
    //Once closure returns the response, callback is invoked to return to view controller to either show error alert or move to next view
    //At the same time data is saved in persistent layer
    
    func register(username: String, password: String, completionHandler: @escaping (Bool, String) -> Void){
        userDetails = User(context: context)

        let params : [String : String] = ["username":username, "password":password]
        
        Alamofire.request("\(baseURL)/users", method: .post, parameters: params, encoding: JSONEncoding.default, headers: httpHeaders).responseJSON { (response) in
            if response.result.isSuccess{
                print("Success")
                
                print(response.result.value!)
                let responseData = response.result.value! as? Dictionary<String, Any>
                
                if responseData!["error"] != nil{
                    completionHandler(false,responseData!["error"] as! String)
                } else {
                    self.updateUserDetail(username: responseData!["username"] as! String,
                                          password: password,
                                          id: responseData!["id"] as! Int,
                                          age: responseData!["age"] as? Int ?? 0,
                                          height: responseData!["height"] as? Int ?? 0,
                                          likeJavaScript: responseData!["likes_javascript"] as! Bool,
                                          magicNumber: responseData!["magic_number"] as? Int ?? 0,
                                          magicHash: responseData!["magic_hash"] as? String ?? "")
                    
                    completionHandler(true,"")
                }
            } else{
                completionHandler(false,(response.error?.localizedDescription)!)
            }
        }

    }
    
    
    //This method will be called from WelcomeViewController, when user enters username and password and clicks Log In button.
    //Alamofire apis are used to call service api with POST as http method
    //Once closure returns the response, callback is invoked to return to view controller to either show error alert or move to next view
    //At the same time data is saved in persistent layer
    
    func logIn(username: String, password: String, completionHandler: @escaping (Bool, String) -> Void) {
        userDetails = User(context: context)
        
        let params : [String : String] = ["username":username, "password":password]
        
        Alamofire.request("\(baseURL)/auth", method: .post, parameters: params, encoding: JSONEncoding.default, headers: httpHeaders).responseJSON { (response) in
            if response.result.isSuccess{
                print(response.result.value!)
                let responseData = response.result.value! as? Dictionary<String, Any>
                
                if responseData!["error"] != nil{
                    completionHandler(false,responseData!["error"] as! String)
                } else {
                    
                    self.jwtToken = responseData!["access_token"] as? String
                    
                    let jwt = try? decode(jwt: self.jwtToken!)
                    let jwtBody = jwt?.body
                    
                    self.updateUserDetail(username: username,
                                          password: password,
                                          id: jwtBody!["identity"] as! Int,
                                          age: responseData!["age"] as? Int ?? 0,
                                          height: responseData!["height"] as? Int ?? 0,
                                          likeJavaScript: responseData!["likes_javascript"] as? Bool ?? false,
                                          magicNumber: responseData!["magic_number"] as? Int ?? 0,
                                          magicHash: responseData!["magic_hash"] as? String ?? "")
                    
                    completionHandler(true,"")
                }
            } else{
                completionHandler(false,(response.error?.localizedDescription)!)
            }
        }
    }
    
    
    //This method will be called from AccountManagerViewController to manage account
    //Alamofire apis are used to call service api with PATCH as http method
    //Once closure returns the response, callback is invoked to return to view controller to either show error alert or to refresh
    //At the same time data is saved in persistent layer
    // feet and inches are converted into cm and age in milliseconds
    
    func saveUserDetails(userDictionary: Dictionary<String, Any>, completionHandler: @escaping (Bool, String) -> Void) {
        
        // calculate all in inches and multiplied with 2.54
        var heightInCm = (userDictionary["feet"] as? Int)! * 12 + (userDictionary["inches"] as? Int)!
        heightInCm = Int(Double(heightInCm) * 2.54)

        let calendar = NSCalendar.current
        
        //First convert the age in years into birthdate
        let birthDate = calendar.date(byAdding: .year, value: -(userDictionary["age"] as! Int), to: NSDate() as Date)
        
        //Birthdate in milliseconds
        let ageInMilliSeconds = Int(((birthDate?.timeIntervalSince1970)! * 1000).rounded())
        
        let params : [String : Any] = ["age":ageInMilliSeconds,
                                       "height":heightInCm,
                                       "likes_javascript":userDictionary["likeJavaScripts"] as! Bool,
                                       "magic_number": userDictionary["magicNumber"] as? Int ?? 0 ,
                                       "magic_hash": userDictionary["magicHash"] as? String ?? ""]
        
        httpHeaders["Authorization"] = "JWT \(jwtToken!)"
        let url = "\(baseURL)/users/\(userDetails.id)"
        
        if let theJSONData = try?  JSONSerialization.data(
            withJSONObject: params,
            options: .prettyPrinted
            ),
            let theJSONText = String(data: theJSONData,
                                     encoding: String.Encoding.ascii) {
            print("JSON string = \n\(theJSONText)")
        }
    
        Alamofire.request(url, method: .patch, parameters: params, encoding: JSONEncoding.default, headers: httpHeaders).responseJSON { (response) in
            if response.result.isSuccess{
                print("Success")
                
                print(response.result.value!)
                let responseData = response.result.value! as? Dictionary<String, Any>
                
                if responseData!["error"] != nil{
                    completionHandler(false,responseData!["error"] as! String)
                } else {
                    self.updateUserDetail(username: self.userDetails!.username!,
                                          password: self.userDetails!.password!,
                                          id: responseData!["id"] as! Int,
                                          age: responseData!["age"] as? Int ?? 0,
                                          height: responseData!["height"] as? Int ?? 0,
                                          likeJavaScript: responseData!["likes_javascript"] as! Bool,
                                          magicNumber: responseData!["magic_number"] as? Int ?? 0,
                                          magicHash: responseData!["magic_hash"] as? String ?? "")
                    
                    completionHandler(true,"")
                }
            } else{
                completionHandler(false,(response.error?.localizedDescription)!)
            }
        }
    }
    
    //This method will be called from AccountManagerViewController to manage account
    //Alamofire apis are used to call service api with PATCH as http method
    //Once closure returns the response, callback is invoked to return to view controller to either show error alert or to load the data
    //At the same time data is saved in persistent layer
    //Age in milliseconds are reconverted and calculated to show in years
    
    func fetchUserDetails(completionHandler: @escaping (Bool, String) -> Void) {
        
        httpHeaders["Authorization"] = "JWT \(jwtToken!)"

        Alamofire.request("\(baseURL)/users/\(userDetails!.id)", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: httpHeaders).responseJSON { (response) in
            if response.result.isSuccess{
                print("Success")
                
                print(response.result.value!)
                let responseData = response.result.value! as? Dictionary<String, Any>
                
                if responseData!["error"] != nil{
                    completionHandler(false,responseData!["error"] as! String)
                } else {
                    self.updateUserDetail(username: responseData!["username"] as! String,
                                          password: self.userDetails!.password!,
                                          id: responseData!["id"] as! Int,
                                          age: responseData!["age"] as? Int ?? 0,
                                          height: responseData!["height"] as? Int ?? 0,
                                          likeJavaScript: responseData!["likes_javascript"] as! Bool,
                                          magicNumber: responseData!["magic_number"] as? Int ?? 0,
                                          magicHash: responseData!["magic_hash"] as? String ?? "")
                    
                    completionHandler(true,"")
                }
            } else{
                completionHandler(false,(response.error?.localizedDescription)!)
            }
        }
    }
    
    
    // Fetching the data from persistent container
    func fetchItem(){
        let request: NSFetchRequest<User> = User.fetchRequest()
        
        request.predicate = NSPredicate(format: "id MATCHES %@", userDetails!.id)
        
        do {
            userDetails = (try context.fetch(request).first)!
        } catch{
            print("Error fetching data from context \(error)")
        }
    }
    
    // saving the data in manageobject context and then save to persistent layer
    func saveContext(){
        if context.hasChanges{
            do{
                try context.save()
            } catch{
                print("Error in saving context \(error)")

            }
        }
    }
    
    // Updating the user data
    func updateUserDetail(username: String, password: String, id: Int, age: Int, height: Int, likeJavaScript: Bool, magicNumber: Int, magicHash: String){
        
        userDetails!.username = username
        userDetails!.password = password
        userDetails!.id = Int16(id)
        userDetails!.age = Int16(age)
        userDetails!.height = Int16(height)
        userDetails!.likeJavaScript = likeJavaScript
        userDetails!.magicHash = magicHash
        userDetails!.magicNumber = Int16(magicNumber)
        
        saveContext()

    }
}
