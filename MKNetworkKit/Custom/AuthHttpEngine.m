//
//  AuthHttpEngine.m
//  MKNetworkKit-iOS-Demo
//
//  Created by Mugunth Kumar on 4/12/11.
//  Copyright (c) 2011 Steinlogic. All rights reserved.
//

#import "AuthHttpEngine.h"

@implementation AuthHttpEngine

-(void) basicAuthTest {
  
  MKNetworkOperation *op = [self operationWithPath:@"mknetworkkit/basic_auth.php"
                                            params:nil 
                                        httpMethod:@"GET"];
  
  [op setUsername:@"admin" password:@"password" basicAuth:YES];
  
  [op onCompletion:^(MKNetworkOperation *operation) {
    
    DLog(@"%@", [operation responseString]); 
  } onError:^(MKNetworkOperation* completedOperation, NSError *error) {
    
    DLog(@"%@", [error localizedDescription]);         
  }];
  [self enqueueOperation:op];
}


-(void) digestAuthTest {
  
  MKNetworkOperation *op = [self operationWithPath:@"mknetworkkit/digest_auth.php"
                                            params:nil 
                                        httpMethod:@"GET"];
  
  [op setUsername:@"admin" password:@"password"];
  
  [op onCompletion:^(MKNetworkOperation *operation) {
    
    DLog(@"%@", [operation responseString]); 
  } onError:^(MKNetworkOperation* completedOperation, NSError *error) {
    
    DLog(@"%@", [error localizedDescription]);         
  }];
  [self enqueueOperation:op];
}

-(void)digestAuthTestWithUser:(NSString*)username password:(NSString*)password {
  MKNetworkOperation *op = [self operationWithPath:@"mknetworkkit/digest_auth.php"
                                            params:nil 
                                        httpMethod:@"GET"];
  
  [op setUsername:username password:password];
  [op setCredentialPersistence:NSURLCredentialPersistenceNone];
  
  [op onCompletion:^(MKNetworkOperation *operation) {
    
    DLog(@"%@", [operation responseString]); 
  } onError:^(MKNetworkOperation* completedOperation, NSError *error) {
    
    DLog(@"%@", [error localizedDescription]);
  }];
  [self enqueueOperation:op];
}


-(void) clientCertTest {
  
  MKNetworkOperation *op = [self operationWithPath:@"mknetworkkit/client_auth.php"
                                            params:nil 
                                        httpMethod:@"GET" 
                                               ssl:YES];
  
  NSString *certPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"client.p12"];
  [op setClientCertificate:certPath];
  
  [op onCompletion:^(MKNetworkOperation *operation) {
    
    DLog(@"%@", [operation responseString]); 
  } onError:^(MKNetworkOperation* completedOperation, NSError *error) {
    
    DLog(@"%@", [error localizedDescription]);         
  }];
  [self enqueueOperation:op];
}

-(MKNetworkOperation*) uploadImageFromFile:(NSString*) file 
                            cellPath:(NSIndexPath*)Path
                              onCompletion:(UploadFinishBlock) completionBlock
                                   onError:(UploadErrorBlock) errorBlock {
//  http://172.16.206.146:8088/TestService/servlet/SaveServlet

//  MKNetworkOperation *op = [self operationWithPath:@"GoverDeciService/servlet/SaveServlet"
//                                              params:[NSDictionary dictionaryWithObjectsAndKeys:
//                                                      @"YES", @"Submit",
//                                                      nil]
//                                          httpMethod:@"POST"];
    MKNetworkOperation *op = [self operationWithPath:@"GoverDeciService/servlet/FileUploadServlet"
                                              params:[NSDictionary dictionaryWithObjectsAndKeys:
                                                      @"YES", @"Submit",
                                                      nil]
                                          httpMethod:@"POST"];
  // add by niurg 2013-07-13
  [op setUserIndexPath:Path];
  [op addFile:file forKey:@"image"];
  
  // setFreezable uploads your images after connection is restored!
  [op setFreezable:YES];
  
  [op onCompletion:^(MKNetworkOperation* completedOperation) {
    
    NSString *xmlString = [completedOperation responseString];
    
    DLog(@"%@", xmlString);
    completionBlock(xmlString, completedOperation);
  } onError:^(MKNetworkOperation* completedOperation, NSError* error) {
             
             errorBlock(error, completedOperation);
           }];
  
  [self enqueueOperation:op];
  
  
  return op;
}

-(MKNetworkOperation*) DownloadAnnexFile:(NSString*) AnnexDownloadUrl
                              onCompletion:(UploadFinishBlock) completionBlock
                                   onError:(UploadErrorBlock) errorBlock
{
    MKNetworkOperation *op = [self operationWithPath:AnnexDownloadUrl];
    [op onCompletion:^(MKNetworkOperation* completedOperation) {
        
        NSString *xmlString = [completedOperation responseString];
        
        DLog(@"%@", xmlString);
        completionBlock(xmlString, completedOperation);
    } onError:^(MKNetworkOperation* completedOperation, NSError* error) {
        
        errorBlock(error, completedOperation);
    }];
    
    [self enqueueOperation:op];
    return op;
}

-(int) cacheMemoryCost {
  return 0;
}

@end
