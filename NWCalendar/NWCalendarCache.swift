//
//  NWCalendarCache.swift
//  NWCalendarDemo
//
//  Created by Nicholas Wargnier on 7/24/15.
//  Copyright (c) 2015 Nick Wargnier. All rights reserved.
//

import Foundation

class NWCalendarCache {
  static let sharedCache = NWCalendarCache()
  private var token: dispatch_once_t = 0
  
  var cache: NSCache!

  
  init() {
    dispatch_once(&token, {
      self.cache = NSCache()
    })
  }
  
  func objectForKey(key: AnyObject) -> AnyObject? {
    return cache.objectForKey(key)
  }
  
  func setObjectForKey(object: AnyObject, key: AnyObject) {
    cache.setObject(object, forKey: key)
  }
  
}