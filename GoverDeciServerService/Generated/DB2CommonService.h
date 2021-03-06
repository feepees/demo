/*
	DB2CommonService.h
	The interface definition of properties and methods for the DB2CommonService object.
	Generated by SudzC.com
*/

#import "Soap.h"
	

@interface DB2CommonService : SoapObject
{
	NSString* _arg0;
	
}
		
	@property (retain, nonatomic) NSString* arg0;

	+ (DB2CommonService*) newWithNode: (CXMLNode*) node;
	- (id) initWithNode: (CXMLNode*) node;
	- (NSMutableString*) serialize;
	- (NSMutableString*) serialize: (NSString*) nodeName;
	- (NSMutableString*) serializeAttributes;
	- (NSMutableString*) serializeElements;

@end
