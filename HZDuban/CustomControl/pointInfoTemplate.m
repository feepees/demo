//
//  pointInfoTemplate.m
//  Earthquake2
//
//  Created by esri on 10-6-21.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "pointInfoTemplate.h"


@implementation pointInfoTemplate

@synthesize title = _title;
@synthesize detail = _detail;

#ifdef _FOR_DEBUG_  
-(BOOL) respondsToSelector:(SEL)aSelector {  
    printf("SELECTOR: %s  FileName: %s\n", [NSStringFromSelector(aSelector) UTF8String], __FILE__);
    return [super respondsToSelector:aSelector];  
}  
#endif

// text for the graphic will be the name attribute of the feature
- (NSString *)textForGraphic:(AGSGraphic *)graphic screenPoint:(CGPoint)screen mapPoint:(AGSPoint *)map {
	NSString * str = @"新添加的点";

	return str;
}

//details for the callout
- (NSString *)detailForGraphic:(AGSGraphic *)graphic screenPoint:(CGPoint)screen mapPoint:(AGSPoint *)map 
{
//    NSString *key = @"TYPENAME";
//    NSString *typeName = [[graphic attributes] valueForKey:key];
    return _detail;
}

- (UIImage *)imageForGraphic:(AGSGraphic *) graphic screenPoint:(CGPoint) screen mapPoint:(AGSPoint *) mapPoint
{
    UIImage *LeftImage = [UIImage imageNamed:@"PriceTopBtn.png"];
    return LeftImage;
}

- (NSString *)titleForGraphic:(AGSGraphic *) graphic screenPoint:(CGPoint) screen mapPoint:(AGSPoint *) map
{
//    NSString *key = @"NAME";
//    NSString *name = [[graphic attributes] valueForKey:key];
    return _title;
}
@end
