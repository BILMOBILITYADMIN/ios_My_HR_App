//
//  WorkboxTests.swift
//  WorkboxTests
//
//  Created by Ratan D K on 01/12/15.
//  Copyright © 2015 Incture Technologies. All rights reserved.
//

import XCTest
@testable import Workbox

class WorkboxTests: XCTestCase {
    
    var TSHomeVC:TSHomeController?
     weak var tableView: UITableView!
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
//        TSHomeVC =  UIStoryboard.TimeSheet().instantiateViewControllerWithIdentifier(String(TSHomeController)) as? TSHomeController
//        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> TSHomeCell {
//            return TSHomeCell()
//        }
        TSHomeVC = TSHomeController()
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
    func testtimeinFloatForTSHomeController(){
        let expectedResult:Float = 1
      let actualResult = TSHomeVC?.getTimeInHours("60")
        XCTAssertEqual(expectedResult, actualResult!, "not same")
    }
    
}
