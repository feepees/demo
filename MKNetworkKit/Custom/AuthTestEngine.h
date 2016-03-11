//
//  AuthTestEngine.h
//  MKNetworkKit-iOS-Demo
//
//  Created by Mugunth Kumar on 4/12/11.
//  Copyright (c) 2011 Steinlogic. All rights reserved.
//
#import "MKNetworkKit.h"
#import "MKNetworkOperation.h"
typedef void (^UploadFinishBlock)(NSString *RetMsg);

@interface AuthTestEngine : MKNetworkEngine

-(void) basicAuthTest;
-(void) digestAuthTest;
-(void)digestAuthTestWithUser:(NSString*)username password:(NSString*)password;
-(void) clientCertTest;
-(int) cacheMemoryCost;

-(MKNetworkOperation*)uploadImageFromFile:(NSString*)file onCompletion:(UploadFinishBlock)completionBlock onError:(MKNKErrorBlock) errorBlock;
@end
