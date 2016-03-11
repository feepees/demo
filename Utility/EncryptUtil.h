//
//  EncryptUtil.h
//  HZDuban
//
//  Created by mac  on 13-7-15.
//
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

// 加密key
#define ENCRYPT_KEY @"sunztech"

@interface EncryptUtil : NSObject
/**
 DES加密
 */
+(NSString *) encryptUseDES:(NSString *)clearText key:(NSString *)key;

/**
 DES解密
 */
+(NSString*) decryptUseDES:(NSString*)cipherText key:(NSString*)key;

@end
