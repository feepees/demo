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

#import "OfflineableTiledMapServiceLayer.h"
#import "OfflineTileOperation.h"
#import "Logger.h"
#import "DBLocalTileDataManager.h"
#import "DBMyModalAlertView.h"
#import "Reachability.h"

// 是否启用可离线模式
//static bool EnableOffline = true;
//static NSString *DBName = @"OfflineTiles.db";
//static NSString *TableServicesName = @"MapServices";

// 数据库的名称
#define  DATABASE_FILE_NAME     @"OfflineTiles.db"
// 表的名称
#define  TABLE_SERVICE_NAME     @"MapServices"


//Function to convert [UNIT] component in WKT to AGSUnits
/*
int MakeAGSUnits(NSString* wkt)
{
	NSString* value ;
	BOOL _continue = YES;
 	NSScanner* scanner = [NSScanner scannerWithString:wkt];
	//Scan for the UNIT information in WKT. 
	//If WKT is for a Projected Coord System, expect two instances of UNIT, and use the second one
	while (_continue) {
		[scanner scanUpToString:@"UNIT[\"" intoString:NULL];
		[scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"UNIT[\""]];
		_continue = [scanner scanUpToString:@"\"" intoString:&value];
	}
	if([@"Foot_US" isEqualToString:value] || [@"Foot" isEqualToString:value]){
		return AGSUnitsFeet;
	}else if([@"Meter" isEqualToString:value]){
		return AGSUnitsMeters;
	}else if([@"Degree" isEqualToString:value]){
		return AGSUnitsDecimalDegrees;
	}else{
		//TODO: Not handling other units like Yard, Chain, Grad, etc
		return -1;
	}
}
*/

@implementation OfflineableTiledMapServiceLayer

-(AGSUnits)units{
	return _units;
}

-(AGSSpatialReference *)spatialReference{
	return _fullEnvelope.spatialReference;
}
 
-(AGSEnvelope *)fullEnvelope{
	return _fullEnvelope;
}
 
-(AGSEnvelope *)initialEnvelope{
	//Assuming our initial extent is the same as the full extent
	return _fullEnvelope;
}

-(AGSTileInfo*) tileInfo{
	return _tileInfo;
}

//- (void)tiledLayer:(AGSTiledLayer *) layer operationDidFailToGetTile:(NSOperation *) op
//{
//    return;
//}
//- (void)tiledLayer:(AGSTiledLayer *) layer operationDidGetTile:(NSOperation *) op
//{
//	//Add the operation to the queue for execution
//    //[super.operationQueue addOperation:op];
//    
////    NSOperation<AGSTileOperation>* op2 = (NSOperation<AGSTileOperation>*)op;
////    AGSTile *tile =  op2.tile;
//    
//    return;
//}


#pragma mark -
- (id)initWithDataFramePath: (NSURL *)url error:(NSError**) outError 
{

    if ([super initWithURL:url])
    {
        bMapServerIsReachable = NO;
        //
        //self.tileDelegate = self;
        [self InitDataBase];
        NSString *MapUrl = url.absoluteString;
        NSString *hostName = [url host];
        DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
        bMapServerIsReachable = [DataMan GetHostNetStatus:hostName];
        if(bMapServerIsReachable)
        {
            BOOL bRet = [self LoadLayerMetaData:MapUrl];
            if (!bRet) 
            {
                // 无本地元数据，则加载网络数据。
                //网络连通,保存当前layer的meta数据
                NSError *err = nil;
                AGSMapServiceInfo *serviceInfo = [AGSMapServiceInfo mapServiceInfoWithURL:url error:&err];
                if (serviceInfo == nil) 
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"领导决策系统"
                                                                    message:@"不能连接到指定的地图服务"
                                                                   delegate:self
                                                          cancelButtonTitle:@"确定" otherButtonTitles: nil];
                    [alert show];
                    
                    [alert release];
                }
                else 
                {
                    AGSTileInfo * _TileInfo = [serviceInfo tileInfo];
                    _tileInfo = [[AGSTileInfo alloc] initWithDpi: _TileInfo.dpi 
                                                          format:_TileInfo.format 
                                                            lods:[_TileInfo.lods copy]
                                                          origin:[_TileInfo.origin copy]
                                                spatialReference:[_TileInfo.spatialReference copy]
                                                        tileSize:_TileInfo.tileSize];
                    _fullEnvelope = [[AGSEnvelope alloc] initWithXmin:[serviceInfo fullEnvelope].xmin ymin:[serviceInfo fullEnvelope].ymin xmax:[serviceInfo fullEnvelope].xmax ymax:[serviceInfo fullEnvelope].ymax spatialReference:[_TileInfo.spatialReference copy]];
                    
                    NSDictionary *SRDic = [_fullEnvelope.spatialReference encodeToJSON];
                    NSString *SrJson = [SRDic AGSJSONRepresentation];
                    
                    NSDictionary *FullEx = [_fullEnvelope encodeToJSON];
                    NSString *FullExtentJson = [FullEx AGSJSONRepresentation];
                    
                    NSDictionary *TileInfoDic = [_tileInfo encodeToJSON];
                    NSString *TileInfoJson = [TileInfoDic AGSJSONRepresentation];
                    
                    // 存储当前地图服务的元数据
                    [self SaveLayerMetaData:MapUrl SpatialReference:SrJson FullExtent:FullExtentJson TileInfo:TileInfoJson];
                    
                    // 初始化切片存储表
                    [self InitTileTableByMapUrl:MapUrl];
                }
            }

        }
        else 
        {
            // 网络中断,读取本地Meta数据
            [self LoadLayerMetaData:MapUrl];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"领导决策系统"
                                                            message:@"不能连通底图服务器,试图加载离线数据"
                                                           delegate:self
                                                  cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            
            [alert release];
        }
        //[self layerDidLoad];
        [super layerDidLoad];
    }
  
    return self;
}
- (void)layerDidFailToLoad:(NSError *) error
{
    return;
}

//-(void)layerDidLoad
//{
//    [super layerDidLoad];
//    [self setTileDelegate:self];
//     return;
//}

#pragma mark -
- (NSOperation<AGSTileOperation>*) retrieveImageAsyncForTile:(AGSTile *) tile
{
    // 查询本地是否有当前tile
    
//    UIImage *Image = [self LoadTile:tile.level Row:tile.row Column:tile.column];
//    if (Image == nil) {
//        // 本地数据库未存储当前切片，则从服务器加载。
    //[self setTileDelegate:self];
    //    }
    
    
//    NSString *pngDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
//    NSString *pngImageName = [NSString stringWithFormat:@"%d.png", tile.column];
//    // create [~/Documents/Tiles/row/column.png] similar directory
//    NSString *pngDirectory = [NSString stringWithFormat:@"%@/Tiles/%d/%d", pngDir, tile.level, tile.row];
//    NSString *pngFileFullPath = [NSString stringWithFormat:@"%@/%@", pngDirectory, pngImageName];
//    
//    NSFileManager *fileMgr = [NSFileManager defaultManager];
//    BOOL bRet = [fileMgr fileExistsAtPath:pngFileFullPath];
    DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
    BOOL bRet = [DataMan TileFileIsExist:tile.level Row:tile.row Column:tile.column];
    if (!bRet) {
        return [super retrieveImageAsyncForTile:tile];
    }
    
	//Create an operation to fetch tile from local cache
    NSString *pngFileFullPath = [DataMan GetTileFullPath:tile.level Row:tile.row Column:tile.column];
	OfflineTileOperation *operation = [[OfflineTileOperation alloc] initWithTile:tile
											dataFramePath:pngFileFullPath
												   target:self 
												   action:@selector(didFinishOperation:)];
	//Add the operation to the queue for execution
    [super.operationQueue addOperation:operation];
    return [operation autorelease];
}

- (void) didFinishOperation:(NSOperation<AGSTileOperation>*)op {
	//If tile was found ...
	if (op.tile.image!=nil) {
		//... notify tileDelegate of success
		[self.tileDelegate tiledLayer:self operationDidGetTile:op];
	}else {
		//... notify tileDelegate of failure
		[self.tileDelegate tiledLayer:self operationDidFailToGetTile:op];
	}
    [self dataChanged];
}

#pragma mark -
- (void)dealloc {
	[_fullEnvelope release];
	[_tileInfo release];
    [super dealloc];
}


//////////////////////////////////////
#pragma mark 路径
- (NSString*)getDabaBasePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:DATABASE_FILE_NAME];
    return path;
}

// 查询指定的表是否存在
-(BOOL)IsTableExist:(NSString*)tableName
{
    sqlite3_stmt *statement = nil;
    char sqlBuf[1024];
    memset(sqlBuf, 0x00, sizeof(sqlBuf));
    sprintf(sqlBuf, "select name from sqlite_master where type='table' and name='%s'",[tableName UTF8String]);
    int nRet = sqlite3_prepare_v2(database, sqlBuf, -1, &statement, NULL);
    if (nRet != SQLITE_OK) 
    {
        //NSLog(@"error");
    }
    BOOL bRet = FALSE;
    
    if (sqlite3_step(statement) == SQLITE_ROW) {
        bRet = TRUE;
    }
    
    int totalRow = sqlite3_column_count(statement);
    if (totalRow <= 0) {
        //NSLog(@"the table is not exist");
    }
    sqlite3_finalize(statement);
    return bRet;
}

//【2】创建表格
//创建表格，假设有五个字段，（id，cid，title，imageData ，imageLen ） //说明一下，id为表格的主键，必须有。 //cid，和title都是字符串，imageData是二进制数据，imageLen 是该二进制数据的长度。 
- (BOOL)createTableBySql:(NSString*)sqlstr
{ 
    sqlite3_stmt *statement; 
    const char* sqlTmp = [sqlstr UTF8String];
    int nRet = sqlite3_prepare_v2(database, sqlTmp, -1, &statement, nil);
    if(nRet != SQLITE_OK) 
    { 
        //NSLog(@"Error: failed to prepare statement:create channels table"); 
        return NO; 
    } 
    int success = sqlite3_step(statement); 
    sqlite3_finalize(statement); 
    if ( success != SQLITE_DONE) 
    { 
        //NSLog(@"Error: failed to dehydrate:CREATE TABLE channels"); 
        return NO; 
    } 
    //NSLog(@"Create table 'channels' successed."); 
    
    return YES; 
}  

-(BOOL)SaveOneTile:(int)nLevel Row:(int)nRow Column:(int)nColumn TileImage:(UIImage*)Image
{
    NSString *MapUrl = [self URL].path;
    
    NSData* ImageData = UIImagePNGRepresentation(Image); 
    NSInteger Imagelen = [ImageData length]; 
    sqlite3_stmt *statement;
    //const char *test = "test1";
    
    char sqlBuf[500];
    memset(sqlBuf, 0x00, sizeof(sqlBuf));
    sprintf(sqlBuf, "INSERT INTO '%s' (level,row,column,tile)\
            VALUES(?,?,?,?)",[MapUrl UTF8String]);
    
    //问号的个数要和(cid,title,imageData,imageLen)里面字段的个数匹配，代表未知的值，将在下面将值和字段关联。 
    int success = sqlite3_prepare_v2(database, sqlBuf, -1, &statement, NULL); 
    if (success != SQLITE_OK) 
    { 
        //NSLog(@"Error: failed to insert:channels"); 
        return NO; 
    } 
    //这里的数字1，2，3，4代表第几个问号 
    sqlite3_bind_int(statement, 1, nLevel); 
    sqlite3_bind_int(statement, 2, nRow); 
    sqlite3_bind_int(statement, 3, nColumn); 
    sqlite3_bind_blob(statement, 4, [ImageData bytes], Imagelen, SQLITE_TRANSIENT); 
    
    success = sqlite3_step(statement); 
    sqlite3_finalize(statement); 
    
    if (success == SQLITE_ERROR) { 
        //NSLog(@"Error: failed to insert into the database with message."); 
        return NO; 
    }  
    
    return YES; 
}

-(BOOL)SaveOrReplaceOneTile:(int)nLevel Row:(int)nRow Column:(int)nColumn TileImage:(UIImage*)Image
{
    NSString *MapUrl = [self URL].path;
    
    NSData* ImageData = UIImagePNGRepresentation(Image); 
    NSInteger Imagelen = [ImageData length]; 
    sqlite3_stmt *statement;
    char sqlBuf[500];
    memset(sqlBuf, 0x00, sizeof(sqlBuf));
    sprintf(sqlBuf, "INSERT OR REPLACE INTO '%s' (level,row,column,tile)\
            VALUES(?,?,?,?)",[MapUrl UTF8String]);
    
    //问号的个数要和(cid,title,imageData,imageLen)里面字段的个数匹配，代表未知的值，将在下面将值和字段关联。 
    int success = sqlite3_prepare_v2(database, sqlBuf, -1, &statement, NULL); 
    if (success != SQLITE_OK) 
    { 
        //NSLog(@"Error: failed to insert:channels"); 
        return NO; 
    } 
    //这里的数字1，2，3，4代表第几个问号 
    sqlite3_bind_int(statement, 1, nLevel); 
    sqlite3_bind_int(statement, 2, nRow); 
    sqlite3_bind_int(statement, 3, nColumn); 
    sqlite3_bind_blob(statement, 4, [ImageData bytes], Imagelen, SQLITE_TRANSIENT); 
    
    success = sqlite3_step(statement); 
    sqlite3_finalize(statement); 
    
    if (success == SQLITE_ERROR) { 
        //NSLog(@"Error: failed to insert into the database with message."); 
        return NO; 
    }  
    
    return YES; 
}

-(UIImage*)LoadTile:(int)nLevel Row:(int)nRow Column:(int)nColumn
{
    sqlite3_stmt *statement = nil; 
    //const char *sql = "SELECT * FROM channels2"; 
    NSString *MapUrl = [self URL].path;
    
    char sqlBuf[500];
    memset(sqlBuf, 0x00, sizeof(sqlBuf));
    sprintf(sqlBuf, "SELECT tile FROM '%s' WHERE level = '%d' AND row = '%d' AND \
            column = '%d'",[MapUrl UTF8String], nLevel, nRow, nColumn);
    if (sqlite3_prepare_v2(database, sqlBuf, -1, &statement, NULL) != SQLITE_OK) 
    { 
        //NSLog(@"Error: failed to prepare statement with message:get channels."); 
    } 
    //查询结果集中一条一条的遍历所有的记录，这里的数字对应的是列值。 
    while (sqlite3_step(statement) == SQLITE_ROW) 
    { 
        //char* cid       = (char*)sqlite3_column_text(statement, 1); 
        //char* title     = (char*)sqlite3_column_text(statement, 2); 
        const char* imageData = (const char*)sqlite3_column_blob(statement, 3);     
        int imageLen = strlen(imageData);
        if(imageData)
        { 
            sqlite3_finalize(statement); 
            UIImage* image = [UIImage imageWithData:[NSData dataWithBytes:imageData length:imageLen]]; 
            return image;
        } 
    } 
    sqlite3_finalize(statement); 
    return nil;
}

// 数据库和服务信息表（信息表中的每一条记录对应一个切片表）
-(BOOL)InitDataBase
{
    BOOL bRet = NO;
    
    // 1.创建或打开数据库
    NSString *writableDBPath = [self getDabaBasePath];
    int nRet = sqlite3_open_v2([writableDBPath UTF8String], &database, SQLITE_OPEN_READWRITE|SQLITE_OPEN_CREATE, nil);
    if(nRet != SQLITE_OK) 
    { 
        sqlite3_close(database); 
        //NSLog(@"Error: open database file."); 
        return NO; 
    } 
    
    // 2.创建或打开MapServices表 
    bRet = [self IsTableExist:TABLE_SERVICE_NAME];
    if (!bRet) 
    {
        char sqlBuf[1024];
        memset(sqlBuf, 0x00, sizeof(sqlBuf));
        sprintf(sqlBuf, "CREATE TABLE '%s' (url text primary key not null unique, \
                spatialreference text not null, \
                fullextent text not null, \
                tileinfo text not null)",[TABLE_SERVICE_NAME UTF8String]);
        //sprintf(sqlBuf, "CREATE TABLE '%s' (url text primary key not null unique, \
                spatialreference text not null, \
                fullextent text not null, \
                tileinfo blob not null)",[TABLE_SERVICE_NAME UTF8String]);
        NSString *sql = [NSString stringWithCString:sqlBuf encoding:NSUTF8StringEncoding];
        
        bRet = [self createTableBySql:sql];
    }
    
    return bRet;
}

// 创建存储切片的表
-(BOOL)InitTileTableByMapUrl:(NSString*)MapUrl
{
    // 查询当前表是否已经存在
    BOOL bRet = NO;
    bRet = [self IsTableExist:MapUrl];
    if (bRet) {
        return YES;
    }
    
    // 创建切片存储表
    char sqlBuf[1024];
    memset(sqlBuf, 0x00, sizeof(sqlBuf));
    sprintf(sqlBuf, "CREATE TABLE '%s' (level integer not null, row integer not null, column integer not null, tile blob not null)", [MapUrl UTF8String]);
    NSString *sql = [NSString stringWithCString:sqlBuf encoding:NSUTF8StringEncoding];
    bRet = [self createTableBySql:sql];
    return bRet;
}

// 保存当前底图层元数据
-(BOOL)SaveLayerMetaData:(NSString*)url  SpatialReference:(NSString*)jsonSR FullExtent:(NSString*)jsonFullExtent TileInfo:(NSString*)jsonTileInfo
//-(BOOL)SaveLayerMetaData:(NSString*)url  SpatialReference:(NSString*)jsonSR FullExtent:(NSString*)jsonFullExtent TileInfo:(NSData*)jsonTileInfo
{
    sqlite3_stmt *statement;
    
    char sqlBuf[1024];
    memset(sqlBuf, 0x00, sizeof(sqlBuf));
    sprintf(sqlBuf, "INSERT OR REPLACE INTO '%s' (url,spatialreference,fullextent,tileinfo)\
            VALUES(?,?,?,?)",[TABLE_SERVICE_NAME UTF8String]);
    
    //问号的个数要和(cid,title,imageData,imageLen)里面字段的个数匹配，代表未知的值，将在下面将值和字段关联。 
    int success = sqlite3_prepare_v2(database, sqlBuf, -1, &statement, NULL); 
    if (success != SQLITE_OK) 
    { 
        //NSLog(@"Error: failed to insert:%@", TABLE_SERVICE_NAME); 
        return NO; 
    } 
    //这里的数字1，2，3，4代表第几个问号 
    sqlite3_bind_text(statement, 1, [url UTF8String], -1, SQLITE_TRANSIENT); 
    sqlite3_bind_text(statement, 2, [jsonSR UTF8String], -1, SQLITE_TRANSIENT); 
    sqlite3_bind_text(statement, 3, [jsonFullExtent UTF8String], -1, SQLITE_TRANSIENT); 
    sqlite3_bind_text(statement, 4, [jsonTileInfo UTF8String], -1, SQLITE_TRANSIENT); 
    //NSInteger Imagelen = [jsonTileInfo length]; 
    //sqlite3_bind_blob(statement, 4, [jsonTileInfo bytes], Imagelen, SQLITE_TRANSIENT); 
    
    success = sqlite3_step(statement); 
    sqlite3_finalize(statement); 
    
    if (success == SQLITE_ERROR) { 
        //NSLog(@"Error: failed to insert into the database with message."); 
        return NO; 
    }  

    return YES;
}

-(BOOL)LoadLayerMetaData:(NSString*)MapUrl
{
    @try {
        sqlite3_stmt *statement = nil; 
        
        char sqlBuf[500];
        memset(sqlBuf, 0x00, sizeof(sqlBuf));
        sprintf(sqlBuf, "SELECT * FROM '%s' WHERE url = '%s'",[TABLE_SERVICE_NAME UTF8String], [MapUrl UTF8String]);
        if (sqlite3_prepare_v2(database, sqlBuf, -1, &statement, NULL) != SQLITE_OK) 
        { 
            sqlite3_finalize(statement);
            return NO;
        } 
        //查询结果集中一条一条的遍历所有的记录，这里的数字对应的是列值。 
        NSInteger nCnt = 0;
        while (sqlite3_step(statement) == SQLITE_ROW) 
        { 
            //char* MapUrl = (char*)sqlite3_column_text(statement, 0); 
            //char* srJson = (char*)sqlite3_column_text(statement, 1); 
            //NSString *srJson2 = [NSString stringWithCString:srJson encoding:NSUTF8StringEncoding];
            
            char* FullEnvelopJson = (char*)sqlite3_column_text(statement, 2); 
            NSString *FullEnvelopJson2 = [NSString stringWithCString:FullEnvelopJson encoding:NSUTF8StringEncoding];
            NSDictionary* FullEnvelopDic = [FullEnvelopJson2 AGSJSONValue]; 
            _fullEnvelope = [[AGSEnvelope alloc] initWithJSON:FullEnvelopDic];
            
            char* TileInfoJson = (char*)sqlite3_column_text(statement, 3); 
            NSString *TileInfoJson2 = [NSString stringWithCString:TileInfoJson encoding:NSUTF8StringEncoding];
            NSDictionary* TileInfoDic = [TileInfoJson2 AGSJSONValue]; 
            AGSTileInfo*tileInf = [[AGSTileInfo alloc] initWithJSON:TileInfoDic];
            nCnt++;
//            int n = 0;
//            AGSLOD *lod = nil;
//            for (lod in tileInf.lods) {
//                //NSLog(@"%@", [lod description]);
//                n++;
//            }
            
//            const char* TileInfoData = (const char*)sqlite3_column_blob(statement, 3);        
//            int imageLen = strlen(TileInfoData);
//            NSError *err = nil;
//            AGSTileInfo*tileInf = nil;
//            NSData *tileData = [NSData dataWithBytes:TileInfoData length:imageLen];
//            if(tileData)
//            { 
//                NSMutableDictionary* TileInfoDic = [NSJSONSerialization JSONObjectWithData:tileData options:NSJSONReadingMutableContainers error:&err]; 
//                tileInf = [[AGSTileInfo alloc] initWithJSON:TileInfoDic];
//            }     
            
            _tileInfo = [[AGSTileInfo alloc] initWithDpi: tileInf.dpi 
                                                  format:tileInf.format 
                                                    lods:[tileInf lods]
                                                  origin:[tileInf.origin copy]
                                        spatialReference:[tileInf.spatialReference copy]
                                                tileSize:tileInf.tileSize];
            [self.tileInfo computeTileBounds:self.fullEnvelope ];
            
            //NSString * mapUrl = [NSString stringWithCString:MapUrl encoding:NSUTF8StringEncoding];
            //NSLog(@"%@", mapUrl);
            break;
        } 
        sqlite3_finalize(statement); 
        if (nCnt == 0) {
            return NO;
        }
        return YES;
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }
    
}

@end

