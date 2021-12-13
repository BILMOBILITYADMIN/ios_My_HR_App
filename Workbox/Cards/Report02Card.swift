//
//  Report02Card.swift
//  Workbox
//
//  Created by Chetan Anand on 23/03/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit
import Charts

class Report02Card: UITableViewCell {

    @IBOutlet weak var lineChartView : LineChartView!
    var lineChartData : CWLineChartData!


    override func awakeFromNib() {
        super.awakeFromNib()
        UITableViewCell.setCellBackgroundView(self)

        // Initialization code
        let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        let unitsSold = [20.0, 4.0, 6.0, 3.0, 12.0, 16.0, 4.0, 18.0, 2.0, 4.0, 5.0, 4.0]
        
        lineChartData =  CWLineChartData(xAxisData: months, dataPoint: unitsSold)
        
        setChart(months, values: unitsSold)

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setChart(dataPoints: [String], values: [Double]) {
        lineChartView.noDataText = "You need to provide data for the chart."
        
        lineChartView.data = lineChartData.getChartData()
        
        lineChartView.descriptionText = ""
        
        lineChartView.xAxis.labelPosition = .Bottom
        lineChartView.animate(yAxisDuration: 2.0, easingOption: .EaseOutBounce)
    }
    
}
