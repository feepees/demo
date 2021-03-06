/*
	DB2CommonServiceResponse.h
	The implementation of properties and methods for the DB2CommonServiceResponse object.
	Generated by SudzC.com
*/
#import "DB2CommonServiceResponse.h"

@implementation DB2CommonServiceResponse
	@synthesize _return = __return;

	- (id) init
	{
		if(self = [super init])
		{
			self._return = nil;

		}
		return self;
	}

	+ (DB2CommonServiceResponse*) newWithNode: (CXMLNode*) node
	{
		if(node == nil) { return nil; }
		return (DB2CommonServiceResponse*)[[[DB2CommonServiceResponse alloc] initWithNode: node] autorelease];
	}

	- (id) initWithNode: (CXMLNode*) node {
		if(self = [super initWithNode: node])
		{
			self._return = [Soap getNodeValue: node withName: @"return"];
		}
		return self;
	}

	- (NSMutableString*) serialize
	{
		return [self serialize: @"CommonServiceResponse"];
	}
  
	- (NSMutableString*) serialize: (NSString*) nodeName
	{
		NSMutableString* s = [NSMutableString string];
		[s appendFormat: @"<%@", nodeName];
		[s appendString: [self serializeAttributes]];
		[s appendString: @">"];
		[s appendString: [self serializeElements]];
		[s appendFormat: @"</%@>", nodeName];
		return s;
	}
	
	- (NSMutableString*) serializeElements
	{
		NSMutableString* s = [super serializeElements];
		if (self._return != nil) [s appendFormat: @"<return>%@</return>", [[self._return stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];

		return s;
	}
	
	- (NSMutableString*) serializeAttributes
	{
		NSMutableString* s = [super serializeAttributes];

		return s;
	}
	
	-(BOOL)isEqual:(id)object{
		if(object != nil && [object isKindOfClass:[DB2CommonServiceResponse class]]) {
			return [[self serialize] isEqualToString:[object serialize]];
		}
		return NO;
	}
	
	-(NSUInteger)hash{
		return [Soap generateHash:self];

	}
	
	- (void) dealloc
	{
		if(self._return != nil) { [self._return release]; }
		[super dealloc];
	}

@end
