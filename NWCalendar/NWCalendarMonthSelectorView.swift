import UIKit
import Foundation

class NWCalendarMonthSelectorView: UIView {
  private let kPrevButtonImage:UIImage! = UIImage(named: "NWCalendar-prev-month")
  private let kNextButtonImage:UIImage! = UIImage(named: "NWCalendar-next-month")
  private let kMonthColor:UIColor!      = UIColor(red:0.475, green:0.475, blue:0.475, alpha: 1)
  private let kMonthFont:UIFont!        = UIFont(name: "Avenir-Medium", size: 16)
  private let kSeperatorColor:UIColor!  = UIColor(red:0.973, green:0.973, blue:0.973, alpha: 1)
  private let kSeperatorWidth:CGFloat!  = 1.5
  
  var prevButton: UIButton!
  var nextButton: UIButton!
  var monthLabel: UILabel!
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    let buttonWidth = floor(frame.width/7)
    prevButton = UIButton(frame: CGRect(x: 0, y: 0, width: buttonWidth, height: frame.height))
    prevButton.setImage(kPrevButtonImage, forState: .Normal)

    nextButton = UIButton(frame: CGRect(x: frame.width-buttonWidth, y: 0, width: buttonWidth, height: frame.height))
    nextButton.setImage(kNextButtonImage, forState: .Normal)

    monthLabel = UILabel(frame: CGRect(x: buttonWidth, y: 0, width: frame.width-(2*buttonWidth), height: frame.height))
    monthLabel.textAlignment = .Center
    monthLabel.textColor = kMonthColor
    monthLabel.font = kMonthFont
    monthLabel.text = "January 2015"
    
    addSubview(prevButton)
    addSubview(nextButton)
    addSubview(monthLabel)
    
    addSeperator(0)
    addSeperator(frame.height-kSeperatorWidth)
  }
  
  
  private func addSeperator(y: CGFloat) {
    let seperator = CALayer()
    seperator.backgroundColor = kSeperatorColor.CGColor
    seperator.frame = CGRect(x: 0, y: y, width: frame.width, height: kSeperatorWidth)
    layer.addSublayer(seperator)
  }
}

extension NWCalendarMonthSelectorView {
  func updateMonthLabelForMonth(month: NSDateComponents) {
    let formatter = NSDateFormatter()
    formatter.dateFormat = "MMMM yyyy"
    let date = month.calendar?.dateFromComponents(month)
    monthLabel.text = formatter.stringFromDate(date!)
  }
}
