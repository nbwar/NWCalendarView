# NWCalendarView

**Usage**


```swift
@IBOutlet weak var calendarView: NWCalendarView!

override func viewDidLoad() {
  super.viewDidLoad()

  calendarView.layer.borderWidth = 1
  calendarView.layer.borderColor = UIColor.lightGrayColor().CGColor
  calendarView.backgroundColor = UIColor.whiteColor()


  var date = NSDate()
  let newDate = date.dateByAddingTimeInterval(60*60*24*8)
  let newDate2 = date.dateByAddingTimeInterval(60*60*24*9)
  let newDate3 = date.dateByAddingTimeInterval(60*60*24*30)
  calendarView.disabledDates = [newDate, newDate2, newDate3]
  calendarView.selectionRangeLength = 7
  calendarView.maxMonths = 4
  calendarView.delegate = self
  calendarView.createCalendar()
}
```
