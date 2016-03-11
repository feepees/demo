//
//  DBLine2ChartViewController.m
//  HZDuban
//
//  Created by sunz on 13-1-6.
//
//

#import "DBLine2ChartViewController.h"

@interface DBLine2ChartViewController ()

@end

@implementation DBLine2ChartViewController

#pragma mark - ViewLifeCycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIButton *prePageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [prePageBtn addTarget:self action:@selector(BackBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [prePageBtn setBackgroundImage:[UIImage imageNamed:@"DBBackBtn.png"] forState:UIControlStateNormal];
    [prePageBtn setFrame:CGRectMake(5, 6, 32, 32)];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:prePageBtn] autorelease];
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.243 green:0.18 blue:0.063 alpha:0];
    ////////////
    // for daylight savings time.
    NSDate *refDate = [NSDate dateWithNaturalLanguageString:@"00:00 Oct 29, 2009"];
    //NSTimeInterval oneDay = 24 * 60 * 60;
    NSTimeInterval oneDay = 100;
    
    // Create graph from theme
    graph = [(CPTXYGraph *)[CPTXYGraph alloc] initWithFrame:CGRectZero];
	CPTTheme *theme = [CPTTheme themeNamed:kCPTDarkGradientTheme];
	[graph applyTheme:theme];
	//hostView.hostedGraph = graph;
    CPTGraphHostingView *hostingView = (CPTGraphHostingView *)self.view;
    hostingView.collapsesLayers = NO; // Setting to YES reduces GPU memory usage, but can slow drawing/scrolling
    hostingView.hostedGraph = graph;
    
    // Setup scatter plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    NSTimeInterval xLow = -20.0f;
    // plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xLow) length:CPTDecimalFromFloat(oneDay*3.0f)];
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xLow) length:CPTDecimalFromFloat(oneDay)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-1.0) length:CPTDecimalFromFloat(5.0)];
    plotSpace.allowsUserInteraction = YES;
    // Axes
	CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *x = axisSet.xAxis;
    //    x.majorIntervalLength = CPTDecimalFromFloat(oneDay);
    //    x.orthogonalCoordinateDecimal = CPTDecimalFromString(@"0");     // 原点的y坐标值
    //    x.minorTicksPerInterval = 3;
	x.orthogonalCoordinateDecimal = CPTDecimalFromString(@"0");     // 原点的y坐标值
    //////////
    
    //x.minorTicksPerInterval = 3;
    
    CPTMutableLineStyle *majorLineStyle = [CPTMutableLineStyle lineStyle];
    majorLineStyle.lineCap = kCGLineCapRound;
    majorLineStyle.lineColor = [CPTColor whiteColor];
    majorLineStyle.lineWidth = 3.0;
    //x.axisLineStyle = majorLineStyle;
    
    CPTMutableLineStyle *minorLineStyle = [CPTMutableLineStyle lineStyle];
    minorLineStyle.lineColor = [CPTColor whiteColor];
    minorLineStyle.lineWidth = 2.0;
    
    x.majorIntervalLength = CPTDecimalFromString(@"20");
    x.labelRotation = M_PI/4;
	x.labelingPolicy = CPTAxisLabelingPolicyNone;
    x.majorTickLineStyle = majorLineStyle;
    x.majorTickLength = 5.0f;
    x.minorTickLineStyle = nil;//minorLineStyle;
    
    NSArray *customTickLocations = [NSArray arrayWithObjects:[NSDecimalNumber numberWithFloat:0], [NSDecimalNumber numberWithFloat:20], [NSDecimalNumber numberWithFloat:40], [NSDecimalNumber numberWithFloat:60], nil];
    
    NSArray *xAxisLabels = [NSArray arrayWithObjects:@"大亚湾区", @"惠城区", @"惠阳区", @"龙门区", nil];
	NSUInteger labelLocation = 0;
	NSMutableArray *customLabels = [NSMutableArray arrayWithCapacity:[xAxisLabels count]];
    
	for (NSNumber *tickLocation in customTickLocations)
    {
		CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithText: [xAxisLabels objectAtIndex:labelLocation++] textStyle:x.labelTextStyle];
		newLabel.tickLocation = [tickLocation decimalValue];
        // 设置“2008”，“2009”等文字的上下偏移位置
		newLabel.offset = x.labelOffset + x.majorTickLength - 8;
        // 设置“2008”，“2009”等文字的反转角度
		newLabel.rotation = M_PI/4;
		[customLabels addObject:newLabel];
		[newLabel release];
	}
	
	x.axisLabels =  [NSSet setWithArray:customLabels];
	
    CPTXYAxis *y = axisSet.yAxis;
    y.majorIntervalLength = CPTDecimalFromString(@"1");         //
    y.minorTicksPerInterval = 5;
    y.orthogonalCoordinateDecimal = CPTDecimalFromFloat(0.0);       // 原点的X轴坐标
    
    NSMutableArray *barPlotArr = [[NSMutableArray alloc] initWithCapacity:5];
    // Create a plot that uses the data source method
	CPTScatterPlot *dataSourceLinePlot = [[[CPTScatterPlot alloc] init] autorelease];
    dataSourceLinePlot.identifier = @"违法案件数";
	CPTMutableLineStyle *lineStyle = [[dataSourceLinePlot.dataLineStyle mutableCopy] autorelease];
	lineStyle.lineWidth = 3.f;
    lineStyle.lineColor = [CPTColor greenColor];
    dataSourceLinePlot.dataLineStyle = lineStyle;
    
    dataSourceLinePlot.dataSource = self;
    [barPlotArr addObject:dataSourceLinePlot];
    [graph addPlot:dataSourceLinePlot];
    
    // Add some data
	//NSMutableArray *newData = [NSMutableArray array];
    plotData = [[NSMutableArray alloc] initWithCapacity:5];
	NSUInteger i;
	for ( i = 0; i < 4; i++ ) {
		//NSTimeInterval x = oneDay*i*0.5f;
        NSTimeInterval x = i* 20;
        
		id y = [NSDecimalNumber numberWithFloat:1.2*rand()/(float)RAND_MAX + 1.2];
        
		[plotData addObject:
         [NSDictionary dictionaryWithObjectsAndKeys:
          [NSDecimalNumber numberWithFloat:x], [NSNumber numberWithInt:CPTScatterPlotFieldX],
          y, [NSNumber numberWithInt:CPTScatterPlotFieldY],
          nil]];
	}
	//plotData = newData;
    // 添加图例说明
    CPTLegend *LegendData = [CPTLegend legendWithPlots:barPlotArr];
    [barPlotArr release];
    barPlotArr = nil;
    CPTMutableTextStyle *LegendDataTextStyle = [CPTTextStyle textStyle];
    LegendDataTextStyle.color = [CPTColor greenColor];
    LegendData.textStyle = LegendDataTextStyle;
    LegendData.titleOffset = 2;
    // 设置每行的显示个数
    LegendData.numberOfRows = 2;
    // 设置说明文字
    //[graph setLegend:LegendData];
    // 设置说明的位置
    [graph setLegendAnchor:CPTRectAnchorTopRight];
    CGPoint pt = CGPointMake(-25,-36);
    // 设置位置的偏移
    [graph setLegendDisplacement:pt];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if((UIInterfaceOrientationLandscapeLeft == interfaceOrientation) || (UIInterfaceOrientationLandscapeRight == interfaceOrientation))
    {
        return YES;
    }
    return NO;
}

-(void)dealloc
{
	[plotData release];
    [graph release];
    [super dealloc];
}

#pragma mark - UIButton Responsder
- (void)BackBtnClick:(id)sender
{
//    [self dismissModalViewControllerAnimated:NO];
    [self dismissViewControllerAnimated:NO completion:NULL];
}
#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    NSUInteger nCnt = plotData.count;
    return nCnt;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSDecimalNumber *num = [[plotData objectAtIndex:index] objectForKey:[NSNumber numberWithInt:fieldEnum]];
    return num;
}



@end
