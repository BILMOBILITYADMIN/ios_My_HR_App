//
//  Charts.swift
//  Workbox
//
//  Created by Chetan Anand on 22/03/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import Foundation
import Charts


struct CWBarChartData {
    var chartTitle : String?
    var dataPointStrings : [String]?
    var valueDoubles : [Double]?
    var targetValue : Double?
    
    
    init(xAxisData : [String], dataPoint : [Double]) {
        dataPointStrings = xAxisData
        valueDoubles = dataPoint
    }
    
    func getChartData() -> BarChartData{
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<dataPointStrings!.count {
            let dataEntry = BarChartDataEntry(value: valueDoubles![i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(yVals: dataEntries, label: "Units Sold")
        let chartData = BarChartData(xVals: dataPointStrings, dataSet: chartDataSet)
        
        chartDataSet.colors = ChartColorTemplates.liberty()
        return chartData
    }
}

struct CWLineChartData {
    var chartTitle : String?
    var dataPointStrings : [String]? //Points on  XAxis
    var valueDoubles : [Double]? // Y values corresponding to each XAxis Points
    var targetValue : Double?
    
    
    init(xAxisData : [String], dataPoint : [Double]) {
        dataPointStrings = xAxisData
        valueDoubles = dataPoint
    }
    
    func getChartData() -> LineChartData{
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPointStrings!.count {
            let dataEntry = ChartDataEntry(value: valueDoubles![i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let lineChartDataSet = LineChartDataSet(yVals: dataEntries, label: "Units Sold")
        let lineChartData = LineChartData(xVals: dataPointStrings, dataSet: lineChartDataSet)
        
        let gradColors = [UIColor.cyanColor().CGColor, UIColor.clearColor().CGColor]
        let colorLocations:[CGFloat] = [0.0, 1.0]
        
        if let gradient = CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), gradColors, colorLocations) {
            lineChartDataSet.fill = ChartFill(linearGradient: gradient, angle: 90.0)
        }
        return lineChartData
    }
}


struct CWPieChartData {
    var chartTitle : String?
    var dataPointStrings : [String]? //Points on  XAxis
    var valueDoubles : [Double]? // Y values corresponding to each XAxis Points
    var targetValue : Double?
    
    
    init(xAxisData : [String], dataPoint : [Double]) {
        dataPointStrings = xAxisData
        valueDoubles = dataPoint
    }
    
    func getChartData() -> PieChartData{
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPointStrings!.count {
            let dataEntry = ChartDataEntry(value: valueDoubles![i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let pieChartDataSet = PieChartDataSet(yVals: dataEntries, label: "Units Sold")
        let pieChartData = PieChartData(xVals: dataPointStrings, dataSet: pieChartDataSet)
        
        var colors: [UIColor] = []
        
        for _ in 0..<dataPointStrings!.count {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }
        
        pieChartDataSet.colors = colors

        return pieChartData
    }
}



