//
//  DBBarChartViewController.h
//  HZDuban
//
//  Created by sunz on 13-1-6.
//
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@interface DBBarChartViewController : UIViewController<CPTPlotDataSource>
{
@private
	CPTXYGraph *barChart;
	NSTimer *timer;
    IBOutlet UIScrollView *MyScrollView;
    IBOutlet CPTGraphHostingView *MyChartView;
    NSMutableArray *dataArr;
    int nChartIndex;
    int nSubChartIndex;
}
@property(readwrite, retain, nonatomic) NSTimer *timer;
@property(readwrite, retain, nonatomic) NSMutableArray *dataArr;

-(void)timerFired;

- (IBAction)test:(id)sender;
- (IBAction)BackBtnClick:(id)sender;


@end
