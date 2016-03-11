//
//  DBBarChartViewController.m
//  HZDuban
//
//  Created by sunz on 13-1-6.
//
//

#import "DBBarChartViewController.h"

@interface DBBarChartViewController ()

@end

@implementation DBBarChartViewController
@synthesize timer, dataArr;

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
    
    ////
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.243 green:0.18 blue:0.063 alpha:0]; //[UIColor brownColor];
    
    
    // 获取各柱体的数据
    //////////
    dataArr = [[NSMutableArray alloc] initWithCapacity:4];
    
    NSMutableArray *subDataArr = [[NSMutableArray alloc] initWithCapacity:3];
    [subDataArr addObject:[NSDecimalNumber numberWithUnsignedInteger:250]];
    [subDataArr addObject:[NSDecimalNumber numberWithUnsignedInteger:200]];
    [dataArr addObject:subDataArr];
    [subDataArr release];
    subDataArr = nil;
    
    subDataArr = [[NSMutableArray alloc] initWithCapacity:3];
    [subDataArr addObject:[NSDecimalNumber numberWithUnsignedInteger:200]];
    [subDataArr addObject:[NSDecimalNumber numberWithUnsignedInteger:180]];
    [dataArr addObject:subDataArr];
    [subDataArr release];
    subDataArr = nil;
    
    subDataArr = [[NSMutableArray alloc] initWithCapacity:3];
    [subDataArr addObject:[NSDecimalNumber numberWithUnsignedInteger:160]];
    [subDataArr addObject:[NSDecimalNumber numberWithUnsignedInteger:120]];
    [dataArr addObject:subDataArr];
    [subDataArr release];
    subDataArr = nil;
    
    subDataArr = [[NSMutableArray alloc] initWithCapacity:3];
    [subDataArr addObject:[NSDecimalNumber numberWithUnsignedInteger:150]];
    [subDataArr addObject:[NSDecimalNumber numberWithUnsignedInteger:140]];
    [dataArr addObject:subDataArr];
    [subDataArr release];
    subDataArr = nil;

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
    [dataArr release];
    dataArr = nil;
    self.timer = nil;
//    [MyScrollView release];
//    [MyChartView release];
    [super dealloc];
}

- (void)viewDidUnload {
    [dataArr release];
    dataArr = nil;
//    [MyScrollView release];
//    MyScrollView = nil;
//    [MyChartView release];
//    MyChartView = nil;
    [super viewDidUnload];
}

-(void)viewWillAppear:(BOOL)animated
{
    nChartIndex = 0;
    nSubChartIndex = 0;
    CGRect rec = [self.view frame];
    
    CGFloat fWidth = rec.size.width;
    CGFloat fHeight = rec.size.height;
    
    [MyScrollView setContentSize:CGSizeMake(fWidth, fHeight-45)];
    [MyScrollView setContentOffset:CGPointMake(0, 0)];

    return;
}

-(void)viewDidAppear:(BOOL)animated
{
	[self timerFired];
#ifdef MEMORY_TEST
	self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self
												selector:@selector(timerFired) userInfo:nil repeats:YES];
#endif
}


-(void)timerFired
{
#ifdef MEMORY_TEST
	static NSUInteger counter = 0;
	
	NSLog(@"\n----------------------------\ntimerFired: %lu", counter++);
#endif
	
	[barChart release];
	
    // Create barChart from theme
    barChart = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    CPTTheme *theme = [CPTTheme themeNamed:kCPTDarkGradientTheme]; //kCPTSlateTheme]; //kCPTStocksTheme];//kCPTDarkGradientTheme];
    [barChart applyTheme:theme];
	CPTGraphHostingView *hostingView = (CPTGraphHostingView *)MyChartView;
    hostingView.hostedGraph = barChart;
    
    // Border
    barChart.plotAreaFrame.borderLineStyle = nil;
    barChart.plotAreaFrame.cornerRadius = 0.0f;
	
    barChart.paddingLeft = 10.0;
	barChart.paddingTop = 10.0;
	barChart.paddingRight = 10.0;
	barChart.paddingBottom = 10.0;
    
    barChart.plotAreaFrame.paddingLeft = 70.0;
	barChart.plotAreaFrame.paddingTop = 20.0;
	barChart.plotAreaFrame.paddingRight = 20.0;
	barChart.plotAreaFrame.paddingBottom = 80.0;
    //
    // Graph title
    barChart.title = @""; //@"Graph Title\nLine 2";
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.color = [CPTColor grayColor];
    textStyle.fontSize = 16.0f;
	textStyle.textAlignment = CPTTextAlignmentCenter;
    barChart.titleTextStyle = textStyle;
    barChart.titleDisplacement = CGPointMake(0.0f, -20.0f);
    barChart.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
	
	// Add plot space for horizontal bar charts
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)barChart.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat(300.0f)];
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat(16.0f)];
	
	CPTXYAxisSet *axisSet = (CPTXYAxisSet *)barChart.axisSet;
    CPTXYAxis *x = axisSet.xAxis;
    x.axisLineStyle = nil;
    x.majorTickLineStyle = nil;
    x.minorTickLineStyle = nil;
    x.majorIntervalLength = CPTDecimalFromString(@"5");
    x.orthogonalCoordinateDecimal = CPTDecimalFromString(@"0");
	x.title = @"地区/年份";
    x.titleLocation = CPTDecimalFromFloat(7.5f);
	x.titleOffset = 55.0f;

	
	// Define some custom labels for the data elements
	x.labelRotation = M_PI/4;
	x.labelingPolicy = CPTAxisLabelingPolicyNone; //CPTAxisLabelingPolicyNone;
    
    // 设置“2008”，“2009”等文字的左右偏移位置
	NSArray *customTickLocations = [NSArray arrayWithObjects:[NSDecimalNumber numberWithFloat:1.7], [NSDecimalNumber numberWithFloat:5.2], [NSDecimalNumber numberWithFloat:8.7], [NSDecimalNumber numberWithFloat:12.2], nil];
	//NSArray *xAxisLabels = [NSArray arrayWithObjects:@"无线城市", @"研发一部", @"研发二部", @"空间数据部", @"数字城市", nil];
    NSArray *xAxisLabels = [NSArray arrayWithObjects:@"2008年", @"2009年", @"2010年", @"2011年", nil];
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
    y.axisLineStyle = nil;
    y.majorTickLineStyle = nil;
    y.minorTickLineStyle = nil;
    y.majorIntervalLength = CPTDecimalFromString(@"50");
    y.orthogonalCoordinateDecimal = CPTDecimalFromString(@"0");
	y.title = @"案件数量";
	y.titleOffset = 45.0f;
    y.titleLocation = CPTDecimalFromFloat(150.0f);
    CPTMutableLineStyle *majorGridLineStyle = [CPTMutableLineStyle lineStyle];
    majorGridLineStyle.lineWidth = 0.5f;
    majorGridLineStyle.lineColor = [CPTColor redColor];
    y.majorGridLineStyle = majorGridLineStyle;
    
    // 设置 Y轴的显示高度（比如总高度为300，可只显示100-200区域范围）
    y.visibleRange  = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(20.0f) length:CPTDecimalFromFloat(250.0f)];
    //y.gridLinesRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat(8.0f)];
    //y.minorGridLineStyle = majorGridLineStyle;
    NSMutableArray *barPlotArr = [[NSMutableArray alloc] initWithCapacity:5];
    
    
    // 无线城市
    CPTBarPlot *barPlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor greenColor] horizontalBars:NO];
    barPlot.baseValue = CPTDecimalFromString(@"0");
    barPlot.dataSource = self;
    barPlot.barOffset = CPTDecimalFromFloat(0.0f);
    barPlot.identifier = @"查出违法总事件";
    //NSDecimal barWid = [barPlot barWidth];
    //NSLog(@"%@", barWid);
    barPlot.barWidth = CPTDecimalFromFloat(0.9f);
    
    CGFloat  radius = barPlot.barCornerRadius;
    NSLog(@"%f", radius);
    barPlot.barCornerRadius = 0.0f; //radius + 5;
    ///
    barPlot.opacity = 0.0f;
    CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
	fadeInAnimation.duration = 1.0f;
	fadeInAnimation.removedOnCompletion = NO;
	fadeInAnimation.fillMode = kCAFillModeForwards;
	fadeInAnimation.toValue = [NSNumber numberWithFloat:1.0];
	[barPlot addAnimation:fadeInAnimation forKey:@"animateOpacity"];
    ///
    [barPlotArr addObject:barPlot];
    [barChart addPlot:barPlot toPlotSpace:plotSpace];

    ///////////////
    
    // 国土事业部
    barPlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor redColor] horizontalBars:NO];
    barPlot.dataSource = self;
    barPlot.baseValue = CPTDecimalFromString(@"0");
    barPlot.barOffset = CPTDecimalFromFloat(3.5f);
    barPlot.barCornerRadius = 0.0f; //15.0f;
    barPlot.identifier = @"已处理事件";
    barPlot.barWidth = CPTDecimalFromFloat(0.9f);
    
    ///
    barPlot.opacity = 0.0f;
	[barPlot addAnimation:fadeInAnimation forKey:@"animateOpacity"];
    ///
    
    [barPlotArr addObject:barPlot];
    //barPlot.barsAreHorizontal = YES;
    // [barPlot setBarTips:xAxisLabels];
    //    barPlot.barTips = xAxisLabels;
    [barChart addPlot:barPlot toPlotSpace:plotSpace];
    
    // 研发一部
    barPlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor yellowColor] horizontalBars:NO];
    barPlot.dataSource = self;
    barPlot.baseValue = CPTDecimalFromString(@"0");
    barPlot.barOffset = CPTDecimalFromFloat(7.0f);
    barPlot.barCornerRadius = 0.0f; //15.0f;
    barPlot.identifier = @"研发一部";
    barPlot.barWidth = CPTDecimalFromFloat(0.9f);
    //[barPlotArr addObject:barPlot];
    ///
    barPlot.opacity = 0.0f;
	[barPlot addAnimation:fadeInAnimation forKey:@"animateOpacity"];
    ///
    [barChart addPlot:barPlot toPlotSpace:plotSpace];
    
    // 营销中心
    barPlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor blueColor] horizontalBars:NO];
    barPlot.dataSource = self;
    barPlot.baseValue = CPTDecimalFromString(@"0");
    barPlot.barOffset = CPTDecimalFromFloat(10.5f);
    barPlot.barCornerRadius = 0.0f; //15.0f;
    barPlot.identifier = @"营销中心";
    barPlot.barWidth = CPTDecimalFromFloat(0.9f);
    //[barPlotArr addObject:barPlot];
    ///
    barPlot.opacity = 0.0f;
	[barPlot addAnimation:fadeInAnimation forKey:@"animateOpacity"];
    ///
    [barChart addPlot:barPlot toPlotSpace:plotSpace];
    
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
    [barChart setLegend:LegendData];
    // 设置说明的位置
    [barChart setLegendAnchor:CPTRectAnchorTopRight];
    CGPoint pt = CGPointMake(-5,-36);
    // 设置位置的偏移
    [barChart setLegendDisplacement:pt];
    
    return;
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
    return 2;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSDecimalNumber *num = nil;
    int nModVal = 0;
    if([plot isKindOfClass:[CPTBarPlot class]])
    {
		switch ( fieldEnum )
        {
			case CPTBarPlotFieldBarLocation:
                index=index+1;
                //num = [dataArr objectAtIndex:index];
				num = (NSDecimalNumber *)[NSDecimalNumber numberWithUnsignedInteger:index];
				break;
			case CPTBarPlotFieldBarTip:
                nModVal = index % 2;
                if(nModVal == 1)
                {
                    num = [[dataArr objectAtIndex:nChartIndex] objectAtIndex:nModVal];
                    nChartIndex++;
                }
                else{
                    num = [[dataArr objectAtIndex:nChartIndex] objectAtIndex:nModVal];
                }

                NSLog(@"%d-%d:%@",nChartIndex, nModVal, num);
				break;
		}
    }
    // NSLog(@"%@", num);
    return num;
}

// 为每一类别柱图填充不同的颜色
-(CPTFill *) barFillForBarPlot:(CPTBarPlot *)barPlot recordIndex:(NSUInteger)index;
{
    //int nVal = [index intValue];
    //NSLog(@"======%d", index);
    if(index == 0)
    {
        CPTGradient *fillGradient = [CPTGradient gradientWithBeginningColor:[CPTColor greenColor] endingColor:[CPTColor blackColor]];
        fillGradient.angle = 0;
        return  [CPTFill fillWithGradient:fillGradient];
    }
    else if(index == 1)
    {
        CPTGradient *fillGradient = [CPTGradient gradientWithBeginningColor:[CPTColor redColor] endingColor:[CPTColor blackColor]];
        fillGradient.angle = 0;
        return  [CPTFill fillWithGradient:fillGradient];
    }
    else if(index == 2)
    {
        CPTGradient *fillGradient = [CPTGradient gradientWithBeginningColor:[CPTColor blueColor] endingColor:[CPTColor blackColor]];
        fillGradient.angle = 0;
        return  [CPTFill fillWithGradient:fillGradient];
    }
    else{
        return nil;
    }
    
    
	//return  nil;
}

@end
