//
//  DBLineChartViewViewController.h
//  HZDuban
//
//  Created by sunz on 13-1-6.
//
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@interface DBLineChartViewController : UIViewController<CPTPlotDataSource>
{
    CPTXYGraph *graph;
}
@property(readwrite, retain, nonatomic) NSMutableArray *dataForPlot;
@property(readwrite, retain, nonatomic) NSMutableArray *dataForPlot2;

- (void)BackBtnClick:(id)sender;


@end
