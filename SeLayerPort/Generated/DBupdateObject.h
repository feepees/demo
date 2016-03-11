/*
	DBupdateObject.h
	The interface definition of properties and methods for the DBupdateObject object.
	Generated by SudzC.com
*/

#import "Soap.h"
	
@class DBfeature;

@interface DBupdateObject : SoapObject
{
	DBfeature* _feature;
	NSString* _tableName;
	NSString* _whereCaluse;
	
}
		
	@property (retain, nonatomic) DBfeature* feature;
	@property (retain, nonatomic) NSString* tableName;
	@property (retain, nonatomic) NSString* whereCaluse;

	+ (DBupdateObject*) newWithNode: (CXMLNode*) node;
	- (id) initWithNode: (CXMLNode*) node;
	- (NSMutableString*) serialize;
	- (NSMutableString*) serialize: (NSString*) nodeName;
	- (NSMutableString*) serializeAttributes;
	- (NSMutableString*) serializeElements;

@end