//
//  Logger.m
//  BaZhouTour
//
//  Created by sunz on 11-10-20.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "Logger.h"
#include <sys/time.h>

#define LOG_FILE_NAME   @"AppRunLog.log"

static int nCount = 0;
static FILE * logFileHandle = NULL;

@implementation Logger

#ifdef _FOR_DEBUG_  
-(BOOL) respondsToSelector:(SEL)aSelector {  
    printf("SELECTOR: %s  FileName: %s\n", [NSStringFromSelector(aSelector) UTF8String], __FILE__);
    return [super respondsToSelector:aSelector];  
}  
#endif

-(id)init
{
    self = [super init];
    if(self)
    {
    }
    
    return self;
}

-(oneway void)release
{
    return;
}


+(void)OutputTimeLog
{
    static NSUInteger nCnt = 0;
    nCnt++;
    struct timeval now; 
    gettimeofday(&now,NULL); 
    //NSLog(@"\n%d -----------\n秒:%ld  微妙:%d", nCnt, now.tv_sec, now.tv_usec);
    fflush(stdout);
    fflush(stderr);
    return;
}

// 初始化LOG文件
+(BOOL)InitLogger
{
    @try {
        @synchronized(self) 
        {
            // create file
            if(nCount == 0)
            {
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString * documentsDir = [paths objectAtIndex:0];
                NSString *logFilePath = [NSString stringWithFormat:@"%@/%@",documentsDir, LOG_FILE_NAME];
                const char * cLogFilePath = [logFilePath cStringUsingEncoding:NSASCIIStringEncoding];
                
//                NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/applog.log"];
//                
//                const char *filePath = [documentsDirectory cStringUsingEncoding:NSASCIIStringEncoding];
//                
                if(logFileHandle)
                {
                    fclose(logFileHandle);
                    logFileHandle = NULL;
                }
                logFileHandle = fopen(cLogFilePath, "w+");
                
            }
            nCount++;
        }
    }
    @catch (NSException *exception) {
        return NO;
    }
    @finally {
        
    }
    
    return YES;
}

// 释放LOG文件资源
+(BOOL)ReleaseLogger
{
    @try {
        @synchronized(self) 
        {
            nCount--;
            if(nCount == 0)
            {
                if(logFileHandle)
                {
                    fclose(logFileHandle);
                    logFileHandle = NULL;
                }
            }
        }
    }
    @catch (NSException *exception) {
        return NO;
    }
    @finally {
    
    }
    return YES;
}

// 写log日志
+(BOOL)WriteLog:(NSString*)strFileName funcName:(NSString*)strFuncName lineNum:(int)nlineNum exceptionName:(NSException*)exception
{
    @try {
        @synchronized(self) 
        {
            const char * fileName = [strFileName cStringUsingEncoding:NSASCIIStringEncoding];
            const char * funcName = [strFuncName cStringUsingEncoding:NSASCIIStringEncoding];
            
            NSString * strException = [NSString stringWithFormat:@"%@", exception];
            const char * cException = [strException cStringUsingEncoding:NSASCIIStringEncoding];
            
            fprintf(logFileHandle, "==================\n");
            fprintf(logFileHandle,  "文件名：%s, 函数名：%s,行号：%d, \n异常详细信息：%s\n", fileName, funcName, nlineNum, cException);
            fprintf(logFileHandle, "==================\n\n");
        }
    }
    @catch (NSException *exception) {
        return NO;
    }
    @finally {
        fflush(logFileHandle);
    }

    return YES;
}

+(void)WriteXMLFile:(NSString*)str
{
    const char * str1 = [str cStringUsingEncoding:NSUTF8StringEncoding];
    fprintf(logFileHandle, "XXXXXXXXXXXXXXX\n\n");
    fprintf(logFileHandle, "%s", str1);
    fprintf(logFileHandle, "@@@@@@@@@@@@@@@n\n");
    return;
}
// 写log日志  
// 错误日志的场合， cTextInf为null.
// 普通日志的场合， exception为null.
+(BOOL)WriteLog:(const char*)fileName funcName:(const char*)funcName lineNum:(int)nlineNum exceptionObj:(NSException*)exception textInf:(const char *)cTextInf
{
    @try {
        NSString *nsFileName = [NSString stringWithCString:fileName encoding:NSASCIIStringEncoding];
        NSString *lineNum = [NSString stringWithFormat:@"%d", nlineNum];
        NSLog(@"---\n FileName:%@ \n---LineNum:%@", nsFileName, lineNum);
        @synchronized(self) 
        {
            //NSString *nsFileName = [NSString stringWithCString:fileName encoding:NSASCIIStringEncoding];
            //const char * cFileName = [nsFileName cStringUsingEncoding:NSASCIIStringEncoding];
            fprintf(logFileHandle, "==================\n");
            if(exception)
            {
                // 错误日志
                //NSLog(@"%@",exception);
                NSString * strException = [NSString stringWithFormat:@"%@", exception];
                const char * cException = [strException cStringUsingEncoding:NSASCIIStringEncoding];
                fprintf(logFileHandle, "error log\n");
                fprintf(logFileHandle, "File Name:\n%s.\n\nFunction name:\n  %s.\n\nLine number:\n  %d.\n\nException detail information:\n  %s\n\n", fileName, funcName, nlineNum, cException);
            }
            else{
                // 普通日志
                //return YES;
                fprintf(logFileHandle, "information log\n");
                fprintf(logFileHandle, "File Name:\n%s.\n\nFunction name:\n  %s.\n\nLine number:\n  %d.\n\ninformation:\n  %s\n", fileName, funcName, nlineNum, cTextInf);
            }

            fprintf(logFileHandle, "==================\n\n");
        }
    }
    @catch (NSException *exception) {
        return NO;
    }
    @finally {
        fflush(logFileHandle);
    }
    
    return YES;
}



@end
