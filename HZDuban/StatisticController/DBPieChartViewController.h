//
//  DBPieChartViewController.h
//  HZDuban
//
//  Created by sunz on 13-1-6.
//
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@interface DBPieChartViewController : UIViewController<CPTPlotDataSource>
{
@private
	CPTXYGraph *pieChart;
	NSMutableArray *dataForChart;
    NSMutableArray *sectionTitles;
	NSTimer *timer;
    IBOutlet UIScrollView *MyScrollView;
    IBOutlet CPTGraphHostingView *MyPieView;
    
    //BOOL piePlotIsRotating;
}

@property(readwrite, retain, nonatomic) NSMutableArray *dataForChart;
@property(readwrite, retain, nonatomic) NSMutableArray *sectionTitles;
@property(readwrite, retain, nonatomic) NSTimer *timer;

-(void)timerFired;
- (void)BackBtnClick:(id)sender;


@end
