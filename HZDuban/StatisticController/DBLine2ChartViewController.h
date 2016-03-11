//
//  DBLine2ChartViewController.h
//  HZDuban
//
//  Created by sunz on 13-1-6.
//
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@interface DBLine2ChartViewController : UIViewController<CPTPlotDataSource>
{
    CPTXYGraph *graph;
    NSMutableArray *plotData;
    
}


@end
