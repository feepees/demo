//
//  Logger.h
//  BaZhouTour
//
//  Created by sunz on 11-10-20.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Logger : NSObject {
    
@private
    //NSString * LogFileName;
}

// 初始化LOG文件
+(BOOL)InitLogger;
// 释放LOG文件资源
+(BOOL)ReleaseLogger;

// 写log日志
+(BOOL)WriteLog:(NSString*)strFileName funcName:(NSString*)strFuncName lineNum:(int)nlineNum exceptionName:(NSException*)exception;

//// 写log日志
//+(BOOL)WriteLog:(const char*)fileName funcName:(const char*)funcName lineNum:(int)nlineNum exceptionObj:(NSException*)exception;
// 写log日志  
// 错误日志的场合， cTextInf为null.
// 普通日志的场合， exception为null.
+(BOOL)WriteLog:(const char*)fileName funcName:(const char*)funcName lineNum:(int)nlineNum exceptionObj:(NSException*)exception textInf:(const char *)cTextInf;

+(void)OutputTimeLog;

+(void)WriteXMLFile:(NSString*)str;
@end
