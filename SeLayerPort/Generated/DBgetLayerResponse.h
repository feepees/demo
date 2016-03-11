/*
	DBgetLayerResponse.h
	The interface definition of properties and methods for the DBgetLayerResponse object.
	Generated by SudzC.com
*/

#import "Soap.h"
	
@class DBseLayerVO;

@interface DBgetLayerResponse : SoapObject
{
	DBseLayerVO* __return;
	
}
		
	@property (retain, nonatomic) DBseLayerVO* _return;

	+ (DBgetLayerResponse*) newWithNode: (CXMLNode*) node;
	- (id) initWithNode: (CXMLNode*) node;
	- (NSMutableString*) serialize;
	- (NSMutableString*) serialize: (NSString*) nodeName;
	- (NSMutableString*) serializeAttributes;
	- (NSMutableString*) serializeElements;

@end
