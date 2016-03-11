//
//  DBXCJGViewController.h
//  HZDuban
//
//  Created by sunz on 13-7-3.
//
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>
#import "DBBaseMapSwitchView.h"


#define kTiledMapServiceURL_0 @"http://172.16.218.116:8399/arcgis/rest/services/行政办公政务底图/DOM2000_10000V12/MapServer"


@interface DBXCJGViewController : UIViewController<UIScrollViewDelegate,AGSMapViewLayerDelegate, AGSMapViewTouchDelegate, AGSMapViewCalloutDelegate, AGSQueryTaskDelegate,AGSTiledLayerTileDelegate,MapLayerConfDelegate>
@property (retain, nonatomic) IBOutlet UIImageView *TopDataDisplayImageView;
@property (retain, nonatomic) IBOutlet UILabel *TopDataDisplayLabel;
@property (retain, nonatomic) IBOutlet UIButton *TopAddMesureBtn;
@property (retain, nonatomic) IBOutlet UIButton *MapLocationBtn;
@property (retain, nonatomic) IBOutlet UIButton *BaseMapSwitchBtn;
@property (retain, nonatomic) IBOutlet UIButton *LengthBtn;
@property (retain, nonatomic) IBOutlet UIButton *AreaBtn;

@property (retain, nonatomic) IBOutlet UIView *MapContainterView;
@property (retain, nonatomic) IBOutlet AGSMapView *BaseMapView;
- (IBAction)BackBtnTouch:(id)sender;
- (IBAction)MapLayerTouched:(id)sender;
- (IBAction)XCJGBtnTouched:(id)sender;
- (IBAction)polylineTouched:(id)sender;
- (IBAction)polygonTouched:(id)sender;
- (IBAction)MapLocationBtnTouched:(id)sender;
- (IBAction)BaseMapBtnTouched:(id)sender;
- (IBAction)TopAddMesureClick:(id)sender;

@end
