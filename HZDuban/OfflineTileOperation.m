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

#import "OfflineTileOperation.h"

@implementation OfflineTileOperation

@synthesize pngFileFullPath = _pngFileFullPath;
@synthesize tile=_tile;
@synthesize target=_target;
@synthesize action=_action;

#ifdef _FOR_DEBUG_  
-(BOOL) respondsToSelector:(SEL)aSelector {  
    printf("SELECTOR: %s  FileName: %s\n", [NSStringFromSelector(aSelector) UTF8String], __FILE__);
    return [super respondsToSelector:aSelector];  
}  
#endif

- (id)initWithTile:(AGSTile *)tile dataFramePath:(NSString *)path target:(id)target action:(SEL)action {
	
	if (self = [super init]) {
		self.target = target;
		self.action = action;
		self.pngFileFullPath = path;
		self.tile = tile;
		
	}
	return self;
}

-(void)main {
	//Fetch the tile for the requested Level, Row, Column
	@try {
       _tile.image = [UIImage imageWithContentsOfFile:_pngFileFullPath];
        
        
        /* org code
		//Level ('L' followed by 2 decimal digits)
		NSString *decLevel = [NSString stringWithFormat:@"L%02d",self.tile.level];
		//Row ('R' followed by 8 hex digits)
		NSString *hexRow = [NSString stringWithFormat:@"R%08x",self.tile.row];
		//Column ('C' followed by 8 hex digits)  
		NSString *hexCol = [NSString stringWithFormat:@"C%08x",self.tile.column];
		
		NSString* dir = [_allLayersPath stringByAppendingFormat:@"/%@/%@",decLevel,hexRow];
		
		//Check for PNG file
		NSString *tileImagePath = [[NSBundle mainBundle] pathForResource:hexCol ofType:@"png" inDirectory:dir];
		
		if (nil != tileImagePath) {
			_tile.image= [UIImage imageWithContentsOfFile:tileImagePath];
		}else {
			//If no PNG file, check for JPEG file
			tileImagePath = [[NSBundle mainBundle] pathForResource:hexCol ofType:@"jpg" inDirectory:dir];
			if (nil != tileImagePath) {
				_tile.image= [UIImage imageWithContentsOfFile:tileImagePath];
			}

		}
		*/
	}
	@catch (NSException *exception) {
		//NSLog(@"main: Caught Exception %@: %@", [exception name], [exception reason]);
	}
	@finally {
		//Invoke the layer's action method
		[_target performSelector:_action withObject:self];
	}
}

- (void)dealloc {
	self.target = nil;
	self.action = nil;

	self.tile = nil;
	[super dealloc];	
}

@end


