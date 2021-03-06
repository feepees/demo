//
//  NSDateAdditions.h
//  Created by Devin Ross on 7/28/09.
//
/*
 
 tapku.com || http://github.com/devinross/tapkulibrary
 
 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 
 */
#import <Foundation/Foundation.h>


@interface NSDate (TKCategory)

struct TKDateInformation {
	int day;
	int month;
	int year;
	
	int weekday;
	
	int minute;
	int hour;
	int second;
	
};
typedef struct TKDateInformation TKDateInformation;

- (TKDateInformation) dateInformation;
- (TKDateInformation) dateInformationWithTimeZone:(NSTimeZone*)tz;
+ (NSDate*) dateFromDateInformation:(TKDateInformation)info;
+ (NSDate*) dateFromDateInformation:(TKDateInformation)info timeZone:(NSTimeZone*)tz;





@property (readonly,nonatomic) NSString *month;
@property (readonly,nonatomic) NSString *year;
@property (readonly,nonatomic) int weekdayWithMondayFirst;
@property (readonly,nonatomic) BOOL isToday;


- (BOOL) isSameDay:(NSDate*)anotherDate;
- (int) differenceInDaysTo:(NSDate *)toDate;
- (int) differenceInMonthsTo:(NSDate *)toDate;

- (int) daysBetweenDate:(NSDate*)d;

//add by zhang
//NSDate获取当前时区的时间
//[NSDate date]获取的是GMT时间，此方法获得某个时区的时间
+ (NSDate *)localeDate;
+ (NSString *)weekStringWithInformation:(TKDateInformation)info;

- (NSString*) dateDescription;
- (NSDate *) dateByAddingDays:(NSUInteger)days;
+ (NSDate *) dateWithDatePart:(NSDate *)aDate andTimePart:(NSDate *)aTime;

+ (NSString*) dateInformationDescriptionWithInformation:(TKDateInformation)info;

@end
