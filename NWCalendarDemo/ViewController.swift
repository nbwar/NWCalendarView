//
//  ViewController.swift
//  NWCalendarDemo
//
//  Created by Nicholas Wargnier on 7/23/15.
//  Copyright (c) 2015 Nick Wargnier. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  @IBOutlet weak var calendarView: NWCalendarView!

  override func viewDidLoad() {
    super.viewDidLoad()
    
    calendarView.layer.borderWidth = 1
    calendarView.layer.borderColor = UIColor.lightGrayColor().CGColor
    calendarView.backgroundColor = UIColor.whiteColor()
    
    
    let date = NSDate()
//    let newDate = date.dateByAddingTimeInterval(60*60*24*2)
    let newDate2 = date.dateByAddingTimeInterval(60*60*24*3)
    let newDate3 = date.dateByAddingTimeInterval(60*60*24*4)
    print(newDate3)
    calendarView.disabledDates = [newDate3]
//    calendarView.disableSundays = true
//    calendarView.availableDates = [newDate, newDate2, newDate3]
    calendarView.selectedDates = [newDate2]
    calendarView.selectionRangeLength = 7
    calendarView.maxMonths = 4
    calendarView.delegate = self
    calendarView.createCalendar()
    
    calendarView.scrollToDate(newDate3, animated: true)
    

  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()

  }

}

extension ViewController: NWCalendarViewDelegate {
  func didChangeFromMonthToMonth(fromMonth: NSDateComponents, toMonth: NSDateComponents) {
    let dateFormatter: NSDateFormatter = NSDateFormatter()
    
    let months = dateFormatter.standaloneMonthSymbols
    let fromMonthName = months[fromMonth.month-1] as String
    let toMonthName = months[toMonth.month-1] as String
    
    print("Change From '\(fromMonthName)' to '\(toMonthName)'")
  }
  
  func didSelectDate(fromDate: NSDateComponents, toDate: NSDateComponents) {
    print("Selected date '\(fromDate.month)/\(fromDate.day)/\(fromDate.year)' to date '\(toDate.month)/\(toDate.day)/\(toDate.year)'")
  }
}