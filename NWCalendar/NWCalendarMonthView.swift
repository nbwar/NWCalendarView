//
//  NWCalendarMonthView.swift
//  NWCalendarDemo
//
//  Created by Nicholas Wargnier on 7/24/15.
//  Copyright (c) 2015 Nick Wargnier. All rights reserved.
//

import Foundation
import UIKit

protocol NWCalendarMonthViewDelegate {
  func didSelectDay(dayView: NWCalendarDayView, notifyDelegate: Bool)
  func selectDay(dayView: NWCalendarDayView)
}

class NWCalendarMonthView: UIView {
  private let kRowCount: CGFloat     = 6
  private let kNumberOfDaysPerWeek   = 7
  
  var delegate: NWCalendarMonthViewDelegate?
  
  var month        : NSDateComponents!
  var dayViewHeight: CGFloat!
  var columnWidths :[CGFloat]?
  var numberOfWeeks: Int!
  
  var dayViewsDict = Dictionary<String, NWCalendarDayView>()
  
  var dayViews:Set<NWCalendarDayView> {
    return Set(dayViewsDict.values)
  }
  
  var isCurrentMonth: Bool! = false {
    didSet {
      if isCurrentMonth == true {
        for dayView in dayViews {
          dayView.isActiveMonth = true
        }
        
      } else {
        for dayView in dayViews {
          dayView.isActiveMonth = false
        }
        
      }
    }
  }
  
  var disabledDates:[NSDateComponents]? {
    didSet {
      if let dates = disabledDates {
        for disabledDate in dates {
          let key = dayViewKeyForDay(disabledDate)
          let dayView = dayViewsDict[key]
          dayView?.isEnabled = false
        }
      }

    }
  }
  
  var availableDates:[NSDateComponents]? {
    didSet {
      if let availableDates = self.availableDates {
        for dayView in dayViews {
          if availableDates.contains(dayView.day!) {
            if disableSundays && dayView.day?.weekday == 1 {
              dayView.isEnabled = false
            } else {
              dayView.isEnabled = true
            }
          } else {
            dayView.isEnabled = false
          }
        }
      }
    }
  }
  
  var selectedDates:[NSDateComponents]? {
    didSet {
      if let dates = selectedDates {
        for selectedDate in dates {
          let key = dayViewKeyForDay(selectedDate)
          if let dayView = dayViewsDict[key] {
            delegate?.selectDay(dayView)
          }
          
        }
      }
    }
  }
  
  var disableSundays: Bool = false
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  convenience init(month: NSDateComponents, width: CGFloat, height: CGFloat, disableSundays: Bool=false) {
    self.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
    backgroundColor = UIColor.clearColor()
    dayViewHeight = frame.height/kRowCount
    self.month = month
    self.disableSundays = disableSundays
    calculateColumnWidths()
    createDays()
    numberOfWeeks = month.calendar!.rangeOfUnit(.WeekOfMonth, inUnit: .Month, forDate: month.date!).length
  }
  
  func disableMonth() {
    for dayView in dayViews {
      dayView.isEnabled = false
    }
  }
  
  func dayViewForDay(day: NSDateComponents) -> NWCalendarDayView? {
    let dayViewKey = dayViewKeyForDay(day)
    return dayViewsDict[dayViewKey]
  }
  
  
}

// MARK: - Layout
extension NWCalendarMonthView {
  func createDays() {
    
    let date: NSDate! = month.calendar?.dateFromComponents(month)!
    var day = month.calendar!.components([.Day, .Weekday, .Month, .Year, .Calendar], fromDate: date)
    let numberOfDaysInMonth = day.calendar?.rangeOfUnit(.Day, inUnit: .Month, forDate: day.date!).length
    
    var startColumn = day.weekday - day.calendar!.firstWeekday
    if startColumn < 0 {
      startColumn += kNumberOfDaysPerWeek
    }
    
    var nextDayViewOrigin = CGPointZero
    for (var column = 0; column < startColumn; column++) {
      nextDayViewOrigin.x += columnWidths![column]
    }
    
    
    while (day.day <= numberOfDaysInMonth && day.month == month.month) {
      for(var column = startColumn; column < kNumberOfDaysPerWeek; column++) {
        if day.month == month.month {
          let dayView = createDayView(nextDayViewOrigin, width: columnWidths![column])
          dayView.delegate = self
          dayView.setDayForDay(day)
          
          // Disable Sundays
          if day.weekday == 1 && disableSundays {
            dayView.isEnabled = false
          }
          
          
          let dayViewKey = dayViewKeyForDay(day)
          dayViewsDict[dayViewKey] = dayView
          addSubview(dayView)
        }
        let nextDate = day.calendar?.dateByAddingUnit(.Day, value: 1, toDate: day.date!, options: NSCalendarOptions(rawValue: 0))
        day = nextDate!.nwCalendarView_dayWithCalendar(day.calendar!)
        nextDayViewOrigin.x += columnWidths![column]
      }
      
      nextDayViewOrigin.x = 0
      nextDayViewOrigin.y += dayViewHeight
      startColumn = 0
    }
  }
  
  func createDayView(origin: CGPoint, width: CGFloat)-> NWCalendarDayView {
    var dayFrame = CGRectZero
    dayFrame.origin = origin
    dayFrame.size.width = width
    dayFrame.size.height = dayViewHeight
    
    return NWCalendarDayView(frame: dayFrame)
  }
  
  
  func calculateColumnWidths() {
    columnWidths = NWCalendarCache.sharedCache.objectForKey(kNumberOfDaysPerWeek) as? [CGFloat]
    if columnWidths == nil {
      let columnCount:CGFloat = CGFloat(kNumberOfDaysPerWeek)
      let width      :CGFloat = floor(bounds.size.width / CGFloat(columnCount))
      var remainder  :CGFloat = bounds.size.width - (width * CGFloat(columnCount))
      var padding    :CGFloat = 1
      
      columnWidths = [CGFloat](count: kNumberOfDaysPerWeek, repeatedValue: width)
      
      if remainder > columnCount {
        padding = ceil(remainder/columnCount)
      }
      
      
      for (index, _) in (columnWidths!).enumerate() {
        columnWidths![index] = width + padding
        
        remainder -= padding
        if remainder < 1 {
          break
        }
      }
      NWCalendarCache.sharedCache.setObjectForKey(columnWidths!, key: kNumberOfDaysPerWeek)
    }
    
  }
  
  func dayViewKeyForDay(day: NSDateComponents) -> String {
    return "\(day.month)/\(day.day)/\(day.year)"
  }
}

// MARK: - Touch Handling
extension NWCalendarMonthView {
  override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
    for subview in subviews {
      if !subview.hidden && subview.alpha > 0 && subview.userInteractionEnabled && subview.pointInside(convertPoint(point, toView: subview), withEvent: event) {
        return true
      }
    }
    return false
  }
}

// MARK: - NWCalendarDayViewDelegate
extension NWCalendarMonthView: NWCalendarDayViewDelegate {
  func dayButtonPressed(dayView: NWCalendarDayView) {
    delegate?.didSelectDay(dayView, notifyDelegate: true)
  }
}