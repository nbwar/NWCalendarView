//
//  NWCalendarMonthContentView.swift
//  NWCalendarDemo
//
//  Created by Nicholas Wargnier on 7/24/15.
//  Copyright (c) 2015 Nick Wargnier. All rights reserved.
//

import Foundation
import UIKit


protocol NWCalendarMonthContentViewDelegate {
  func didChangeFromMonthToMonth(fromMonth: NSDateComponents, toMonth: NSDateComponents)
  func didSelectDate(fromDate: NSDateComponents, toDate: NSDateComponents)
}

class NWCalendarMonthContentView: UIScrollView {
  private let unitFlags: NSCalendarUnit = [.Year, .Month, .Day, .Weekday, .Calendar]
  private let kCurrentMonthOffset = 4
  
  var monthContentViewDelegate:NWCalendarMonthContentViewDelegate?
  
  var presentMonth         : NSDateComponents!
  var monthViewsDict   = Dictionary<String, NWCalendarMonthView>()
  var monthViews    : [NWCalendarMonthView] = []
  
  var dayViewHeight       : CGFloat             = 44
  var pastEnabled                               = false
  var presentMonthIndex   : Int!                = 0
  var selectionRangeLength: Int!                = 0
  var selectedDayViews    : [NWCalendarDayView] = []
  var lastMonthOrigin     : CGFloat?
  
  var maxMonth            : NSDateComponents?
  var maxMonths           : Int! = 0 {
    didSet {
      if maxMonths > 0 {
        let date = NSCalendar.usLocaleCurrentCalendar().dateByAddingUnit(.Month, value: maxMonths, toDate: presentMonth.date!, options: [])!
        let month = date.nwCalendarView_monthWithCalendar(presentMonth.calendar!)
        maxMonth = month
      }
    }
  }
  var futureEnabled: Bool {
    return maxMonths == 0
  }

  var disabledDatesDict: [String: [NSDateComponents]] = [String: [NSDateComponents]]()
  var disabledDates:[NSDate]? {
    didSet {
      if let dates = disabledDates {
        for date in dates {
          let comp = NSCalendar.usLocaleCurrentCalendar().components([.Year, .Month, .Day, .Weekday, .Calendar], fromDate: date)
          let key = monthViewKeyForMonth(comp)
          if var compArray = disabledDatesDict[key] {
            compArray.append(comp)
            disabledDatesDict[key] = compArray
          } else {
            let compArray:[NSDateComponents] = [comp]
            disabledDatesDict[key] = compArray
          }
        }
      }
    }
  }
  
  var selectedDatesDict: [String: [NSDateComponents]] = [String: [NSDateComponents]]()
  var selectedDates: [NSDate]? {
    didSet {
      if let dates = selectedDates {
        for date in dates {
          let comp = NSCalendar.usLocaleCurrentCalendar().components([.Year, .Month, .Day, .Weekday, .Calendar], fromDate: date)
          let key = monthViewKeyForMonth(comp)
          if var compArray = selectedDatesDict[key] {
            compArray.append(comp)
            selectedDatesDict[key] = compArray
          } else {
            let compArray:[NSDateComponents] = [comp]
            selectedDatesDict[key] = compArray
          }
        }
      }
    }
  }
  
  var showOnlyAvailableDates = false
  var availableDatesDict: [String: [NSDateComponents]] = [String: [NSDateComponents]]()
  var availableDates: [NSDate]? {
    didSet {
      if let dates = availableDates {
        showOnlyAvailableDates = true
        for date in dates {
          let comp = NSCalendar.usLocaleCurrentCalendar().components([.Year, .Month, .Day, .Weekday, .Calendar], fromDate: date)
          let key = monthViewKeyForMonth(comp)
          if var compArray = availableDatesDict[key] {
            compArray.append(comp)
            availableDatesDict[key] = compArray
          } else {
            let compArray:[NSDateComponents] = [comp]
            availableDatesDict[key] = compArray
          }
        }
      }
    }
  }
  
  var disableSundays: Bool = false
  
  var currentMonthView: NWCalendarMonthView! {
    return monthViews[currentPage]
  }
  
  
  var monthViewOrigins: [CGFloat] = []
  var currentPage:Int! {
    didSet(oldPage) {
      if currentPage == oldPage { return }
      let oldMonthView = monthViews[oldPage]
      
      monthContentViewDelegate?.didChangeFromMonthToMonth(oldMonthView.month, toMonth: currentMonthView.month)
      UIView.animateWithDuration(0.3, animations: {
        self.currentMonthView.isCurrentMonth = true
        oldMonthView.isCurrentMonth = false
      })
      
      if oldPage < currentPage {
        appendMonthIfNeeded()
      } else {
        // TODO: Prepend for past
      }
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    clipsToBounds = true
    delegate = self
    showsHorizontalScrollIndicator = false
    showsVerticalScrollIndicator = false
    decelerationRate = UIScrollViewDecelerationRateFast
    presentMonthIndex = kCurrentMonthOffset
    dayViewHeight = frame.height / 6
    currentPage = kCurrentMonthOffset
    
  }
  
  convenience init(month: NSDateComponents, frame: CGRect) {
    self.init(frame: frame)
    presentMonth = month
  }
  
  func createCalendar() {
    setupMonths(presentMonth)
  }

  func setupMonths(month: NSDateComponents) {
    for (var monthOffset = -kCurrentMonthOffset; monthOffset <= 7; monthOffset+=1) {
      var offsetMonth = month.copy() as! NSDateComponents
      offsetMonth.month = offsetMonth.month + monthOffset
      
      
      offsetMonth = offsetMonth.calendar!.components(unitFlags, fromDate: offsetMonth.date!)
      createMonthViewForMonth(offsetMonth)
    }
    
    scrollToOffset(monthViewOrigins[kCurrentMonthOffset], animated: false)
  }
  
}

// MARK: - Navigation
extension NWCalendarMonthContentView {
  func nextMonth() {
    if !futureEnabled && lastMonthOrigin != nil {
      if monthViewOrigins[currentPage+1] <= lastMonthOrigin {
        currentPage = currentPage+1
        scrollToOffset(monthViewOrigins[currentPage], animated:true)
      }
    } else {
      let totalMonths = monthViews.count-1
      currentPage = min(currentPage+1, totalMonths)
      scrollToOffset(monthViewOrigins[currentPage], animated:true)
    }

  }

  func prevMonth() {
    currentPage = pastEnabled ? max(currentPage-1, 0) : max(currentPage-1, presentMonthIndex)
    scrollToOffset(monthViewOrigins[currentPage], animated:true)
  }
  
  func scrollToOffset(yOffset: CGFloat, animated: Bool) {
    setContentOffset(CGPoint(x: 0, y: yOffset), animated: animated)
  }
  
  func scrollToDate(dateComps: NSDateComponents, animated: Bool) {
    let key = monthViewKeyForMonth(dateComps)
    
    if let monthView = monthViewsDict[key] {
      if let index = monthViews.indexOf(monthView) {
        if monthViewOrigins[index] <= lastMonthOrigin {
          currentPage = index
          scrollToOffset(monthViewOrigins[currentPage], animated: animated)
        }
      }
    }
  }
}
  
// MARK: - Layout
extension NWCalendarMonthContentView {
  func createMonthViewForMonth(month: NSDateComponents) {
    var overlapOffset:CGFloat = 0
    var lastMonthMaxY:CGFloat = 0
    if monthViews.count > 0 {
      let lastMonthView = monthViews[monthViews.count-1]
      lastMonthMaxY = CGRectGetMaxY(lastMonthView.frame)
      
      if lastMonthView.numberOfWeeks == 6 || monthStartsOnFirstDayOfWeek(month) {
        if lastMonthView.numberOfWeeks == 4 {
            overlapOffset = self.dayViewHeight * 2
        } else {
            overlapOffset = self.dayViewHeight
        }
      } else {
        overlapOffset = dayViewHeight * 2
      }
    }
    
    // Create & Position Month View
    let monthView = cachedOrCreateMonthViewForMonth(month)
    
    monthView.frame.origin.y = lastMonthMaxY - overlapOffset
    monthViewOrigins.append(monthView.frame.origin.y)
    
    contentSize.height = lastMonthMaxY
    
    if !futureEnabled {
      if monthIsEqualToMaxMonth(monthView.month) {
        lastMonthOrigin = monthView.frame.origin.y
      } else if monthIsGreaterThanMaxMonth(monthView.month) {
        monthView.disableMonth()
      } 
    }
    
    if monthIsEqualToPresentMonth(month) {
      monthView.isCurrentMonth = true
    }
    
    let key = monthViewKeyForMonth(month)
    if let disabledArray = disabledDatesDict[key] {
      monthView.disabledDates = disabledArray
    }
    
    if let availableArray = availableDatesDict[key] {
      monthView.availableDates = availableArray
    } else if showOnlyAvailableDates {
      monthView.availableDates = []
    }
    
    if let selectedArray = selectedDatesDict[key] {
      monthView.selectedDates = selectedArray
    }
    
  }
  
  func appendMonthIfNeeded() {
    if currentPage >= monthViews.count - 3 {
      let newMonth = monthViews.last!.month.copy() as! NSDateComponents
      newMonth.month += 1
      createMonthViewForMonth(newMonth.date!.nwCalendarView_monthWithCalendar(newMonth.calendar!))
    }
  }
  
  func monthIsEqualToPresentMonth(month: NSDateComponents) -> Bool {
    return month.month == presentMonth.month && month.year == presentMonth.year
  }
  
  func monthIsGreaterThanMaxMonth(month: NSDateComponents) -> Bool {
    return month.year > maxMonth?.year || (month.month > maxMonth?.month && maxMonth?.year <= month.year)
  }
  
  func monthIsEqualToMaxMonth(month: NSDateComponents) -> Bool {
    return maxMonth!.month == month.month && maxMonth!.year == month.year
  }
}

// MARK: - Caching
extension NWCalendarMonthContentView {
  func monthStartsOnFirstDayOfWeek(month: NSDateComponents) -> Bool{
    let month = month.calendar!.components(unitFlags, fromDate: month.date!)
    return (month.weekday - month.calendar!.firstWeekday) == 0
  }
  
  func monthViewKeyForMonth(month: NSDateComponents) -> String {
    let month = month.calendar?.components([.Year, .Month], fromDate: month.date!)
    return "\(month!.year).\(month!.month)"
  }
  
  func cachedOrCreateMonthViewForMonth(month: NSDateComponents) -> NWCalendarMonthView {
    let month = month.calendar?.components(unitFlags, fromDate: month.date!)
    let monthViewKey = monthViewKeyForMonth(month!)
    var monthView = monthViewsDict[monthViewKey]
    
    if monthView == nil {
      monthView = NWCalendarMonthView(month: month!, width: bounds.width, height: bounds.height, disableSundays: disableSundays)
      monthViewsDict[monthViewKey] = monthView
      monthViews.append(monthView!)
      monthView?.delegate = self
      addSubview(monthView!)
    }

    return monthView!
    
  }
}


// MARK: - UIScrollViewDelegate
extension NWCalendarMonthContentView: UIScrollViewDelegate {
  func scrollViewDidScroll(scrollView: UIScrollView) {
    
    // Disable scrolling to past
    if !pastEnabled {
      let presentMonthOrigin = monthViewOrigins[presentMonthIndex]
      if scrollView.contentOffset.y < presentMonthOrigin{
        setContentOffset(CGPoint(x: 0, y: presentMonthOrigin), animated: false)
      }
    }
    
    // Disable scrolling to future beyond max month
    if !futureEnabled && lastMonthOrigin != nil {
      if scrollView.contentOffset.y > lastMonthOrigin {
        setContentOffset(CGPoint(x: 0, y: lastMonthOrigin!), animated: false)
      }
    }

  }
  
  func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    let currentOrigin = monthViewOrigins[currentPage]
    
    var targetOffset = targetContentOffset.memory.y
    
    if targetOffset < currentOrigin-dayViewHeight {
      currentPage = (pastEnabled == false) ? max(currentPage-1, presentMonthIndex) : max(currentPage-1, 0)
      targetOffset = monthViewOrigins[currentPage]
    } else if targetOffset > currentOrigin+dayViewHeight {
      
      if !futureEnabled && lastMonthOrigin != nil {
        if monthViewOrigins[currentPage+1] <= lastMonthOrigin {
          currentPage = currentPage+1
        }
      } else {
        currentPage = min(currentPage+1, monthViews.count-1)
      }
      
      targetOffset = monthViewOrigins[currentPage]
    } else {
      targetOffset = currentOrigin
    }
    
    targetContentOffset.memory = CGPoint(x: 0, y: targetOffset)
  }
}

// MARK: - NWCalendarMonthViewDelegate
extension NWCalendarMonthContentView: NWCalendarMonthViewDelegate {
  func didSelectDay(dayView: NWCalendarDayView, notifyDelegate: Bool) {
    if selectionRangeLength > 0 {
      clearSelectedDays()
      var day = dayView.day?.copy() as! NSDateComponents
      
      for _ in 0..<selectionRangeLength {
        day = day.date!.nwCalendarView_dayWithCalendar(day.calendar!)
        let month = day.date!.nwCalendarView_monthWithCalendar(day.calendar!)
        let monthViewKey = monthViewKeyForMonth(month)
        let monthView = monthViewsDict[monthViewKey]
        let dayView = monthView?.dayViewForDay(day)
        
        if let unwrappedDayView = dayView {
          selectDay(unwrappedDayView)
        }
        
        day.day += 1
      }
      
      day.day -= 1
      day = day.date!.nwCalendarView_dayWithCalendar(day.calendar!)
      
      if notifyDelegate {
        changeMonthIfNeeded(dayView.day!, toDay: day)
        monthContentViewDelegate?.didSelectDate(dayView.day!, toDate: day)
      }
      
    }
  }
  
  func selectDay(dayView: NWCalendarDayView) {
    dayView.isSelected = true
    selectedDayViews.append(dayView)
  }
  
  func clearSelectedDays() {
    if selectedDayViews.count > 0 {
      for dayView in selectedDayViews {
        dayView.isSelected = false
      }
    }
  }
  
  func changeMonthIfNeeded(fromDay: NSDateComponents, toDay: NSDateComponents) {
    if fromDay.month < currentMonthView.month.month && fromDay.year <= currentMonthView.month.year{
      prevMonth()
    } else if fromDay.month > currentMonthView.month.month && fromDay.year >= currentMonthView.month.year {
      nextMonth()
    } else if fromDay.year > currentMonthView.month.year {
      nextMonth()
    } else if fromDay.year < currentMonthView.month.year {
      prevMonth()
    }
  }

}