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

class TTMTasklistMetadata : NSObject {
    
    var projectsSet: Set<String> = []
    var contextsSet: Set<String> = []
    var prioritiesSet: Set<String> = []
    @objc var contextsArray: [String] = []
    @objc var projectsArray: [String] = []
    @objc var prioritiesArray: [String] = []
    var projectTaskCounts: [String: Int] = [:]
    var contextTaskCounts: [String: Int] = [:]
    var priorityTaskCounts: [String: Int] = [:]
    @objc var allTaskCount: Int = 0
    @objc var completedTaskCount: Int = 0
    @objc var incompleteTaskCount: Int = 0
    @objc var dueTodayTaskCount: Int = 0
    @objc var overdueTaskCount: Int = 0
    @objc var notDueTaskCount: Int = 0
    @objc var noDueDateTaskCount: Int = 0
    @objc var projectsCount: Int = 0
    @objc var contextsCount: Int = 0
    @objc var prioritiesCount: Int = 0
    @objc var hiddenCount: Int = 0
    
    /*!
     * @method updateMetadataFromTaskArray:
     * @abstract Generates metadata from a list of tasks.
     * @param taskArray An array of TTMTask objects.
     */
    @objc func updateMetadataFromTaskArray(_ taskArray: [TTMTask]) {
        self.initialize()
        for task in taskArray {
            // update task counts
            self.allTaskCount += 1
            self.completedTaskCount += (task.isCompleted ? 1 : 0)
            self.incompleteTaskCount += (task.isCompleted ? 0 : 1)
            self.dueTodayTaskCount += (task.dueState == DueToday ? 1 : 0)
            self.overdueTaskCount += (task.dueState == Overdue ? 1 : 0)
            self.notDueTaskCount += (task.dueState == NotDue ? 1 : 0)
            self.noDueDateTaskCount += (task.dueState == NoDueDate ? 1 : 0)
            self.hiddenCount += (task.isHidden ? 1 : 0)
            // update task counts by project and context
            self.projectTaskCounts.incrementCounts(forKeys: task.projectsArray as [String])
            self.contextTaskCounts.incrementCounts(forKeys: task.contextsArray as [String])
            // add all projects and contexts to sets
            self.projectsSet.insert(fromArray: task.projectsArray)
            self.contextsSet.insert(fromArray: task.contextsArray)
            // update task count by priority, and add priority to set
            if task.priorityText != nil {
                self.priorityTaskCounts.incrementCounts(forKeys: [task.priorityText])
                self.prioritiesSet.insert(task.priorityText)
            }
        }
        // Convert the sets to case-insensitive-sorted arrays.
        self.projectsArray = self.projectsSet.sorted{$0.caseInsensitiveCompare($1) == .orderedAscending}
        self.contextsArray = self.contextsSet.sorted{$0.caseInsensitiveCompare($1) == .orderedAscending}
        self.prioritiesArray = self.prioritiesSet.sorted{$0.caseInsensitiveCompare($1) == .orderedAscending}
        // update counts of projects, contexts, and priorities
        self.projectsCount = self.projectsSet.count
        self.contextsCount = self.contextsSet.count
        self.prioritiesCount = self.prioritiesSet.count
    }
    
    /*!
     * @method initialize:
     * @abstract Helper function to populate task counts in the properties projectTaskCounts,
     * contextTaskCounts, and priorityTaskCounts. Called in method updateMetadataFromTaskArray:.
     */
    private func initialize() {
        self.allTaskCount = 0
        self.completedTaskCount = 0
        self.incompleteTaskCount = 0
        self.dueTodayTaskCount = 0
        self.overdueTaskCount = 0
        self.notDueTaskCount = 0
        self.noDueDateTaskCount = 0
        self.hiddenCount = 0
        self.projectTaskCounts = [:]
        self.contextTaskCounts = [:]
        self.priorityTaskCounts = [:]
        self.projectsSet = []
        self.contextsSet = []
        self.prioritiesSet = []
        self.projectsArray = []
        self.contextsArray = []
        self.prioritiesArray = []
        self.projectsCount = 0
        self.contextsCount = 0
        self.prioritiesCount = 0
    }
    
    @objc var projects: String? {
        return self.projectsArray.joined(separator: "\n")
    }
    
    @objc var contexts: String? {
        return self.contextsArray.joined(separator: "\n")
    }
    
}

extension Set {
    mutating func insert(fromArray values: [Set.Element]) {
        values.forEach({ v in self.insert(v) })
    }
}

// FIXME: An extension method is not ideal for application-specific functionality.
//     The counts dictionaries should probably converted to a custom class that
//     encapsulates or extends the dictionary.
extension Dictionary where Key == String, Value == Int {
    mutating func incrementCounts(forKeys keys: [String]) {
        for key in keys {
            if let count = self[key] {
                self[key] = count + 1
            } else {
                self[key] = 1
            }
        }
    }
}
