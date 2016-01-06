import UIKit

let now = NSDate()
// "Sep 23, 2015, 10:26 AM"
let olderDate = NSDate(timeIntervalSinceNow: -10000)
// "Sep 23, 2015, 7:40 AM"

var order = NSCalendar.currentCalendar().compareDate(now, toDate: olderDate,
    toUnitGranularity: .Hour)

switch order {
case .OrderedDescending:
    print("DESCENDING")
case .OrderedAscending:
    print("ASCENDING")
case .OrderedSame:
    print("SAME")
}

// Compare to hour: SAME

order = NSCalendar.currentCalendar().compareDate(now, toDate: olderDate,
    toUnitGranularity: .Day)

switch order {
case .OrderedDescending:
    print("DESCENDING")
case .OrderedAscending:
    print("ASCENDING")
case .OrderedSame:
    print("SAME")
}

// Compare to day: DESCENDING