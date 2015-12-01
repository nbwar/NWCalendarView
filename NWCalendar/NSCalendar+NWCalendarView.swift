//
//  NSCalendar+NWCalendarView.swift
//  NWCalendarDemo
//
//  Created by Nicholas Wargnier on 12/1/15.
//  Copyright © 2015 Nick Wargnier. All rights reserved.
//

import Foundation
import UIKit

extension NSCalendar {
  class func usLocaleCurrentCalendar() -> NSCalendar {
    let us = NSLocale(localeIdentifier: "en_US")
    let calendar = NSCalendar.currentCalendar()
    calendar.locale = us
    return calendar
  }
}
