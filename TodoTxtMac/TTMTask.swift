/**
* @author Michael Descy
* @copyright 2014-2015 Michael Descy
* @discussion Dual-licensed under the GNU General Public License and the MIT License
*
* Ported to Swift by Kenny Pitt
*
*
*
* @license GNU General Public License http://www.gnu.org/licenses/gpl.html
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program.  If not, see <http://www.gnu.org/licenses/>.
*
*
*
*
* @license The MIT License (MIT)
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

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
