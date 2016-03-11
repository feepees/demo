/*
	DBgetLayer.h
	The interface definition of properties and methods for the DBgetLayer object.
	Generated by SudzC.com
*/

#import "Soap.h"
	

@interface DBgetLayer : SoapObject
{
	NSString* _arg0;
	
}
		
	@property (retain, nonatomic) NSString* arg0;

	+ (DBgetLayer*) newWithNode: (CXMLNode*) node;
	- (id) initWithNode: (CXMLNode*) node;
	- (NSMutableString*) serialize;
	- (NSMutableString*) serialize: (NSString*) nodeName;
	- (NSMutableString*) serializeAttributes;
	- (NSMutableString*) serializeElements;

@end