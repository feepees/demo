/*
	DBqueryObject.h
	The implementation of properties and methods for the DBqueryObject object.
	Generated by SudzC.com
*/
#import "DBqueryObject.h"

#import "DBfields.h"
#import "DBrelationTable.h"
#import "DBwebGeometry.h"
@implementation DBqueryObject
	@synthesize beginRecord = _beginRecord;
	@synthesize fields = _fields;
	@synthesize limitRecord = _limitRecord;
	@synthesize outSR = _outSR;
	@synthesize relationTables = _relationTables;
	@synthesize returnShape = _returnShape;
	@synthesize spatialFeature = _spatialFeature;
	@synthesize tableName = _tableName;
	@synthesize whereCaluse = _whereCaluse;

	- (id) init
	{
		if(self = [super init])
		{
			self.fields = [[[NSMutableArray alloc] init] autorelease];
			self.relationTables = nil; // [[DBrelationTable alloc] init];
			self.spatialFeature = nil; // [[DBwebGeometry alloc] init];
			self.tableName = nil;
			self.whereCaluse = nil;

		}
		return self;
	}

	+ (DBqueryObject*) newWithNode: (CXMLNode*) node
	{
		if(node == nil) { return nil; }
		return (DBqueryObject*)[[[DBqueryObject alloc] initWithNode: node] autorelease];
	}

	- (id) initWithNode: (CXMLNode*) node {
		if(self = [super initWithNode: node])
		{
			self.beginRecord = [[Soap getNodeValue: node withName: @"beginRecord"] longLongValue];
			self.fields = [[DBfields newWithNode: [Soap getNode: node withName: @"fields"]] object];
			self.limitRecord = [[Soap getNodeValue: node withName: @"limitRecord"] longLongValue];
			self.outSR = [[Soap getNodeValue: node withName: @"outSR"] intValue];
			self.relationTables = [[DBrelationTable newWithNode: [Soap getNode: node withName: @"relationTables"]] object];
			self.returnShape = [[Soap getNodeValue: node withName: @"returnShape"] boolValue];
			self.spatialFeature = [[DBwebGeometry newWithNode: [Soap getNode: node withName: @"spatialFeature"]] object];
			self.tableName = [Soap getNodeValue: node withName: @"tableName"];
			self.whereCaluse = [Soap getNodeValue: node withName: @"whereCaluse"];
		}
		return self;
	}

	- (NSMutableString*) serialize
	{
		return [self serialize: @"queryObject"];
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
		[s appendFormat: @"<beginRecord>%@</beginRecord>", [NSString stringWithFormat: @"%ld", self.beginRecord]];
		if (self.fields != nil && self.fields.count > 0) {
			[s appendFormat: @"<fields>%@</fields>", [DBfields serialize: self.fields]];
		} else {
			[s appendString: @"<fields/>"];
		}
		[s appendFormat: @"<limitRecord>%@</limitRecord>", [NSString stringWithFormat: @"%ld", self.limitRecord]];
		[s appendFormat: @"<outSR>%@</outSR>", [NSString stringWithFormat: @"%i", self.outSR]];
		if (self.relationTables != nil) [s appendString: [self.relationTables serialize: @"relationTables"]];
		[s appendFormat: @"<returnShape>%@</returnShape>", (self.returnShape)?@"true":@"false"];
		if (self.spatialFeature != nil) [s appendString: [self.spatialFeature serialize: @"spatialFeature"]];
		if (self.tableName != nil) [s appendFormat: @"<tableName>%@</tableName>", [[self.tableName stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];
		if (self.whereCaluse != nil) [s appendFormat: @"<whereCaluse>%@</whereCaluse>", [[self.whereCaluse stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];

		return s;
	}
	
	- (NSMutableString*) serializeAttributes
	{
		NSMutableString* s = [super serializeAttributes];

		return s;
	}
	
	-(BOOL)isEqual:(id)object{
		if(object != nil && [object isKindOfClass:[DBqueryObject class]]) {
			return [[self serialize] isEqualToString:[object serialize]];
		}
		return NO;
	}
	
	-(NSUInteger)hash{
		return [Soap generateHash:self];

	}
	
	- (void) dealloc
	{
		if(self.fields != nil) { [self.fields release]; }
		if(self.relationTables != nil) { [self.relationTables release]; }
		if(self.spatialFeature != nil) { [self.spatialFeature release]; }
		if(self.tableName != nil) { [self.tableName release]; }
		if(self.whereCaluse != nil) { [self.whereCaluse release]; }
		[super dealloc];
	}

@end
