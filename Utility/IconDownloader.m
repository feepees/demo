/*
     File: IconDownloader.m 
 Abstract: Helper object for managing the downloading of a particular app's icon.
 As a delegate "NSURLConnectionDelegate" is downloads the app icon in the background if it does not
 yet exist and works in conjunction with the RootViewController to manage which apps need their icon.
 
 A simple BOOL tracks whether or not a download is already in progress to avoid redundant requests.
  
  Version: 1.2 
  
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple 
 Inc. ("Apple") in consideration of your agreement to the following 
 terms, and your use, installation, modification or redistribution of 
 this Apple software constitutes acceptance of these terms.  If you do 
 not agree with these terms, please do not use, install, modify or 
 redistribute this Apple software. 
  
 In consideration of your agreement to abide by the following terms, and 
 subject to these terms, Apple grants you a personal, non-exclusive 
 license, under Apple's copyrights in this original Apple software (the 
 "Apple Software"), to use, reproduce, modify and redistribute the Apple 
 Software, with or without modifications, in source and/or binary forms; 
 provided that if you redistribute the Apple Software in its entirety and 
 without modifications, you must retain this notice and the following 
 text and disclaimers in all such redistributions of the Apple Software. 
 Neither the name, trademarks, service marks or logos of Apple Inc. may 
 be used to endorse or promote products derived from the Apple Software 
 without specific prior written permission from Apple.  Except as 
 expressly stated in this notice, no other rights or licenses, express or 
 implied, are granted by Apple herein, including but not limited to any 
 patent rights that may be infringed by your derivative works or by other 
 works in which the Apple Software may be incorporated. 
  
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE 
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION 
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS 
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND 
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 
  
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL 
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, 
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED 
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), 
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE 
 POSSIBILITY OF SUCH DAMAGE. 
  
 Copyright (C) 2010 Apple Inc. All Rights Reserved. 
  
 */

#import "IconDownloader.h"
#import "TileImageRecord.h"

#define kAppIconHeight 512


@implementation IconDownloader

@synthesize TileImageRecordData;
//@synthesize indexPathInTableView;
@synthesize delegate;
@synthesize activeDownload;
@synthesize imageConnection;

#pragma mark

- (void)dealloc
{
    [TileImageRecordData release];
    //[indexPathInTableView release];
    
    [activeDownload release];
    
    [imageConnection cancel];
    [imageConnection release];
    
    [super dealloc];
}

- (void)startDownload
{
    self.activeDownload = [NSMutableData data];
    // alloc+init and start an NSURLConnection; release on completion/failure
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:
                             [NSURLRequest requestWithURL:
                              [NSURL URLWithString:TileImageRecordData.imageURLString]] delegate:self];
    
    NSLog(@"%@\n", TileImageRecordData.imageURLString);
    
    self.imageConnection = conn;
    [conn release];
}

- (void)cancelDownload
{
    [self.imageConnection cancel];
    self.imageConnection = nil;
    self.activeDownload = nil;
}


#pragma mark -
#pragma mark Download support (NSURLConnectionDelegate)

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if(httpResponse && [httpResponse respondsToSelector:@selector(allHeaderFields)])
    {
        NSDictionary *httpResponseHeaderFields = [httpResponse allHeaderFields];
        long long total_ = [[httpResponseHeaderFields objectForKey:@"Content-Length"] longLongValue];
        NSLog(@"%lld", total_);
    }
    
    return;
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.activeDownload appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	// Clear the activeDownload property to allow later attempts
    self.activeDownload = nil;
    
    // Release the connection now that it's finished
    self.imageConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // 检查文件存放目录
    NSString *pngDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    // 查找URL中最后一个/符号，截取这个符号后的图片文件名称。
    NSString *pngFullPathName = self.TileImageRecordData.imageURLString;
    NSString *pngImageName = [pngFullPathName lastPathComponent];
    // create [~/Documents/Tiles/row/column.png] similar directory
    NSString *pngDirectory = [NSString stringWithFormat:@"%@/Tiles/%d/%d", pngDir, TileImageRecordData.nLevel, TileImageRecordData.nRow];
    NSLog(@"%@", pngDirectory);
    
    BOOL IsDir = YES;
    BOOL bRet = [fileMgr fileExistsAtPath:pngDirectory isDirectory:&IsDir];
    if (!bRet) {
        NSError *err = nil;
        [fileMgr createDirectoryAtPath:pngDirectory withIntermediateDirectories:YES attributes:nil error:&err];
    }
    NSString *pngFileFullPath = [NSString stringWithFormat:@"%@/%@", pngDirectory, pngImageName];
    
    // Set appIcon and clear temporary data/image
    UIImage *image = [[UIImage alloc] initWithData:self.activeDownload];
    if (image.size.width != kAppIconHeight && image.size.height != kAppIconHeight)
	{
        CGSize itemSize = CGSizeMake(kAppIconHeight, kAppIconHeight);
		UIGraphicsBeginImageContext(itemSize);
		CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
		[image drawInRect:imageRect];
        
        UIImage *ImageData = UIGraphicsGetImageFromCurrentImageContext();
		self.TileImageRecordData.appIcon = UIGraphicsGetImageFromCurrentImageContext();
        BOOL bRet = [UIImagePNGRepresentation(ImageData) writeToFile:pngFileFullPath atomically:NO];
        bRet = bRet;
		UIGraphicsEndImageContext();
    }
    else
    {
        self.TileImageRecordData.appIcon = image;
        // write a uiimage to jpeg with minimum compression
        BOOL bRet = [UIImagePNGRepresentation(image) writeToFile:pngFileFullPath atomically:NO];
        bRet=bRet;
    }

    
//    self.activeDownload = nil;
    [image release];
    
    
    // Release the connection now that it's finished
    self.imageConnection = nil;
        
    // call our delegate and tell it that our icon is ready for display
    [delegate appImageDidLoad:TileImageRecordData.Reckey];
    self.activeDownload = nil;
}

@end

