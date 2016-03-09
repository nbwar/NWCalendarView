//
//  NWCalendarView.swift
//  NWCalendarDemo
//
//  Created by Nicholas Wargnier on 7/23/15.
//  Copyright (c) 2015 Nick Wargnier. All rights reserved.
//

import UIKit

@objc protocol NWCalendarViewDelegate {
  optional func didChangeFromMonthToMonth(fromMonth: NSDateComponents, toMonth: NSDateComponents)
  optional func didSelectDate(fromDate: NSDateComponents, toDate: NSDateComponents)
}


public class NWCalendarView: UIView {
  private let kMenuHeightPercentage:CGFloat = 0.256
  
  weak var delegate: NWCalendarViewDelegate?
  
  var menuView          : NWCalendarMenuView!
  var monthContentView  : NWCalendarMonthContentView!
  var visibleMonth      : NSDateComponents! {
    didSet {
      updateMonthLabel(visibleMonth)
    }
  }
  
  public var disableSundays:Bool = false {
    didSet {
      monthContentView.disableSundays = disableSundays
    }
  }
  
  public var selectionRangeLength: Int? {
    didSet {
      monthContentView.selectionRangeLength = selectionRangeLength
    }
  }
  
  public var disabledDates:[NSDate]? {
    didSet {
      monthContentView.disabledDates = disabledDates
    }
  }
  
  public var maxMonths: Int? {
    didSet {
      monthContentView.maxMonths = maxMonths
    }
  }
  
  public var selectedDates: [NSDate]? {
    didSet {
      monthContentView.selectedDates = selectedDates
    }
  }
  
  public var availableDates: [NSDate]? {
    didSet {
      monthContentView.availableDates = availableDates
    }
  }
  
  // MARK: Initialization
  override public init(frame: CGRect) {
    super.init(frame: frame)
    
    commonInit()
  }
  
  // IB Init
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
   
    commonInit()
  }
  
  func commonInit() {
    clipsToBounds = true
    
    let unitFlags: NSCalendarUnit = [.Year, .Month, .Day, .Weekday, .Calendar]
    visibleMonth = NSCalendar.usLocaleCurrentCalendar().components(unitFlags, fromDate: NSDate())
    
    visibleMonth.day = 1
    
    let menuHeight = floor(frame.height*kMenuHeightPercentage)
    menuView = NWCalendarMenuView(frame: CGRect(x: 0, y: 0, width: frame.width, height: menuHeight))
    menuView.delegate = self
    
    let monthContentViewHeight = frame.height - menuHeight
    let monthContentViewY = CGRectGetMaxY(menuView.frame)
    monthContentView = NWCalendarMonthContentView(month: visibleMonth, frame: CGRect(x: 0, y: monthContentViewY, width: frame.width, height: monthContentViewHeight))
    monthContentView.clipsToBounds = true
    monthContentView.monthContentViewDelegate = self
    
    addSubview(menuView)
    addSubview(monthContentView)
    
    updateMonthLabel(visibleMonth)
  }
  
  public func createCalendar() {
    monthContentView.createCalendar()
  }
  
  
  public func scrollToDate(date: NSDate, animated: Bool) {
    let comp = NSCalendar.usLocaleCurrentCalendar().components([.Year, .Month, .Day, .Weekday, .Calendar], fromDate: date)
    
    if maxMonths != nil && !monthContentView.monthIsGreaterThanMaxMonth(comp) {
      updateMonthLabel(comp)
      monthContentView.scrollToDate(comp, animated: animated)
    }

  }
}

// MARK - NWCalendarMonthSelectorView
extension NWCalendarView {
  func updateMonthLabel(month: NSDateComponents) {
    if menuView != nil {
      menuView.monthSelectorView.updateMonthLabelForMonth(month)
    }
  }
}


// MARK: - NWCalendarMenuViewDelegate
extension NWCalendarView: NWCalendarMenuViewDelegate {
  func prevMonthPressed() {
    monthContentView.prevMonth()
  }
  
  func nextMonthPressed() {
    monthContentView.nextMonth()
  }
}

// MARK: - NWCalendarMonthContentViewDelegate
extension NWCalendarView: NWCalendarMonthContentViewDelegate {
  func didChangeFromMonthToMonth(fromMonth: NSDateComponents, toMonth: NSDateComponents) {
    visibleMonth = toMonth
    delegate?.didChangeFromMonthToMonth?(fromMonth, toMonth: toMonth)
  }
  
  func didSelectDate(fromDate: NSDateComponents, toDate: NSDateComponents) {
    delegate?.didSelectDate?(fromDate, toDate: toDate)
  }
}
