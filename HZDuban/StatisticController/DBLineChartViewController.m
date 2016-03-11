//
//  DBLineChartViewViewController.m
//  HZDuban
//
//  Created by sunz on 13-1-6.
//
//

#import "DBLineChartViewController.h"

@interface DBLineChartViewController ()

@end

@implementation DBLineChartViewController
@synthesize dataForPlot, dataForPlot2;

#pragma mark - ViewLifeCycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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
	[dataForPlot release];
    [dataForPlot2 release];
    [super dealloc];
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
    
    // Create graph from theme
    graph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
	CPTTheme *theme = [CPTTheme themeNamed:kCPTDarkGradientTheme];  //kCPTSlateTheme];
    [graph applyTheme:theme];
	CPTGraphHostingView *hostingView = (CPTGraphHostingView *)self.view;
    hostingView.collapsesLayers = NO; // Setting to YES reduces GPU memory usage, but can slow drawing/scrolling
    hostingView.hostedGraph = graph;
	
    graph.paddingLeft = 10.0;
	graph.paddingTop = 10.0;
	graph.paddingRight = 10.0;
	graph.paddingBottom = 10.0;
    
    // Setup plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    NSTimeInterval oneYear = 12 * 30 * 24 * 60 * 60;   // niurg
    plotSpace.allowsUserInteraction = YES;
    //plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(1.0) length:CPTDecimalFromFloat(2.0)];
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(oneYear * -1 / 2) length:CPTDecimalFromFloat(oneYear *6.0)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-10.0) length:CPTDecimalFromFloat(100.0)];
    
    // Axes
	CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *x = axisSet.xAxis;
    //x.majorIntervalLength = CPTDecimalFromString(@"0.5");
    //x.majorIntervalLength = CPTDecimalFromString(@"12");
    x.majorIntervalLength = CPTDecimalFromFloat(oneYear);
    //x.orthogonalCoordinateDecimal = CPTDecimalFromString(@"2");
    x.orthogonalCoordinateDecimal = CPTDecimalFromString(@"0");
    x.minorTicksPerInterval = 2;
 	NSArray *exclusionRanges = [NSArray arrayWithObjects:
                                [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(1.99) length:CPTDecimalFromFloat(0.02)],
                                [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.99) length:CPTDecimalFromFloat(0.02)],
                                [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(2.99) length:CPTDecimalFromFloat(0.02)],
                                nil];
	//x.labelExclusionRanges = exclusionRanges;
    
    ////
    //NSDate *refDate = [NSDate dateWithNaturalLanguageString:@"00:00 Oct 29, 2006"];
    NSDate *refDate = [NSDate dateWithNaturalLanguageString:@"1/1/06"];
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    dateFormatter.dateStyle = kCFDateFormatterShortStyle;
    CPTTimeFormatter *myDateFormatter = [[[CPTTimeFormatter alloc] initWithDateFormatter:dateFormatter] autorelease];
    myDateFormatter.referenceDate = refDate;
    x.labelFormatter = myDateFormatter;
    
    NSDateFormatter *timeFormatter = [[[NSDateFormatter alloc] init] autorelease];
    timeFormatter.timeStyle = kCFDateFormatterShortStyle;
    CPTTimeFormatter *myTimeFormatter = [[[CPTTimeFormatter alloc] initWithDateFormatter:timeFormatter] autorelease];
    myTimeFormatter.referenceDate = refDate;
    x.minorTickLabelFormatter = myTimeFormatter;
    x.minorTickLabelFormatter = nil;
    x.minorTickLabelTextStyle = nil;
    ////
    
    CPTXYAxis *y = axisSet.yAxis;
    y.majorIntervalLength = CPTDecimalFromString(@"10");
    y.minorTicksPerInterval = 5;
    //y.orthogonalCoordinateDecimal = CPTDecimalFromString(@"2");
    y.orthogonalCoordinateDecimal = CPTDecimalFromString(@"0");
	exclusionRanges = [NSArray arrayWithObjects:
                       [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(1.99) length:CPTDecimalFromFloat(0.02)],
                       [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.99) length:CPTDecimalFromFloat(0.02)],
                       [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(3.99) length:CPTDecimalFromFloat(0.02)],
                       nil];
	y.labelExclusionRanges = exclusionRanges;
    
    NSMutableArray *barPlotArr = [[NSMutableArray alloc] initWithCapacity:5];
    
	// Create a blue plot area
	CPTScatterPlot *boundLinePlot = [[[CPTScatterPlot alloc] init] autorelease];
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.miterLimit = 1.0f;
	lineStyle.lineWidth = 3.0f;
	lineStyle.lineColor = [CPTColor blueColor];
    boundLinePlot.dataLineStyle = lineStyle;
    boundLinePlot.identifier = @"大亚湾区";
    boundLinePlot.dataSource = self;
    [barPlotArr addObject:boundLinePlot];
	[graph addPlot:boundLinePlot];
	
	// Do a blue gradient
	CPTColor *areaColor1 = [CPTColor colorWithComponentRed:0.3 green:0.3 blue:1.0 alpha:0.8];
    CPTGradient *areaGradient1 = [CPTGradient gradientWithBeginningColor:areaColor1 endingColor:[CPTColor clearColor]];
    areaGradient1.angle = -90.0f;
    CPTFill *areaGradientFill = [CPTFill fillWithGradient:areaGradient1];
    boundLinePlot.areaFill = areaGradientFill;
    boundLinePlot.areaBaseValue = [[NSDecimalNumber zero] decimalValue];
    
	// Add plot symbols
	CPTMutableLineStyle *symbolLineStyle = [CPTMutableLineStyle lineStyle];
	symbolLineStyle.lineColor = [CPTColor blackColor];
	CPTPlotSymbol *plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
	plotSymbol.fill = [CPTFill fillWithColor:[CPTColor blueColor]];
	plotSymbol.lineStyle = symbolLineStyle;
    plotSymbol.size = CGSizeMake(10.0, 10.0);
    boundLinePlot.plotSymbol = plotSymbol;
    
    // Create a green plot area
	CPTScatterPlot *dataSourceLinePlot = [[[CPTScatterPlot alloc] init] autorelease];
    lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.lineWidth = 3.f;
    lineStyle.lineColor = [CPTColor greenColor];
	lineStyle.dashPattern = [NSArray arrayWithObjects:[NSNumber numberWithFloat:5.0f], [NSNumber numberWithFloat:5.0f], nil];
    dataSourceLinePlot.dataLineStyle = lineStyle;
    dataSourceLinePlot.identifier = @"惠阳区";
    dataSourceLinePlot.dataSource = self;
    
    // Put an area gradient under the plot above
    CPTColor *areaColor = [CPTColor colorWithComponentRed:0.3 green:1.0 blue:0.3 alpha:0.8];
    CPTGradient *areaGradient = [CPTGradient gradientWithBeginningColor:areaColor endingColor:[CPTColor clearColor]];
    areaGradient.angle = -90.0f;
    areaGradientFill = [CPTFill fillWithGradient:areaGradient];
    dataSourceLinePlot.areaFill = areaGradientFill;
    dataSourceLinePlot.areaBaseValue = CPTDecimalFromString(@"1.75");
    
    ////////// add by niurg
    CPTPlotSymbol *plotSymbol2 = [CPTPlotSymbol ellipsePlotSymbol];
	plotSymbol2.fill = [CPTFill fillWithColor:[CPTColor greenColor]];
	plotSymbol2.lineStyle = symbolLineStyle;
    plotSymbol2.size = CGSizeMake(10.0, 10.0);
    dataSourceLinePlot.plotSymbol = plotSymbol2;
    ///////////
	// Animate in the new plot, as an example
	dataSourceLinePlot.opacity = 0.0f;
    [barPlotArr addObject:dataSourceLinePlot];
    [graph addPlot:dataSourceLinePlot];       // comment by niurg
	
	CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
	fadeInAnimation.duration = 1.0f;
	fadeInAnimation.removedOnCompletion = NO;
	fadeInAnimation.fillMode = kCAFillModeForwards;
	fadeInAnimation.toValue = [NSNumber numberWithFloat:1.0];
	[dataSourceLinePlot addAnimation:fadeInAnimation forKey:@"animateOpacity"];
	
    // Add some initial data
	NSMutableArray *contentArray = [NSMutableArray arrayWithCapacity:100];
	NSUInteger i;
    srand((unsigned)time(NULL));
	for ( i = 0; i < 6; i++ ) {
		//id x = [NSNumber numberWithFloat:1+i*0.05];
        id x = [NSNumber numberWithFloat:oneYear * i];
        // NSTimeInterval x = oneDay * i * 12 * 30 * 24 * 60 * 60;
        //min   +   (max   -   min)   *   rand()/RAND_MAX
		id y = [NSNumber numberWithFloat:30.0 +  rand()   %   60]; //1.2* nRand / (float)RAND_MAX + 1.2];
		[contentArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:x, @"x", y, @"y", nil]];
	}
	self.dataForPlot = contentArray;
    
    NSMutableArray *contentArray2 = [NSMutableArray arrayWithCapacity:100];
    srand((unsigned)time(NULL) + 1000);
	for ( i = 0; i < 6; i++ ) {
        id x = [NSNumber numberWithFloat:oneYear * i];
		id y = [NSNumber numberWithFloat:30.0 +  rand()   %   60];
		[contentArray2 addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:x, @"x", y, @"y", nil]];
	}
    self.dataForPlot2 = contentArray2;
    
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
    [graph setLegend:LegendData];
    // 设置说明的位置
    [graph setLegendAnchor:CPTRectAnchorTopRight];
    CGPoint pt = CGPointMake(-25,-36);
    // 设置位置的偏移
    [graph setLegendDisplacement:pt];
    
    
#ifdef PERFORMANCE_TEST
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(changePlotRange) userInfo:nil repeats:YES];
#endif
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)changePlotRange
{
    // Setup plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0) length:CPTDecimalFromFloat(3.0 + 2.0*rand()/RAND_MAX)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0) length:CPTDecimalFromFloat(3.0 + 2.0*rand()/RAND_MAX)];
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
    return [dataForPlot count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSNumber *num = [[dataForPlot objectAtIndex:index] valueForKey:(fieldEnum == CPTScatterPlotFieldX ? @"x" : @"y")];
	// Green plot gets shifted above the blue
	if ([(NSString *)plot.identifier isEqualToString:@"惠阳区"])
	{
        NSNumber *num = [[dataForPlot2 objectAtIndex:index] valueForKey:(fieldEnum == CPTScatterPlotFieldX ? @"x" : @"y")];
        
		if ( fieldEnum == CPTScatterPlotFieldY )
        {
			//num = [NSNumber numberWithDouble:[num doubleValue] + 1.0];
            num = [NSNumber numberWithDouble:[num doubleValue]];
        }
        return num;
	}
    return num;
}

@end
