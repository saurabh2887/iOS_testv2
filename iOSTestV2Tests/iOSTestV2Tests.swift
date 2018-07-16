//
//  iOSTestV2Tests.swift
//  iOSTestV2Tests
//
//  Created by Saurabh Anand on 7/15/18.
//  Copyright © 2018 Saurabh Anand. All rights reserved.
//

import XCTest
import CoreData

@testable import iOSTestV2

class iOSTestV2Tests: XCTestCase {
    
    var testViewModel: UserViewModel!


    override func setUp() {
        super.setUp()
        
        
        testViewModel = UserViewModel()
        testViewModel.jwtToken = "12345"
    }
    
    override func tearDown() {
        testViewModel = nil
        super.tearDown()
    }

    func test_register(){
        
        var isRegistered = false
        
        testViewModel.register(username: "test", password: "1234") { (isSuccess, errorMsg) in
            isRegistered = isSuccess
        }
        
        XCTAssertFalse(isRegistered)
    }
    
    func test_logIn(){
        
        var isAbleToLogIn = false
        
        testViewModel.logIn(username: "test", password: "1234") { (isSuccess, errorMsg) in
            isAbleToLogIn = isSuccess
        }
        
        XCTAssertFalse(isAbleToLogIn)
    }
    
    func test_save(){
        
        var isAbleToSave = false
        
        var userDictionary = [String:Any]()
        userDictionary["age"] = 30
        userDictionary["feet"] = 6
        userDictionary["inches"] = 7
        userDictionary["likeJavaScripts"] = false
        userDictionary["magicNumber"] = 1400000
        userDictionary["magicHash"] = "Magic"

        testViewModel.saveUserDetails(userDetails: userDictionary) { (isSuccess, errorMsg) in
            isAbleToSave = isSuccess
        }
        
        XCTAssertFalse(isAbleToSave)

    }
    
    func test_getData(){
        var isAbleToFetch = false
        
        testViewModel.fetchUserDetails { (isSuccess, errorMsg) in
            isAbleToFetch = isSuccess
        }
        
        XCTAssertFalse(isAbleToFetch)
    }
    
}
