//
//  DataGridComponent.m
//
//  Created by lee jory on 09-10-22.
//  Copyright 2009 Netgen. All rights reserved.
//

#import "DataGridComponent.h"
#import "Logger.h"

@implementation DataGridScrollView
@synthesize dataGridComponent;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
    @try {
        UITouch *t = [touches anyObject];
        if([t tapCount] == 1)
        {
            DataGridComponent *d = (DataGridComponent*)dataGridComponent;
            // 计算出第几行
            NSInteger idx = [t locationInView:self].y / d.cellHeight;
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.65];
            for(int i=0;i<[d.dataSource.titles count];i++){
                UILabel *l = (UILabel*)[dataGridComponent viewWithTag:idx * d.cellHeight + i + 1000];
                l.alpha = .5;
            }
            for(int i=0;i<[d.dataSource.titles count];i++){
                UILabel *l = (UILabel*)[dataGridComponent viewWithTag:idx * d.cellHeight + i + 1000];
                l.alpha = 1.0;
            }		
            [UIView commitAnimations];
            
            [d.Delegate didSelectRowAtIndexPath:idx];
        }
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }
    return;
}

@end

@implementation DataGridComponentDataSource
@synthesize titles,data,columnWidth;
@end

//声明私有方法
@interface DataGridComponent(Private)

	/**
	 * 初始化各子视图
	 */
	-(void)layoutSubView:(CGRect)aRect;

	/**
	 * 用数据项填冲数据
	 */
	-(void)fillData;

@end


@implementation DataGridComponent
@synthesize dataSource,cellHeight,cellWidth,vRight,vLeft;
@synthesize Delegate = _Delegate;
@synthesize nDoubleTileFlg;

/////////
- (id)initWithFrame:(CGRect)aRect data:(DataGridComponentDataSource*)aDataSource DoubleTitleFlg:(int)Flg
{
	self = [super initWithFrame:aRect];
	if(self != nil)
    {
				
		self.clipsToBounds = YES;
		self.backgroundColor = [UIColor grayColor];
		self.dataSource = aDataSource;
        self.nDoubleTileFlg = Flg;
		//初始显示视图及Cell的长宽高
		contentWidth = .0;
		cellHeight = 30.0;
		cellWidth = [[dataSource.columnWidth objectAtIndex:0] intValue];
		for(int i=1;i<[dataSource.columnWidth count];i++)
			contentWidth += [[dataSource.columnWidth objectAtIndex:i] intValue];
		contentHeight = [dataSource.data count] * cellHeight;		
		contentWidth = contentWidth + [[dataSource.columnWidth objectAtIndex:0] intValue]  < aRect.size.width
			? aRect.size.width : contentWidth;

		//初始化各视图
		[self layoutSubView:aRect];
		
		//填冲数据
		[self fillData];
        
	}
	return self;
}

/*
--------------------------------------------
| vTopLeft |        vTopRight               |
|----------|--------------------------------|
|          |                                |
|- Left1  -|         Right1                 |
|          |                                |
|----------|--------------------------------|
 
 vLeft = Left1 + Right1
 vRight = vTopRight + Right1
*/
-(void)layoutSubView:(CGRect)aRect{
    @try {
        vLeftContent = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, contentHeight)];
        vRightContent = [[UIView alloc] initWithFrame:CGRectMake(0, 0, aRect.size.width - cellWidth, contentHeight)];
        vLeftContent.opaque = YES;
        vRightContent.opaque = YES;
        
        
        //初始化各视图
        if (nDoubleTileFlg == 2) {
            vTopLeft = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cellWidth, cellHeight * 2)];
            vLeft = [[DataGridScrollView alloc] initWithFrame:CGRectMake(0, cellHeight*2, aRect.size.width, aRect.size.height - cellHeight)];
        }
        else{
            vTopLeft = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cellWidth, cellHeight)];
            vLeft = [[DataGridScrollView alloc] initWithFrame:CGRectMake(0, cellHeight, aRect.size.width, aRect.size.height - cellHeight)];
        }
        


        if (nDoubleTileFlg == 2) {
            vTopRight = [[UIView alloc] initWithFrame:CGRectMake(cellWidth, 0, aRect.size.width - cellWidth, cellHeight*2)];
            vRight = [[DataGridScrollView alloc] initWithFrame:CGRectMake(cellWidth, 0, aRect.size.width - cellWidth, contentHeight)];
        }
        else{
            vTopRight = [[UIView alloc] initWithFrame:CGRectMake(cellWidth, 0, aRect.size.width - cellWidth, cellHeight)];
            vRight = [[DataGridScrollView alloc] initWithFrame:CGRectMake(cellWidth, 0, aRect.size.width - cellWidth, contentHeight)];
        }
        
        
        vLeft.dataGridComponent = self;
        vRight.dataGridComponent = self;
        
        vLeft.opaque = YES;
        vRight.opaque = YES;
        vTopLeft.opaque = YES;
        vTopRight.opaque = YES;
        
        //设置ScrollView的显示内容
        if (nDoubleTileFlg == 2) {
            vLeft.contentSize = CGSizeMake(aRect.size.width, contentHeight + cellHeight);
        }
        else{
            vLeft.contentSize = CGSizeMake(aRect.size.width, contentHeight);
        }
        
        vRight.contentSize = CGSizeMake(contentWidth,aRect.size.height - cellHeight);
        
        //设置ScrollView参数
        vRight.delegate = self;
        
        // 设置颜色
        //	vTopRight.backgroundColor = [UIColor grayColor];		
        //	vRight.backgroundColor = [UIColor grayColor];
        //	vTopLeft.backgroundColor = [UIColor colorWithRed:.7 green:.7 blue:.7 alpha:1];
        //vTopRight.backgroundColor = [UIColor brownColor];		
        //vRight.backgroundColor = [UIColor yellowColor];
        //vTopLeft.backgroundColor = [UIColor colorWithRed:.0 green:.0 blue:.0 alpha:1];
        
        //添加各视图
        [vRight addSubview:vRightContent];
        [vLeft addSubview:vLeftContent];
        [vLeft addSubview:vRight];
        [self addSubview:vTopLeft];
        [self addSubview:vLeft];
        
        [vLeft bringSubviewToFront:vRight];
        [self addSubview:vTopRight];
        [self bringSubviewToFront:vTopRight];	
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }
    return;
}


-(void)fillData{

    @try {
        float columnOffset = 0.0;
        
        //填冲标题数据
        NSArray *TopTitles = [NSArray arrayWithObjects:@"商业用地", @"工业用地",@"住宅用地",nil];
        for(int column = 0;column < [dataSource.titles count];column++){
            float columnWidth = [[dataSource.columnWidth objectAtIndex:column] floatValue];
            if (nDoubleTileFlg == 2)
            {
                // 设定地价信息列表第1-2，3-4，5-6列分别为商业用地、住宅用地、工业用地（起始列为0）。
                // 商业用地
                if ((column == 1) || (column == 3) || (column == 5)){
                    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(columnOffset, 0, (columnWidth -2) * 2, cellHeight )];
                    l.font = [UIFont systemFontOfSize:12.0f];
                    
                    l.text = [TopTitles objectAtIndex:(column - 1)/2];
                    //l.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TipBarBackground.png"]];
                    l.backgroundColor = [UIColor colorWithRed:78./255 green:85./255 blue:74./255 alpha:1.];
                    l.textColor = [UIColor whiteColor];
                    l.textAlignment = UITextAlignmentCenter;
                    
                    [vTopRight addSubview:l];
                    //columnOffset += columnWidth;
                    [l release];
                    
                    // 生地价格
                    UILabel *l2 = [[UILabel alloc] initWithFrame:CGRectMake(columnOffset, cellHeight+2, columnWidth -3, cellHeight-2 )];
                    l2.font = [UIFont systemFontOfSize:12.0f];
                    l2.text = [dataSource.titles objectAtIndex:column];
                    //l2.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TipBarBackground.png"]];
                    l2.backgroundColor = [UIColor colorWithRed:78./255 green:85./255 blue:74./255 alpha:1.];
                    l2.textColor = [UIColor whiteColor];
                    l2.textAlignment = UITextAlignmentCenter;
                    
                    [vTopRight addSubview:l2];
                    int nWith = columnWidth -1;
                    columnOffset += nWith;
                    [l2 release];
                }
                else if ((column == 2) || (column == 4) || (column == 6)) {
                    // 熟地价格
                    UILabel *l2 = [[UILabel alloc] initWithFrame:CGRectMake(columnOffset, cellHeight+2, columnWidth -3, cellHeight-2 )];
                    l2.font = [UIFont systemFontOfSize:12.0f];
                    l2.text = [dataSource.titles objectAtIndex:column];
                    //l2.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TipBarBackground.png"]];
                    l2.backgroundColor = [UIColor colorWithRed:78./255 green:85./255 blue:74./255 alpha:1.];
                    l2.textColor = [UIColor whiteColor];
                    l2.textAlignment = UITextAlignmentCenter;
                    
                    [vTopRight addSubview:l2];
                    columnOffset += (columnWidth -1);
                    [l2 release];
                }
                else{
                    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(columnOffset, 0, columnWidth -1, cellHeight*2 )];
                    l.font = [UIFont systemFontOfSize:12.0f];
                    l.text = [dataSource.titles objectAtIndex:column];
                    //l.backgroundColor = [UIColor grayColor];
                    l.backgroundColor = [UIColor colorWithRed:78./255 green:85./255 blue:74./255 alpha:1.];
                    
                    //l.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TipBarBackground.png"]];
                    l.textColor = [UIColor whiteColor];
                    l.textAlignment = UITextAlignmentCenter;
                    
                    if( 0 == column){
                        [vTopLeft addSubview:l];
                    }
                    else{
                        [vTopRight addSubview:l];
                        columnOffset += columnWidth;
                    }
                    [l release];
                }

            }
            else{
                UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(columnOffset, 0, columnWidth -1, cellHeight )];
                l.font = [UIFont systemFontOfSize:12.0f];
                l.text = [dataSource.titles objectAtIndex:column];
                //l.backgroundColor = [UIColor grayColor];
                //l.backgroundColor = [UIColor purpleColor];
                l.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TipBarBackground.png"]];
                l.textColor = [UIColor whiteColor];
                l.textAlignment = UITextAlignmentCenter;
                
                if( 0 == column){
                    [vTopLeft addSubview:l];
                }
                else{
                    [vTopRight addSubview:l];
                    columnOffset += columnWidth;
                }
                [l release];
            }

        }	
		
        //填冲数据内容	
        for(int i = 0;i<[dataSource.data count];i++){
            
            NSArray *rowData = [dataSource.data objectAtIndex:i];
            columnOffset = 0.0;
            
            for(int column=0;column<[rowData count];column++){
                float columnWidth = [[dataSource.columnWidth objectAtIndex:column] floatValue];;
                UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(columnOffset, i * cellHeight  , columnWidth, cellHeight -1 )];
                l.font = [UIFont systemFontOfSize:12.0f];
                l.text = [rowData objectAtIndex:column];
                l.textAlignment = UITextAlignmentCenter;
                l.tag = i * cellHeight + column + 1000;
                if(i % 2 == 0)
                    l.backgroundColor = [UIColor whiteColor];
                
                if( 0 == column){
                    l.frame = CGRectMake(columnOffset,  i * cellHeight , columnWidth -1 , cellHeight -1 );
                    [vLeftContent addSubview:l];
                }
                else{	
                    [vRightContent addSubview:l];
                    columnOffset += columnWidth;
                }
                [l release];
            }
            
            
        }	
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }

}

/*
 --------------------------------------------
 | vTopLeft |        vTopRight               |
 |----------|--------------------------------|
 |          |                                |
 |- Left1  -|         Right1                 |
 |          |                                |
 |----------|--------------------------------|
 
 vLeft = Left1 + Right1
 vRight = vTopRight + Right1
 */
//-------------------------------以下为事件处发方法----------------------------------------
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
	
	vTopRight.frame = CGRectMake(cellWidth, 0, vRight.contentSize.width, vTopRight.frame.size.height);
	vTopRight.bounds = CGRectMake(scrollView.contentOffset.x, 0, vTopRight.frame.size.width, vTopRight.frame.size.height);
	vTopRight.clipsToBounds = YES;	
	vRightContent.frame = CGRectMake(0, 0  , 
									 vRight.contentSize.width , contentHeight);
	[self addSubview:vTopRight];
	vRight.frame =CGRectMake(cellWidth, 0, self.frame.size.width - cellWidth, vLeft.contentSize.height); 
	[vLeft addSubview:scrollView];
	
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
	scrollView.frame = CGRectMake(cellWidth, 0, scrollView.frame.size.width, self.frame.size.height);
    if (nDoubleTileFlg == 2) {
        vRightContent.frame = CGRectMake(0, cellHeight * 2 - vLeft.contentOffset.y  ,
                                         vRight.contentSize.width , contentHeight);
    }
    else
    {
        vRightContent.frame = CGRectMake(0, cellHeight - vLeft.contentOffset.y  ,
                                         vRight.contentSize.width , contentHeight);
    }

	
	vTopRight.frame = CGRectMake(0, 0, vRight.contentSize.width, vTopRight.frame.size.height );
	vTopRight.bounds = CGRectMake(0, 0, vRight.contentSize.width, vTopRight.frame.size.height);
	[scrollView addSubview:vTopRight];
	[self addSubview:scrollView];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	if(!decelerate)
		[self scrollViewDidEndDecelerating:scrollView];
}

- (void) dealloc
{
    CGGradientRelease(gradient);
	[vLeft release];
	[vRight release];
	[vRightContent release];
	[vLeftContent release];
	[vTopLeft release];
	[vTopRight release];
	[super dealloc];
}


@end
