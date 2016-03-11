/*
	DBinsertFeatureResponse.h
	The interface definition of properties and methods for the DBinsertFeatureResponse object.
	Generated by SudzC.com
*/

#import "Soap.h"
	
@class DBinsertResponse;

@interface DBinsertFeatureResponse : SoapObject
{
	DBinsertResponse* __return;
	
}
		
	@property (retain, nonatomic) DBinsertResponse* _return;

	+ (DBinsertFeatureResponse*) newWithNode: (CXMLNode*) node;
	- (id) initWithNode: (CXMLNode*) node;
	- (NSMutableString*) serialize;
	- (NSMutableString*) serialize: (NSString*) nodeName;
	- (NSMutableString*) serializeAttributes;
	- (NSMutableString*) serializeElements;

@end
