/*
	DB2Exception.h
	The interface definition of properties and methods for the DB2Exception object.
	Generated by SudzC.com
*/

#import "Soap.h"
	

@interface DB2Exception : SoapObject
{
	NSString* _message;
	
}
		
	@property (retain, nonatomic) NSString* message;

	+ (DB2Exception*) newWithNode: (CXMLNode*) node;
	- (id) initWithNode: (CXMLNode*) node;
	- (NSMutableString*) serialize;
	- (NSMutableString*) serialize: (NSString*) nodeName;
	- (NSMutableString*) serializeAttributes;
	- (NSMutableString*) serializeElements;

@end
