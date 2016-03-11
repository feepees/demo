//
//  BookMarkManager.h
//  HZDuban
//
//  Created by  on 12-7-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BookMarkManager : NSObject

// init bookmark data set
+(BOOL)InitBookMarksDataSet;
//+(BOOL)Release;

// 判断指定书签是否存在
+(BOOL)IsBookMarkExist:(NSString*)bookMark;

// add a bookmark
+(BOOL)AddBookMark:(NSString*)bookMark;
// get all bookmarks
+(NSMutableArray*)GetBookMarks;
// delete a book mark by index postion
+(BOOL)DelBookMarkByIndex:(int)nIndex;
// delete a book mark
+(BOOL)DelBookMarkByObj:(NSString*)bookMark;

// for test
+(BOOL)WriteBookMarks:(NSDictionary*)dicData;
@end
