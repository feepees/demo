//
//  DBMySegue.h
//  HZDuban2
//
//  Created by  on 12-7-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface DBMySegue : UIStoryboardSegue
{
    CATransition *lastAnimation;
    BOOL isHalfAnimation;
}
@property (nonatomic,retain) CATransition *lastAnimation;
@end
