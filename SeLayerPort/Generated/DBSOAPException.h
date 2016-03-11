/*
	DBSOAPException.h
	The interface definition of properties and methods for the DBSOAPException object.
	Generated by SudzC.com
*/

#import "Soap.h"
	

@interface DBSOAPException : SoapObject
{
	
}
		

	+ (DBSOAPException*) newWithNode: (CXMLNode*) node;
	- (id) initWithNode: (CXMLNode*) node;
	- (NSMutableString*) serialize;
	- (NSMutableString*) serialize: (NSString*) nodeName;
	- (NSMutableString*) serializeAttributes;
	- (NSMutableString*) serializeElements;

@end