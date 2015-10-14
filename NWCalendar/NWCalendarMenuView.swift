//
//  NWCalendarMenuView.swift
//  NWCalendarDemo
//
//  Created by Nicholas Wargnier on 7/23/15.
//  Copyright (c) 2015 Nick Wargnier. All rights reserved.
//

import UIKit

protocol NWCalendarMenuViewDelegate {
  func prevMonthPressed()
  func nextMonthPressed()
}

class NWCalendarMenuView: UIView {
  private let kDayColor = UIColor(red:0.475, green:0.475, blue:0.475, alpha: 1)
  private let kDayFont  = UIFont(name: "Avenir-Roman", size: 14)
  
  var delegate         : NWCalendarMenuViewDelegate?
  var monthSelectorView: NWCalendarMonthSelectorView!
  var days             : [String]  = []
  var sectionHeight    : CGFloat {
    return frame.height/2
  }
  
  init() {
    super.init(frame: .zero)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = UIColor.whiteColor()

    monthSelectorView = NWCalendarMonthSelectorView(frame: CGRect(x: 0, y: 0, width: frame.width, height: sectionHeight))
    monthSelectorView.prevButton.addTarget(self, action: "prevMonthPressed:", forControlEvents: .TouchUpInside)
    monthSelectorView.nextButton.addTarget(self, action: "nextMonthPressed:", forControlEvents: .TouchUpInside)
    addSubview(monthSelectorView)
    
    setupDays()
    setupDayLabels()
  }
  
  func setupDays() {
    let dateFormatter = NSDateFormatter()
    days = dateFormatter.shortWeekdaySymbols as [String]
  }
  
  
  func setupDayLabels() {
    let width = frame.width / 7
    let height = sectionHeight
    
    var x:CGFloat = 0
    let y:CGFloat = CGRectGetMaxY(monthSelectorView.frame)
    
    for i in 0..<7 {
      x = CGFloat(i) * width
      createDayLabel(x, y: y, width: width, height: height, day: days[i])
    }
    
  }
  
  func createDayLabel(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, day: String) {
    let dayLabel = UILabel(frame: CGRect(x: x, y: y, width: width, height: height))
    dayLabel.textAlignment = .Center
    dayLabel.text = day.uppercaseString
    dayLabel.font = kDayFont
    dayLabel.textColor = kDayColor
    addSubview(dayLabel)
  }
  
}


// MARK: NWCalendarMonthSelectorView Actions
extension NWCalendarMenuView {
  func prevMonthPressed(sender: AnyObject) {
    delegate?.prevMonthPressed()
  }
  
  func nextMonthPressed(sender: AnyObject) {
    delegate?.nextMonthPressed()
  }
}
