# NWCalendarView
---

NWCalendar View is an IOS control that displays a calendar. It is perfect for appointment or availibilty selection. It allows for selection of a single date or a range. It also also to disable dates that are unavailable.


## Sample Usage


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


## Customization

Make sure to call `createCalendar()` setting your custom options


**disable dates**


```swift
// Takes an array of NSDates
calendarView.disabledDates = [newDate, newDate2, newDate3]
```

**Set Max Months**

You may only want to allow going aheader 4 months
```swift
calendarView.maxMonths = 4
```


## Delegate

**didChangeFromMonthToMonth(fromMonth: NSDateComponents, toMonth: NSDateComponents)**
```swift
func didChangeFromMonthToMonth(fromMonth: NSDateComponents, toMonth: NSDateComponents) {
  println("Change From month \(fromMonth) to month \(toMonth)")
}
```

**didSelectDate(fromDate: NSDateComponents, toDate: NSDateComponents)**
```swift
func didSelectDate(fromDate: NSDateComponents, toDate: NSDateComponents) {
  println("Selected date \(fromDate.date!) to date \(toDate.date!)")
}
```
