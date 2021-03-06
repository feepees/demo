/*
	DBupdateResponse.h
	The interface definition of properties and methods for the DBupdateResponse object.
	Generated by SudzC.com
*/

#import "Soap.h"
	
#import "DBabstractResponse.h"
@class DBabstractResponse;


@interface DBupdateResponse : DBabstractResponse
{
	
}
		

	+ (DBupdateResponse*) newWithNode: (CXMLNode*) node;
	- (id) initWithNode: (CXMLNode*) node;
	- (NSMutableString*) serialize;
	- (NSMutableString*) serialize: (NSString*) nodeName;
	- (NSMutableString*) serializeAttributes;
	- (NSMutableString*) serializeElements;

@end
