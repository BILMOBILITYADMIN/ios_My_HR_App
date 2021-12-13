//
//  Report03Card.swift
//  Workbox
//
//  Created by Chetan Anand on 23/03/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit
import Charts

class Report03Card: UITableViewCell {

    @IBOutlet weak var pieChartView : PieChartView!
    var lineChartData : CWPieChartData!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        UITableViewCell.setCellBackgroundView(self)
        
        let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        let unitsSold = [20.0, 4.0, 6.0, 3.0, 12.0, 16.0, 4.0, 18.0, 2.0, 4.0, 5.0, 4.0]
        
        lineChartData =  CWPieChartData(xAxisData: months, dataPoint: unitsSold)
        
        setChart(months, values: unitsSold)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setChart(dataPoints: [String], values: [Double]) {
        pieChartView.noDataText = "You need to provide data for the chart."
        
        pieChartView.data = lineChartData.getChartData()
        
        pieChartView.descriptionText = ""
        
        pieChartView.animate(yAxisDuration: 2.0, easingOption: .EaseOutBounce)
    }
    
}
