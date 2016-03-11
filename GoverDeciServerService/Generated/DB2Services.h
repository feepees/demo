/*
	DB2Services.h
	Creates a list of the services available with the DB2 prefix.
	Generated by SudzC.com
*/
#import "DB2GoverDeciServerService.h"

@interface DB2Services : NSObject {
	BOOL logging;
	NSString* server;
	NSString* defaultServer;
DB2GoverDeciServerService* goverDeciServerService;

}

-(id)initWithServer:(NSString*)serverName;
-(void)updateService:(SoapService*)service;
-(void)updateServices;
+(DB2Services*)service;
+(DB2Services*)serviceWithServer:(NSString*)serverName;

@property (nonatomic) BOOL logging;
@property (nonatomic, retain) NSString* server;
@property (nonatomic, retain) NSString* defaultServer;

@property (nonatomic, retain, readonly) DB2GoverDeciServerService* goverDeciServerService;

@end
			