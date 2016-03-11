//
//  DBPieChartViewController.m
//  HZDuban
//
//  Created by sunz on 13-1-6.
//
//

#import "DBPieChartViewController.h"

@interface DBPieChartViewController ()

@end

@implementation DBPieChartViewController

@synthesize dataForChart, sectionTitles;
@synthesize timer;

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
    
    sectionTitles = [[NSMutableArray alloc] initWithObjects:@"非法占地", @"破坏耕地", @"非法批地", nil];
    
    self.dataForChart = [NSMutableArray arrayWithObjects:[NSNumber numberWithDouble:10.0], [NSNumber numberWithDouble:30.0], [NSNumber numberWithDouble:60.0], nil];
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.243 green:0.18 blue:0.063 alpha:0];//[UIColor brownColor]; //[UIColor colorWithRed:0.47 green:0.41 blue:0.29 alpha:1];
    ////////////////
    
    [self timerFired];
#ifdef MEMORY_TEST
	self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self
												selector:@selector(timerFired) userInfo:nil repeats:YES];
#endif
    
    int nCnt = self.dataForChart.count;
    if(nCnt > 0)
    {
        int index = 0;
        NSString *selSectionTitle = [sectionTitles objectAtIndex:index];
        double dRat = [[dataForChart objectAtIndex:index] doubleValue];
        pieChart.title = [NSString stringWithFormat:@"%@所占比例为%0.0f%%", selSectionTitle, dRat];
    }
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

- (void)dealloc {
    [sectionTitles release];
    [dataForChart release];
	[timer release];
//    [MyScrollView release];
//    [MyPieView release];
    [super dealloc];
}
- (void)viewDidUnload {
//    sectionTitles = nil;
    [sectionTitles release];
    [dataForChart release];
	[timer release];
    
//    [MyScrollView release];
//    MyScrollView = nil;
//    [MyPieView release];
//    MyPieView = nil;
    [super viewDidUnload];
}

////////////
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    return;
    
	CGFloat margin = pieChart.plotAreaFrame.borderLineStyle.lineWidth + 5.0;
	
	CPTPlot *piePlot = [pieChart plotWithIdentifier:@"Pie Chart 1"];
	CGRect plotBounds = pieChart.plotAreaFrame.bounds;
	CGFloat newRadius = MIN(plotBounds.size.width, plotBounds.size.height) / 2.0 - margin;
	((CPTPieChart *)piePlot).pieRadius = newRadius;
	
	CGFloat y = 0.0;
	
	if ( plotBounds.size.width > plotBounds.size.height ) {
		y = 0.5;
	}
	else {
		y = (newRadius + margin) / plotBounds.size.height;
	}
	((CPTPieChart *)piePlot).centerAnchor = CGPointMake(0.5, y);
}

-(void)timerFired
{
#ifdef MEMORY_TEST
	static NSUInteger counter = 0;
	
	NSLog(@"\n----------------------------\ntimerFired: %lu", counter++);
#endif
	
	[pieChart release];
	
    // Create pieChart from theme
    pieChart = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
	CPTTheme *theme = [CPTTheme themeNamed:kCPTDarkGradientTheme]; //kCPTSlateTheme];//kCPTStocksTheme];//kCPTDarkGradientTheme];
    [pieChart applyTheme:theme];
	CPTGraphHostingView *hostingView = MyPieView; //(CPTGraphHostingView *)self.MyPieView;
    hostingView.hostedGraph = pieChart;
	
    pieChart.paddingLeft = 20.0;
	pieChart.paddingTop = 70.0;
	pieChart.paddingRight = 20.0;
	pieChart.paddingBottom = 20.0;

    //
	pieChart.axisSet = nil;
    
    // Prepare a radial overlay gradient for shading/gloss
    CPTGradient *overlayGradient = [[[CPTGradient alloc] init] autorelease];
    overlayGradient.gradientType = CPTGradientTypeRadial;
	overlayGradient = [overlayGradient addColorStop:[[CPTColor blackColor] colorWithAlphaComponent:0.0] atPosition:0.0];
    overlayGradient = [overlayGradient addColorStop:[[CPTColor blackColor] colorWithAlphaComponent:0.3] atPosition:0.9];
	overlayGradient = [overlayGradient addColorStop:[[CPTColor blackColor] colorWithAlphaComponent:0.7] atPosition:1.0];
	
    // niurg modifyed
	//ieChart.titleTextStyle.color = [CPTColor whiteColor];
	pieChart.title = @"";
    pieChart.titleDisplacement = CGPointMake(0, -50);
    //pieChart.titleTextStyle ;=
    //CPTTextStyle * textStyle = [CPTTextStyle textStyle]
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.color = [CPTColor brownColor];
    textStyle.fontSize = 28.0f;
	textStyle.textAlignment = CPTTextAlignmentCenter;
    pieChart.titleTextStyle = textStyle;
	
    // Add pie chart
    NSMutableArray *barPlotArr = [[NSMutableArray alloc] initWithCapacity:5];
    CPTPieChart *piePlot = [[CPTPieChart alloc] init];
    piePlot.dataSource = self;
	piePlot.pieRadius = 230.0;
    piePlot.identifier = @"非法占地";
	piePlot.startAngle = M_PI_4;
	piePlot.sliceDirection = CPTPieDirectionCounterClockwise;
	piePlot.centerAnchor = CGPointMake(0.5, 0.5);
	piePlot.borderLineStyle = [CPTLineStyle lineStyle];
    piePlot.overlayFill = [CPTFill fillWithGradient:overlayGradient];
	piePlot.delegate = self;
    ///
    piePlot.opacity = 0.0f;
    CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
	fadeInAnimation.duration = 1.0f;
	fadeInAnimation.removedOnCompletion = NO;
	fadeInAnimation.fillMode = kCAFillModeForwards;
	fadeInAnimation.toValue = [NSNumber numberWithFloat:1.0];
	[piePlot addAnimation:fadeInAnimation forKey:@"animateOpacity"];
    ///
    
    [barPlotArr addObject:piePlot];
    [pieChart addPlot:piePlot];
    [piePlot release];
	
    
    // 添加图例说明
    CPTLegend *LegendData = [CPTLegend legendWithPlots:barPlotArr];
    [barPlotArr release];
    barPlotArr = nil;
    CPTMutableTextStyle *LegendDataTextStyle = [CPTTextStyle textStyle];
    LegendDataTextStyle.color = [CPTColor redColor];
    LegendData.textStyle = LegendDataTextStyle;
    LegendData.titleOffset = 2;
    // 设置每行的显示个数
    LegendData.numberOfRows = 2;
    // 设置说明文字
    //[pieChart setLegend:LegendData];
    // 设置说明的位置
    [pieChart setLegendAnchor:CPTRectAnchorTopRight];
    CGPoint pt = CGPointMake(-25,-70);
    // 设置位置的偏移
    [pieChart setLegendDisplacement:pt];
#ifdef PERFORMANCE_TEST
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(changePlotRange) userInfo:nil repeats:YES];
#endif
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
    return [self.dataForChart count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
	if ( index >= [self.dataForChart count] )
    {
        return nil;
    }
	
	if ( fieldEnum == CPTPieChartFieldSliceWidth )
    {
		return [self.dataForChart objectAtIndex:index];
	}
	else {
		return [NSNumber numberWithInt:index];
	}
}

-(CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index
{
	//CPTTextLayer *label = [[CPTTextLayer alloc] initWithText:[NSString stringWithFormat:@"%lu", index]];
    NSString *strTitle = [sectionTitles objectAtIndex:index];
    CPTTextLayer *label = [[CPTTextLayer alloc] initWithText:strTitle];
    
    CPTMutableTextStyle *textStyle = [label.textStyle mutableCopy];
	textStyle.color = [CPTColor whiteColor];
    textStyle.fontSize = 18;
    label.textStyle = textStyle;
    [textStyle release];
	return [label autorelease];
}

-(CGFloat)radialOffsetForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)index
{
    CGFloat fVal = 0.0f;
    
    return fVal;
    if(index == 0)
    {
        fVal = 10.0f;
    }
    else if(index == 1)
    {
        fVal = 10.0f;
    }else if(index == 2)
    {
        fVal = 10.0f;
    }
    return fVal;
}

#pragma mark -
#pragma mark Delegate Methods

-(void)pieChart:(CPTPieChart *)plot sliceWasSelectedAtRecordIndex:(NSUInteger)index
{
    NSString *selSectionTitle = [sectionTitles objectAtIndex:index];
    double dRat = [[dataForChart objectAtIndex:index] doubleValue];
	//pieChart.title = [NSString stringWithFormat:@"%@所占比例为%0.2f%%", selSectionTitle, dRat];
    pieChart.title = [NSString stringWithFormat:@"%@所占比例为%0.0f%%", selSectionTitle, dRat];
}
@end
