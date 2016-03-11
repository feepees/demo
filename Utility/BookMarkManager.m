//
//  BookMarkManager.m
//  HZDuban
//
//  Created by  on 12-7-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BookMarkManager.h"

#define BOOKMARK_FILE_NAME   @"BookMarksJason.xml"
#define BOOKMARK_KEY    @"BookMarks"



@implementation BookMarkManager

static   NSMutableArray *_AllBookMarks;
static BOOL bInitFlg = FALSE;

#ifdef _FOR_DEBUG_  
-(BOOL) respondsToSelector:(SEL)aSelector {  
    printf("SELECTOR: %s  FileName: %s\n", [NSStringFromSelector(aSelector) UTF8String], __FILE__);
    return [super respondsToSelector:aSelector];  
}  
#endif

// get bookmarks file's full path 
+(NSString*)GetFileFullPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsDir = [paths objectAtIndex:0];
    NSString *jasonFilePath = [NSString stringWithFormat:@"%@/%@",documentsDir, BOOKMARK_FILE_NAME];
    return jasonFilePath;
}

// get all bookmarks
+(NSMutableArray*)GetBookMarks
{
    if(bInitFlg)
    {
        return _AllBookMarks;
    }
    else {
        return nil;
    }
}
// init bookmark data set
+(BOOL)InitBookMarksDataSet
{
    BOOL bRet = FALSE;
    @try 
    {
        @synchronized(self) 
        {
            NSString *strPath = [self GetFileFullPath];
            NSFileManager *fileMgr = [NSFileManager defaultManager];
            BOOL bRet = [fileMgr fileExistsAtPath:strPath];
            if (!bRet) 
            {
                // 文件不存在的场合
                _AllBookMarks = [[NSMutableArray alloc] initWithCapacity:1];
                [_AllBookMarks addObject:@"惠州"];
                [_AllBookMarks addObject:@"医院"];
                [_AllBookMarks addObject:@"酒店"];
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                [dict setValue:_AllBookMarks forKey:@"BookMarks"];
                bRet = [dict writeToFile:strPath atomically:YES];
            }
            else {
                NSDictionary *bookMarkDic = [NSDictionary dictionaryWithContentsOfFile:strPath];
                NSArray *dicData = [bookMarkDic valueForKey:BOOKMARK_KEY];
                _AllBookMarks = [[NSMutableArray alloc] initWithArray:dicData];
            }

            bInitFlg = TRUE;
            bRet = TRUE;
        }
    }
    @catch (NSException *exception) 
    {
        bRet = FALSE;
    }
    @finally {
        return bRet;
    }
    
}

//// save and release source
//+(BOOL)Release
//{
//    BOOL bRet = FALSE;
//    if(!bInitFlg)
//    {
//        return bRet;
//    }
//    @try 
//    {
//        @synchronized(self) 
//        {
//            [_AllBookMarks release];
//            _AllBookMarks = nil;
//            
//            NSString *strPath = [self GetFileFullPath];
//            NSDictionary *dicData = [[NSDictionary alloc] init];
//            [dicData setValue:_AllBookMarks forKey:BOOKMARK_KEY];
//            bRet = [dicData writeToFile:strPath atomically:YES];
//            
//            dicData = nil;
//            return bRet;
//        }
//    }
//    @catch (NSException *exception) 
//    {
//        bRet = FALSE;
//    }
//    @finally {
//        return bRet;
//    }
//}

// 判断指定书签是否存在
+(BOOL)IsBookMarkExist:(NSString*)bookMark
{
    BOOL bRet = FALSE;
    if(!bInitFlg)
    {
        return bRet;
    }
    @try 
    {
        @synchronized(self) 
        {
            bRet = [_AllBookMarks containsObject:bookMark];
        }
    }
    @catch (NSException *exception) 
    {
        bRet = FALSE;
    }
    @finally {
        return bRet;
    }
}
// add a bookmark
+(BOOL)AddBookMark:(NSString*)bookMark
{
    BOOL bRet = FALSE;
    if(!bInitFlg)
    {
        return bRet;
    }
    @try 
    {
        @synchronized(self) 
        {
            [_AllBookMarks addObject:bookMark];
            [self SaveBookMark];
            bRet = TRUE;
        }
    }
    @catch (NSException *exception) 
    {
        bRet = FALSE;
    }
    @finally {
        return bRet;
    }
}

// delete a book mark by index postion
+(BOOL)DelBookMarkByIndex:(int)nIndex
{
    BOOL bRet = FALSE;
    if(!bInitFlg)
    {
        return bRet;
    }
    @try 
    {
        @synchronized(self) 
        {
            [_AllBookMarks removeObjectAtIndex:nIndex];
            [self SaveBookMark];
            bRet = TRUE;
        }
    }
    @catch (NSException *exception) 
    {
        bRet = FALSE;
    }
    @finally {
        return bRet;
    }
}
// delete a book mark by object
+(BOOL)DelBookMarkByObj:(NSString*)bookMark
{
    BOOL bRet = FALSE;
    if(!bInitFlg)
    {
        return bRet;
    }
    @try 
    {
        @synchronized(self) 
        {
            [_AllBookMarks removeObject:bookMark];
            [self SaveBookMark];
            bRet = TRUE;
        }
    }
    @catch (NSException *exception) 
    {
        bRet = FALSE;
    }
    @finally {
        return bRet;
    }
}

// save
+(BOOL)SaveBookMark
{
    BOOL bRet = FALSE;
    if(!bInitFlg)
    {
        return bRet;
    }
    @try 
    {
        @synchronized(self) 
        {
            NSString *strPath = [self GetFileFullPath];
            NSMutableDictionary *dicData = [[NSMutableDictionary alloc] init];
            [dicData setValue:_AllBookMarks forKey:BOOKMARK_KEY];
            bRet = [dicData writeToFile:strPath atomically:YES];
            
            dicData = nil;
            return bRet;
        }
    }
    @catch (NSException *exception) 
    {
        bRet = FALSE;
    }
    @finally {
        return bRet;
    }
}

////////////////
+(BOOL)WriteBookMarks:(NSDictionary*)dicData
{
    BOOL bRet = FALSE;
    @try 
    {
        @synchronized(self) 
        {
            NSString *strPath = [self GetFileFullPath];
            bRet = [dicData writeToFile:strPath atomically:YES];
            return bRet;
        }
    }
    @catch (NSException *exception) 
    {
        bRet = FALSE;
    }
    @finally {
        return bRet;
    }
}

@end
