//
//  TTMTask.swift
//  TodoTxtMac
//
//  Created by Kenny Pitt on 11/27/19.
//  Copyright © 2019 Michael Descy. All rights reserved.
//

import Foundation

@objc(TTMTask)
class TTMTask : TTMTaskBase {
    
    //MARK: - Recurrence Methods
    
    @objc func newRecurringTask() -> TTMTask? {
        if !isRecurring {
            return nil
        }

        let newTask = copy() as! TTMTask

        newTask.advanceDueDateBasedOnReccurencePattern(TTMDateUtility.today())

        if thresholdDateText != nil {
            var numberOfDaysThresholdDateIsBeforeDueDate = 0
            if dueDateText == nil {
                numberOfDaysThresholdDateIsBeforeDueDate = TTMDateUtility.daysBetweenDate(thresholdDate, andEndDate: TTMDateUtility.today())
            } else if dueDateText != nil && thresholdDateText != nil {
                numberOfDaysThresholdDateIsBeforeDueDate = TTMDateUtility.daysBetweenDate(thresholdDate, andEndDate: dueDate)
            }
            if numberOfDaysThresholdDateIsBeforeDueDate < 0 {
                numberOfDaysThresholdDateIsBeforeDueDate = 0
            }
            newTask.setThresholdDateBased(daysBetweenThresholdDateAndDueDate: numberOfDaysThresholdDateIsBeforeDueDate)
        }

        return newTask
    }

    private func advanceDueDateBasedOnReccurencePattern(_ completionDate: Date?) {
        var oldDueDate: Date?
        if dueDateText == nil || !recurrencePatternIsStrict() {
            oldDueDate = completionDate
        } else {
            oldDueDate = dueDate
        }
        let newDueDate = relativeDateBasedOnRecurrencePattern(oldDueDate)
        setDueDate(newDueDate)
    }

    private func setThresholdDateBased(daysBetweenThresholdDateAndDueDate daysBetweenThresholdAndDueDates: NSInteger) {
        let dateAdjustment = (daysBetweenThresholdAndDueDates > 0) ? -1 * daysBetweenThresholdAndDueDates : 0
        let newThresholdDate = dueDate.advanceDate(byNumberOfCalendarUnits: dateAdjustment, calendarUnit: .day)
        setThresholdDate(newThresholdDate)
    }
    
    private func recurrencePatternIsStrict() -> Bool {
        recurrencePattern.hasPrefix("+")
    }

    private func calendarUnitFromRecurrencePattern() -> Calendar.Component {
        if (recurrencePattern == nil) {
            return .era // not a real return value
        }

        let lastChar = (recurrencePattern.uppercased() as NSString).substring(from: recurrencePattern.count - 1)
        if (lastChar == "D") {
            return .day
        }
        if (lastChar == "W") {
            return .weekOfYear
        }
        if (lastChar == "M") {
            return .month
        }
        if (lastChar == "Y") {
            return .year
        }
        if (lastChar == "B") {
            return .weekday
        }

        return .era // not a real return value
    }

    private func numberOfCalendarUnitsFromRecurrencePattern() -> Int {
        let startOffset = recurrencePatternIsStrict() ? 1 : 0
        let rangeStart = recurrencePattern.index(recurrencePattern.startIndex, offsetBy: startOffset)
        let rangeEnd = recurrencePattern.index(recurrencePattern.endIndex, offsetBy: -1)
        let recurrenceUnits = String(recurrencePattern[rangeStart..<rangeEnd])
        return Int(recurrenceUnits) ?? 0
    }

    private func relativeDateBasedOnRecurrencePattern(_ date: Date?) -> Date? {
        let calendarUnit = calendarUnitFromRecurrencePattern()
        if calendarUnit == .era {
            return nil
        }

        let numberOfCalendarUnits = numberOfCalendarUnitsFromRecurrencePattern()
        if calendarUnit == .weekday {
            return date?.advanceDate(byWeekdays: numberOfCalendarUnits)
        } else {
            return date?.advanceDate(byNumberOfCalendarUnits: numberOfCalendarUnits, calendarUnit: calendarUnit)
        }
    }

}
