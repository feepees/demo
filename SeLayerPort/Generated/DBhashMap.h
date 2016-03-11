/*
	DBhashMap.h
	The interface definition of properties and methods for the DBhashMap object.
	Generated by SudzC.com
*/

#import "Soap.h"
	
#import "DBabstractMap.h"
@class DBabstractMap;


@interface DBhashMap : DBabstractMap
{
	
}
		

	+ (DBhashMap*) newWithNode: (CXMLNode*) node;
	- (id) initWithNode: (CXMLNode*) node;
	- (NSMutableString*) serialize;
	- (NSMutableString*) serialize: (NSString*) nodeName;
	- (NSMutableString*) serializeAttributes;
	- (NSMutableString*) serializeElements;

@end
