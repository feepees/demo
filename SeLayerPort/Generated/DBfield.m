/*
	DBfield.h
	The implementation of properties and methods for the DBfield object.
	Generated by SudzC.com
*/
#import "DBfield.h"

@implementation DBfield
	@synthesize displayName = _displayName;
	@synthesize name = _name;
	@synthesize value = _value;

	- (id) init
	{
		if(self = [super init])
		{
			self.displayName = nil;
			self.name = nil;
			self.value = nil;

		}
		return self;
	}

	+ (DBfield*) newWithNode: (CXMLNode*) node
	{
		if(node == nil) { return nil; }
		return (DBfield*)[[[DBfield alloc] initWithNode: node] autorelease];
	}

	- (id) initWithNode: (CXMLNode*) node {
		if(self = [super initWithNode: node])
		{
			self.displayName = [Soap getNodeValue: node withName: @"displayName"];
			self.name = [Soap getNodeValue: node withName: @"name"];
			self.value = [Soap getNodeValue: node withName: @"value"];
		}
		return self;
	}

	- (NSMutableString*) serialize
	{
		return [self serialize: @"field"];
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
		if (self.displayName != nil) [s appendFormat: @"<displayName>%@</displayName>", [[self.displayName stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];
		if (self.name != nil) [s appendFormat: @"<name>%@</name>", [[self.name stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];
		if (self.value != nil) [s appendFormat: @"<value>%@</value>", [[self.value stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];

		return s;
	}
	
	- (NSMutableString*) serializeAttributes
	{
		NSMutableString* s = [super serializeAttributes];

		return s;
	}
	
	-(BOOL)isEqual:(id)object{
		if(object != nil && [object isKindOfClass:[DBfield class]]) {
			return [[self serialize] isEqualToString:[object serialize]];
		}
		return NO;
	}
	
	-(NSUInteger)hash{
		return [Soap generateHash:self];

	}
	
	- (void) dealloc
	{
		if(self.displayName != nil) { [self.displayName release]; }
		if(self.name != nil) { [self.name release]; }
		if(self.value != nil) { [self.value release]; }
		[super dealloc];
	}

@end
