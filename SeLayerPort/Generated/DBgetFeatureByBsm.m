/*
	DBgetFeatureByBsm.h
	The implementation of properties and methods for the DBgetFeatureByBsm object.
	Generated by SudzC.com
*/
#import "DBgetFeatureByBsm.h"

@implementation DBgetFeatureByBsm
	@synthesize layerName = _layerName;
	@synthesize bsm = _bsm;

	- (id) init
	{
		if(self = [super init])
		{
			self.layerName = nil;
			self.bsm = nil;

		}
		return self;
	}

	+ (DBgetFeatureByBsm*) newWithNode: (CXMLNode*) node
	{
		if(node == nil) { return nil; }
		return (DBgetFeatureByBsm*)[[[DBgetFeatureByBsm alloc] initWithNode: node] autorelease];
	}

	- (id) initWithNode: (CXMLNode*) node {
		if(self = [super initWithNode: node])
		{
			self.layerName = [Soap getNodeValue: node withName: @"layerName"];
			self.bsm = [Soap getNodeValue: node withName: @"bsm"];
		}
		return self;
	}

	- (NSMutableString*) serialize
	{
		return [self serialize: @"getFeatureByBsm"];
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
		if (self.layerName != nil) [s appendFormat: @"<layerName>%@</layerName>", [[self.layerName stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];
		if (self.bsm != nil) [s appendFormat: @"<bsm>%@</bsm>", [[self.bsm stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];

		return s;
	}
	
	- (NSMutableString*) serializeAttributes
	{
		NSMutableString* s = [super serializeAttributes];

		return s;
	}
	
	-(BOOL)isEqual:(id)object{
		if(object != nil && [object isKindOfClass:[DBgetFeatureByBsm class]]) {
			return [[self serialize] isEqualToString:[object serialize]];
		}
		return NO;
	}
	
	-(NSUInteger)hash{
		return [Soap generateHash:self];

	}
	
	- (void) dealloc
	{
		if(self.layerName != nil) { [self.layerName release]; }
		if(self.bsm != nil) { [self.bsm release]; }
		[super dealloc];
	}

@end