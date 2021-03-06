/*
	DBdeleteFeature.h
	The interface definition of properties and methods for the DBdeleteFeature object.
	Generated by SudzC.com
*/

#import "Soap.h"
	
@class DBdeleteObject;

@interface DBdeleteFeature : SoapObject
{
	DBdeleteObject* _arg0;
	
}
		
	@property (retain, nonatomic) DBdeleteObject* arg0;

	+ (DBdeleteFeature*) newWithNode: (CXMLNode*) node;
	- (id) initWithNode: (CXMLNode*) node;
	- (NSMutableString*) serialize;
	- (NSMutableString*) serialize: (NSString*) nodeName;
	- (NSMutableString*) serializeAttributes;
	- (NSMutableString*) serializeElements;

@end
