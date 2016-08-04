//
//  WMModelTests.swift
//  WMModelTests
//
//  Created by kc on 16/8/3.
//  Copyright © 2016年 WM. All rights reserved.
//

import XCTest
@testable import WMModel

class WMModelTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        let ss = "{\"title\":\"你好\",\"Hash\":\"你好1\",\"image\":\"www.baidu.com\" }"
        
       
     
        print(KCBannerTopModel.wm_model(ss).wm_dict())

    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
