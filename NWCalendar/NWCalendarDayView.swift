//
//  NWCalendarDayView.swift
//  NWCalendarDemo
//
//  Created by Nicholas Wargnier on 7/24/15.
//  Copyright (c) 2015 Nick Wargnier. All rights reserved.
//

import Foundation
import UIKit

protocol NWCalendarDayViewDelegate {
  func dayButtonPressed(dayView: NWCalendarDayView)
}

class NWCalendarDayView: UIView {
  private let kDayFont             = UIFont(name: "Avenir-Roman", size: 14)
  private let kAvailableColor      = UIColor(red:0.475, green:0.475, blue:0.475, alpha: 1)
  private let kNotAvailableColor   = UIColor(red:0.890, green:0.890, blue:0.890, alpha: 1)
  private let kNonActiveMonthColor = UIColor(red:0.949, green:0.949, blue:0.949, alpha: 1)
  private let kActiveMonthColor    = UIColor.whiteColor()
  private let kSelectedColor       = UIColor(red:0.988, green:0.325, blue:0.341, alpha: 1)
  
  var delegate : NWCalendarDayViewDelegate?
  var dayLabel : UILabel!
  var dayButton: UIButton!
  var date     : NSDate? {
    didSet {
      if let unwrappedDate = date {
        if unwrappedDate.nwCalendarView_dayIsInPast() {
          isInPast = true
        }
      }
    }
  }
  
  var day: NSDateComponents? {
    didSet {      
      date = day?.date
      dayButton.setTitle("\(day!.day)", forState: .Normal)
    }
  }
  
  var isActiveMonth = false {
    didSet {
      setNotSelectedBackgroundColor()
    }
  }
  
  var isInPast = false {
    didSet {
      isEnabled = !isInPast
    } 
  }
  
  var isEnabled = true {
    didSet {
      dayButton.enabled = isEnabled
    }
  }
  
  var isSelected = false {
    didSet {
      if isSelected {
        backgroundColor = kSelectedColor
        dayButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        dayButton.setTitleColor(UIColor.whiteColor(), forState: .Disabled)
      } else {
        setNotSelectedBackgroundColor()
        dayButton.setTitleColor(kAvailableColor, forState: .Normal)
        dayButton.setTitleColor(kNotAvailableColor, forState: .Disabled)
      }
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = kNonActiveMonthColor
    
    dayButton = UIButton(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
    dayButton.titleLabel?.textAlignment = .Center
    dayButton.titleLabel?.font = kDayFont
    dayButton.setTitleColor(kAvailableColor, forState: .Normal)
    dayButton.setTitleColor(kNotAvailableColor, forState: .Disabled)
    dayButton.addTarget(self, action: "dayButtonPressed:", forControlEvents: .TouchUpInside)
    addSubview(dayButton)
  }

  func dayButtonPressed(sender: AnyObject) {
    delegate?.dayButtonPressed(self)
  }
  
  func setDayForDay(day: NSDateComponents) {
    self.day = day.date!.nwCalendarView_dayWithCalendar(day.calendar!)
  }
  
  func setNotSelectedBackgroundColor() {
    if !isSelected {
      if isActiveMonth {
        backgroundColor = kActiveMonthColor
      } else {
        backgroundColor = kNonActiveMonthColor
      }
    }
  }
}