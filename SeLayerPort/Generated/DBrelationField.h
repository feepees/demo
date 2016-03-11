/*
	DBrelationField.h
	The interface definition of properties and methods for the DBrelationField object.
	Generated by SudzC.com
*/

#import "Soap.h"
	

@interface DBrelationField : SoapObject
{
	NSString* _asname;
	NSString* _fullName;
	NSString* _name;
	
}
		
	@property (retain, nonatomic) NSString* asname;
	@property (retain, nonatomic) NSString* fullName;
	@property (retain, nonatomic) NSString* name;

	+ (DBrelationField*) newWithNode: (CXMLNode*) node;
	- (id) initWithNode: (CXMLNode*) node;
	- (NSMutableString*) serialize;
	- (NSMutableString*) serialize: (NSString*) nodeName;
	- (NSMutableString*) serializeAttributes;
	- (NSMutableString*) serializeElements;

@end