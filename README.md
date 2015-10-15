# NWCalendarView

NWCalendar View is an IOS control that displays a calendar. It is perfect for appointment or availibilty selection. It allows for selection of a single date or a range. It also allows to disable dates that are unavailable.

<p align="center">
  <img src="http://i.imgur.com/XsIX6F6.png" height=400 width=400/>
</p>


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

You may only want to allow going 4 months into the future
```swift
calendarView.maxMonths = 4
```

**Set selection Range** (defaults to 0)

```swift
selectionRangeLength = 7
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

## TODO
1. Enable going into the past
2. Dynamic adding of months when scrolling in to past
3. Make all aspects customizable (font, colors, etc..)
4. Turn into cocoapod

## License
MIT
