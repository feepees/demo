/*
	DBfeatureSet.h
	The interface definition of properties and methods for the DBfeatureSet object.
	Generated by SudzC.com
*/

#import "Soap.h"
	
@class DBfeature;
@class DBfields;

@interface DBfeatureSet : SoapObject
{
	DBfeature* _features;
	NSMutableArray* _fields;
	NSString* _geometryType;
	long _recordCount;
	NSString* _tableName;
	
}
		
	@property (retain, nonatomic) DBfeature* features;
	@property (retain, nonatomic) NSMutableArray* fields;
	@property (retain, nonatomic) NSString* geometryType;
	@property long recordCount;
	@property (retain, nonatomic) NSString* tableName;

	+ (DBfeatureSet*) newWithNode: (CXMLNode*) node;
	- (id) initWithNode: (CXMLNode*) node;
	- (NSMutableString*) serialize;
	- (NSMutableString*) serialize: (NSString*) nodeName;
	- (NSMutableString*) serializeAttributes;
	- (NSMutableString*) serializeElements;

@end