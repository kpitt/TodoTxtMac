/**
 * @author Michael Descy
 * @copyright 2014-2015 Michael Descy
 * @discussion Dual-licensed under the GNU General Public License and the MIT License
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

#import "TTMPredicateEditorDueRowTemplate.h"
#import "TodoTxtMac-Swift.h"

@implementation TTMPredicateEditorDueRowTemplate

//MARK: - Class Property Getters

- (NSPopUpButton*)keypathPopUp {
    if(!_keypathPopUp) {
        NSMenu *keypathMenu = [[NSMenu alloc]
                               initWithTitle:@"due state menu"];
        
        NSMenuItem *menuItem = [[NSMenuItem alloc]
                                initWithTitle:@"due state"
                                action:nil
                                keyEquivalent:@""];
        [menuItem setRepresentedObject:[NSExpression expressionForKeyPath:@"dueState"]];
        [menuItem setEnabled:YES];
        
        [keypathMenu addItem:menuItem];
        
        _keypathPopUp = [[NSPopUpButton alloc] initWithFrame:NSZeroRect pullsDown:NO];
        [_keypathPopUp setMenu:keypathMenu];
    }
    return _keypathPopUp;
}

- (NSPopUpButton*)dueStatePopUp {
    if (!_dueStatePopUp) {
        NSMenuItem *dueTodayItem = [[NSMenuItem alloc] initWithTitle:@"due today"
                                                              action:nil
                                                       keyEquivalent:@""];
        [dueTodayItem setRepresentedObject:[NSExpression expressionForConstantValue:@(DueToday)]];
        [dueTodayItem setEnabled:YES];
        [dueTodayItem setTag:(long)DueToday];
        
        NSMenuItem *dueSoonItem = [[NSMenuItem alloc] initWithTitle:@"due soon"
                                                              action:nil
                                                       keyEquivalent:@""];
        [dueSoonItem setRepresentedObject:[NSExpression expressionForConstantValue:@(DueSoon)]];
        [dueSoonItem setEnabled:YES];
        [dueSoonItem setTag:(long)DueSoon];
        
        NSMenuItem *overdueItem = [[NSMenuItem alloc] initWithTitle:@"overdue"
                                                              action:nil
                                                       keyEquivalent:@""];
        [overdueItem setRepresentedObject:[NSExpression expressionForConstantValue:@(Overdue)]];
        [overdueItem setEnabled:YES];
        [overdueItem setTag:(long)Overdue];
        
        NSMenuItem *notDueItem = [[NSMenuItem alloc] initWithTitle:@"not due"
                                                              action:nil
                                                       keyEquivalent:@""];
        [notDueItem setRepresentedObject:[NSExpression expressionForConstantValue:@(NotDue)]];
        [notDueItem setEnabled:YES];
        [notDueItem setTag:(long)NotDue];

        NSMenuItem *noDueDateItem = [[NSMenuItem alloc] initWithTitle:@"no due date"
                                                            action:nil
                                                     keyEquivalent:@""];
        [noDueDateItem setRepresentedObject:[NSExpression expressionForConstantValue:@(NoDueDate)]];
        [noDueDateItem setEnabled:YES];
        [noDueDateItem setTag:(long)NoDueDate];
        
        NSMenu *dueStateMenu = [[NSMenu alloc] initWithTitle:@"Due State"];
        [dueStateMenu addItem:dueTodayItem];
        [dueStateMenu addItem:dueSoonItem];
        [dueStateMenu addItem:overdueItem];
        [dueStateMenu addItem:notDueItem];
        [dueStateMenu addItem:noDueDateItem];
        
        _dueStatePopUp = [[NSPopUpButton alloc] initWithFrame:NSZeroRect pullsDown:NO];
        [_dueStatePopUp setMenu:dueStateMenu];
    }
    return _dueStatePopUp;
}

//MARK: - NSPredicateEditorRowTemplate Method Overrides

- (NSArray<NSView *> *)templateViews {
    NSMutableArray<NSView *> *newTemplateViews = [[super templateViews] mutableCopy];
    [newTemplateViews replaceObjectAtIndex:0 withObject:self.keypathPopUp];
    [newTemplateViews replaceObjectAtIndex:2 withObject:self.dueStatePopUp];
    return newTemplateViews;
}

- (void)setPredicate:(NSPredicate *)predicate {
    id rightValue = [[(NSComparisonPredicate*)predicate rightExpression] constantValue];
    if ([rightValue isKindOfClass:[NSNumber class]]) {
        [self.dueStatePopUp selectItemWithTag:[rightValue integerValue]];
    }
}

- (NSPredicate*)predicateWithSubpredicates:(NSArray<NSPredicate *> *)subpredicates {
    NSPredicate *p = [super predicateWithSubpredicates:subpredicates];
    NSComparisonPredicate *comparison = (NSComparisonPredicate*)p;
    NSPredicate *newPredicate =
        [NSComparisonPredicate
         predicateWithLeftExpression:[[self.keypathPopUp selectedItem] representedObject]
         rightExpression:[[self.dueStatePopUp selectedItem] representedObject]
         modifier:[comparison comparisonPredicateModifier]
         type:[comparison predicateOperatorType]
         options:[comparison options]];
    return newPredicate;
}

@end
