//
//  pointInfoTemplate.h
//  Earthquake2
//
//  Created by esri on 10-6-21.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>

@interface pointInfoTemplate : NSObject<AGSInfoTemplateDelegate>{

}
/** Template used to display the title in the callout.
 @since 1.0
 */
@property (nonatomic, copy) NSString *title;

/** Template used to display the detail string in the callout.
 @since 1.0
 */
@property (nonatomic, copy) NSString *detail;
@end
