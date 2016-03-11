// Copyright 2012 ESRI
//
// All rights reserved under the copyright laws of the United States
// and applicable international laws, treaties, and conventions.
//
// You may freely redistribute and use this sample code, with or
// without modification, provided you include the original copyright
// notice and use restrictions.
//
// See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>

@interface OfflineTileOperation : NSOperation <AGSTileOperation> {

@private
	id _target;
	SEL _action;
    NSString *_pngFileFullPath;
	AGSTile* _tile;
}

- (id)initWithTile:(AGSTile *)tile dataFramePath:(NSString *)path target:(id)target action:(SEL)action;


@property (nonatomic,retain) AGSTile* tile;
@property (nonatomic,retain) NSString* pngFileFullPath;
@property (nonatomic,retain) id target;
@property (nonatomic,assign) SEL action;


@end


