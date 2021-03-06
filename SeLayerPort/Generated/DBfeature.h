/*
	DBfeature.h
	The interface definition of properties and methods for the DBfeature object.
	Generated by SudzC.com
*/

#import "Soap.h"
	
@class DBfields;
@class DBwebGeometry;

@interface DBfeature : SoapObject
{
	double _area;
	NSString* _bsm;
	NSMutableArray* _fields;
	DBwebGeometry* _geometry;
	NSString* _oid;
	
}
		
	@property double area;
	@property (retain, nonatomic) NSString* bsm;
	@property (retain, nonatomic) NSMutableArray* fields;
	@property (retain, nonatomic) DBwebGeometry* geometry;
	@property (retain, nonatomic) NSString* oid;

	+ (DBfeature*) newWithNode: (CXMLNode*) node;
	- (id) initWithNode: (CXMLNode*) node;
	- (NSMutableString*) serialize;
	- (NSMutableString*) serialize: (NSString*) nodeName;
	- (NSMutableString*) serializeAttributes;
	- (NSMutableString*) serializeElements;

@end
