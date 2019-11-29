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

class TTMDateUtility: NSObject {
    
    /*!
     * @method convertStringToDate:
     * @abstract This method converts a string in "yyyy-MM-dd" format to an NSDate object.
     * @param dateString An NSString in "yyyy-MM-dd" format. It must not contain time elements.
     * @return Returns a date object based on the date string.
     */
    @objc class func convertStringToDate(_ dateString: String) -> Date? {
        // dateString must not contain a time element.
        let dateFormatter = self.dateFormatter()
        return dateFormatter.date(from: dateString)
    }
    
    class func dateFormatter() -> DateFormatter {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }
    
    /*!
     * @method convertDateToString:
     * @abstract This method returns today's date as a string in "yyyy-MM-dd" format.
     * @param date The date to convert to a string.
     * @return The date parameter as a string in "yyyy-MM-dd" format.
     */
    @objc class func convertDateToString(_ date: Date) -> String {
        return self.dateFormatter().string(from: date)
    }
    
    /*!
     * @method todayAsString:
     * @abstract This method returns today's date.
     * @return Today's date.
     */
    @objc class func today() -> Date {
        return self.dateWithoutTime(Date())
    }
    
    /*!
     * @method todayAsString:
     * @abstract This method returns today's date as a string in "yyyy-MM-dd" format.
     * @return Today's date as a string in "yyyy-MM-dd" format.
     */
    @objc class func todayAsString() -> String {
        return self.convertDateToString(self.today())
    }
    
    /*!
     * @method addDays:toDate:
     * @abstract This method adds a number of days to the date.
     * @param days The number of days to add. Can be negative.
     * @param date The date to add days to.
     * @return A date offset by the given number of days.
     */
    @objc class func addDays(_ days: Int, toDate date: Date) -> Date? {
        return Calendar.current.date(byAdding: Calendar.Component.day, value: days, to: date)
    }
    
    /*!
     * @method dateWithoutTime:
     * @abstract This method strips the time element from a date.
     * @param date The date to return as of 00:00:00.
     * @return A date with the time element set to 00:00:00.
     * @discussion This method is necessary to allow for date "is equal" comparisons
     * in NSPredicateEditor.
     */
    @objc class func dateWithoutTime(_ date: Date) -> Date {
        return Calendar.current.startOfDay(for: date)
    }
    
    /*!
     * @method dateFromNaturalLanguageString:
     * @abstract This method returns a date based on a string such as "today" or "Monday".
     * @param string A string that could represent a relative due date.
     * @return A date, or nil if no date matches the string passed to the method.
     */
    class func dateFromNaturalLanguageString(_ string: String) -> Date? {
        // This method's structure of comparing localized strings, rather than just using
        // an NSDataDetector, came about because NSDataDetector does not properly find dates
        // in short strings such as "today", "tomorrow", or "Friday". NSDataDetector does find
        // dates when a time is specified, such as "today at 00:00", but it also finds the time
        // when nonsense plus a time is specified, as in "never at 00:00" (which returns today's date
        // at midnight).
        let todayString = Bundle.main.localizedString(forKey: "today", value: "today", table: "RelativeDates")
        if string.caseInsensitiveCompare(todayString) == .orderedSame {
            return self.today()
        }
        let tomorrowString = Bundle.main.localizedString(forKey: "tomorrow", value: "tomorrow", table: "RelativeDates")
        if string.caseInsensitiveCompare(tomorrowString) == .orderedSame {
            return self.addDays(1, toDate: self.today())
        }
        let yesterdayString = Bundle.main.localizedString(forKey: "yesterday", value: "yesterday", table: "RelativeDates")
        if string.caseInsensitiveCompare(yesterdayString) == .orderedSame {
            return self.addDays(-1, toDate: self.today())
        }
        let testString = string.lowercased()
        var returnDate: Date?
        let weekdayNames: [String] = [
            Bundle.main.localizedString(forKey: "Monday", value: "Monday", table: "RelativeDates").lowercased(),
            Bundle.main.localizedString(forKey: "Tuesday", value: "Tuesday", table: "RelativeDates").lowercased(),
            Bundle.main.localizedString(forKey: "Wednesday", value: "Wednesday", table: "RelativeDates").lowercased(),
            Bundle.main.localizedString(forKey: "Thursday", value: "Thursday", table: "RelativeDates").lowercased(),
            Bundle.main.localizedString(forKey: "Friday", value: "Friday", table: "RelativeDates").lowercased(),
            Bundle.main.localizedString(forKey: "Saturday", value: "Saturday", table: "RelativeDates").lowercased(),
            Bundle.main.localizedString(forKey: "Sunday", value: "Sunday", table: "RelativeDates").lowercased()
        ]
        returnDate = self.relativeDateFromWeekdayName(testString, withAllowedWeekdayNames: weekdayNames, withDateFormat: "eeee")
        if returnDate != nil {
            return returnDate
        }
        
        let shortWeekdayNames: [String] = [
            Bundle.main.localizedString(forKey: "Mon", value: "Mon", table: "RelativeDates").lowercased(),
            Bundle.main.localizedString(forKey: "Tue", value: "Tue", table: "RelativeDates").lowercased(),
            Bundle.main.localizedString(forKey: "Wed", value: "Wed", table: "RelativeDates").lowercased(),
            Bundle.main.localizedString(forKey: "Thu", value: "Thu", table: "RelativeDates").lowercased(),
            Bundle.main.localizedString(forKey: "Fri", value: "Fri", table: "RelativeDates").lowercased(),
            Bundle.main.localizedString(forKey: "Sat", value: "Sat", table: "RelativeDates").lowercased(),
            Bundle.main.localizedString(forKey: "Sun", value: "Sun", table: "RelativeDates").lowercased()
        ]
        return self.relativeDateFromWeekdayName(testString, withAllowedWeekdayNames: shortWeekdayNames, withDateFormat: "eee")
    }
    
    /*!
     * @method relativeDateFromWeekdayName:withAllowedWeekdayNames:withDateFormat
     * @abstract This method returns a date based on a string that represents a weekday name.
     * @return A date, or nil if no date matches the string passed to the method.
     * @param weekdayName A string that could be a weekday name.
     * @param allowedWeekdayNames An array of weekday names (or shortnames) that the weekdayName
     * will be tested to match.
     * @param dateFormat Date format to apply to the weekdayName for matching purposes.
     * @discussion This is a convenience method called from
     * relativeDateFromWeekdayName:withAllowedWeekdayNames:withDateFormat.
     */
    class func relativeDateFromWeekdayName(_ weekdayName: String, withAllowedWeekdayNames allowedWeekdayNames: [String], withDateFormat dateFormat: String) -> Date? {
        let weekdayNamesSet = Set(allowedWeekdayNames)
        if !weekdayNamesSet.contains(weekdayName) {
            return nil
        }
        let dateFormatter: DateFormatter = self.dateFormatter()
        dateFormatter.dateFormat = dateFormat
        let todaysDate = self.today()
        for i in 1..<8 {
            let testDate = self.addDays(i, toDate: todaysDate)
            if (testDate == nil) {
                return nil
            }
            let generatedWeekdayName = dateFormatter.string(from: testDate!).lowercased()
            if weekdayName.caseInsensitiveCompare(generatedWeekdayName) == .orderedSame {
                return testDate
            }
        }
        return nil
    }
    
    /*!
     * @method dateStringFromNaturalLanguageString:
     * @abstract This method returns a string-formatted date in "YYYY-MM-DD" format,
     * based on a string such as "today" or "Monday".
     * @param string A string that could represent a relative due date.
     * @return A string-formatted date in "YYYY-MM-DD" format, or nil if no date matches
     * the string passed to the method.
     */
    @objc class func dateStringFromNaturalLanguageString(_ naturalLanguageString: String) -> String? {
        let date = self.dateFromNaturalLanguageString(naturalLanguageString)
        if date == nil {
            return nil
        } else {
            return self.convertDateToString(date!)
        }
    }
    
    private static let secondsPerDay: Double = 24 * 60 * 60
    @objc class func daysBetweenDate(_ startDate: Date, andEndDate endDate: Date) -> Int {
        let interval = endDate.timeIntervalSince(startDate)
        return Int(interval / secondsPerDay)
    }
}

//MARK: - Date Extensions

extension Date {
    
    var currentCalendar: Calendar {
        return Calendar.current
    }
    
    func advanceDate(byWeekdays numberOfWeekdays: Int) -> Date {
        var relativeDate = self
        var weekdaysLeft = numberOfWeekdays
        while weekdaysLeft > 0 {
            let newDate = TTMDateUtility.addDays(1, toDate: relativeDate)
            if newDate == nil {
                return relativeDate
            }
            relativeDate = newDate!
            if relativeDate.isWeekday() {
                weekdaysLeft -= 1
            }
        }
        return relativeDate
    }
    
    func advanceDate(byNumberOfCalendarUnits numberOfUnits: Int, calendarUnit: Calendar.Component) -> Date? {
        return self.currentCalendar.date(byAdding: calendarUnit, value: numberOfUnits, to: self)
    }

    func isWeekendDay() -> Bool {
        return self.currentCalendar.isDateInWeekend(self)
    }
    
    func isWeekday() -> Bool {
        return !self.isWeekendDay()
    }
    
}
