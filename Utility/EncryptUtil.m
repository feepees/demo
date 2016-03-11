//
//  EncryptUtil.m
//  HZDuban
//
//  Created by mac  on 13-7-15.
//
//

#import "EncryptUtil.h"
#import "GTMBase64.h"

@implementation EncryptUtil
/*
 DES加密
 */
+(NSString*) decryptUseDES:(NSString*)cipherText key:(NSString*)key {
    // 利用 GTMBase64 解碼 Base64 字串
    NSData* cipherData = [GTMBase64 decodeString:cipherText];
    unsigned char buffer[102400];
    memset(buffer, 0, sizeof(char));
    size_t numBytesDecrypted = 0;
    
    void * VI = (void*)malloc(20);
    memset(VI, 0x00, 20);
    memcpy(VI, "encrypiv", 8);
    // IV 偏移量不需使用
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmDES,
                                           kCCOptionPKCS7Padding,
                                          [key UTF8String],
                                          kCCKeySizeDES,
                                          VI,
                                          [cipherData bytes],
                                          [cipherData length],
                                          buffer,
                                          102400,
                                          &numBytesDecrypted);
    NSString* plainText = nil;
    if (cryptStatus == kCCSuccess) {
        NSData* data = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesDecrypted];
        plainText = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    }
    free(VI);
    return plainText;
}
/**
 DES 解密
 */
+(NSString *) encryptUseDES:(NSString *)clearText key:(NSString *)key
{
    NSData *data = [clearText dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    unsigned char buffer[102400];
    memset(buffer, 0, sizeof(char));
    size_t numBytesEncrypted = 0;
    void * VI = (void*)malloc(20);
    memset(VI, 0x00, 20);
    memcpy(VI, "encrypiv", 8);
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding,
                                          [key UTF8String],
                                          kCCKeySizeDES,
                                          VI,
                                          [data bytes],
                                          [data length],
                                          buffer,
                                          102400,
                                          &numBytesEncrypted);
    
    NSString* plainText = nil;
    if (cryptStatus == kCCSuccess) {
        NSData *dataTemp = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesEncrypted];
        plainText = [GTMBase64 stringByEncodingData:dataTemp];
    }else{
        NSLog(@"DES加密失败");
    }
    free(VI);
    return plainText;
}
@end
