//
//  UnitConverter.m
//  MashMachine
//
//  Created by Tobias Patton on 11-03-08.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UnitConverter.h"

@implementation UnitAbbreviationMapper 

static NSDictionary *unitMap;
static NSDictionary *conversionFactorMap;

+ (void) initialize {
	unitMap = [[NSDictionary alloc] initWithObjectsAndKeys:
			   // mass
			   @"g",	[NSNumber numberWithInt: kUnitGram],
			   @"kg",	[NSNumber numberWithInt: kUnitKilogram],
			   @"lb",	[NSNumber numberWithInt: kUnitPound],
			   @"oz",	[NSNumber numberWithInt: kUnitOunce],
			   
			   // volume
			   @"ml",	[NSNumber numberWithInt: kUnitMilliliter],
			   @"l",	[NSNumber numberWithInt: kUnitLiter],
			   @"oz",	[NSNumber numberWithInt: kUnitFluidOunce],
			   @"qt",	[NSNumber numberWithInt: kUnitQuart],
			   @"g",	[NSNumber numberWithInt: kUnitGallon],
			   
			   nil];
}

+ (NSString *) abbreviationForUnit: (EConversionUnit) unit {
	return [unitMap objectForKey:[NSNumber numberWithInt:unit]];
}

+ (EConversionUnit) unitForAbbreviation: (NSString *) abbreviation {	
	NSSet *set = [unitMap keysOfEntriesPassingTest:^ BOOL (id key, id obj, BOOL *stop) {
		return [(NSString *)obj compare:[abbreviation lowercaseString]] == NSOrderedSame;
	}];
	
	return [(NSNumber *)[set anyObject] intValue];
}

@end

@implementation Converter

@synthesize displayUnit;
@synthesize cannonicalUnit;
@synthesize conversionFactor;

+ (void) initialize {
	conversionFactorMap = [[NSDictionary alloc] initWithObjectsAndKeys:
						   
						   // from grams
						   [NSDictionary dictionaryWithObjectsAndKeys:
							[NSNumber numberWithFloat:0.001], [NSNumber numberWithInt:kUnitKilogram],
							[NSNumber numberWithFloat:0.00220462262], [NSNumber numberWithInt:kUnitPound],
							[NSNumber numberWithFloat:0.0352739619], [NSNumber numberWithInt:kUnitOunce],
							nil],
						   [NSNumber numberWithInt:kUnitGram],
						   
						   // from kg
						   [NSDictionary dictionaryWithObjectsAndKeys:
							[NSNumber numberWithFloat:1000.0], [NSNumber numberWithInt:kUnitGram],
							[NSNumber numberWithFloat:2.20462262], [NSNumber numberWithInt:kUnitPound],
							[NSNumber numberWithFloat:35.2739619], [NSNumber numberWithInt:kUnitOunce],
							nil],
						   [NSNumber numberWithInt:kUnitKilogram],
						   
						   // from lb
						   [NSDictionary dictionaryWithObjectsAndKeys:
							[NSNumber numberWithFloat:453.59237], [NSNumber numberWithInt:kUnitGram],
							[NSNumber numberWithFloat:0.45359237], [NSNumber numberWithInt:kUnitKilogram],
							[NSNumber numberWithFloat:16.0], [NSNumber numberWithInt:kUnitOunce],
							nil],
						   [NSNumber numberWithInt:kUnitPound],
						   
						   // from oz
						   [NSDictionary dictionaryWithObjectsAndKeys:
							[NSNumber numberWithFloat:28.3495231], [NSNumber numberWithInt:kUnitGram],
							[NSNumber numberWithFloat:0.0283495231], [NSNumber numberWithInt:kUnitKilogram],
							[NSNumber numberWithFloat:0.0625], [NSNumber numberWithInt:kUnitPound],
							nil],
						   [NSNumber numberWithInt:kUnitOunce],
						   
						   nil];
}

+ (id<IConverter>) converterFromCannonicalUnit: (EConversionUnit) cannonicalUnit toDisplayUnit: (EConversionUnit) displayUnit {
	Converter *result = [[Converter alloc] init];
	
	result.cannonicalUnit = cannonicalUnit;
	result.displayUnit = displayUnit;
		
	NSDictionary *converters = [conversionFactorMap objectForKey:[NSNumber numberWithInt:cannonicalUnit]];
	NSNumber *factor = [converters objectForKey:[NSNumber numberWithInt:displayUnit]];
	
	result.conversionFactor = factor;
	
	return [result autorelease];
}

- (NSNumber *) convertToDisplay: (NSNumber *)value {
	return [NSNumber numberWithFloat:[value floatValue] * [conversionFactor floatValue]];
}

- (NSNumber *) convertToCannonical: (NSNumber *)value {
	return [NSNumber numberWithFloat:[value floatValue] / [conversionFactor floatValue]];
}

- (void) dealloc {
	[conversionFactor release];
	[super dealloc];
}

@end

@implementation UnitNumberFormater

@synthesize unitConverter;

- (id) initWithCannonicalUnit: (EConversionUnit) cannonicalUnit andDisplayUnit: (EConversionUnit) displayUnit {
	if (self = [super init]) {
		id<IConverter> converter = [Converter converterFromCannonicalUnit:cannonicalUnit toDisplayUnit:displayUnit];
		self.unitConverter = converter;
	}	
	return self;
}

- (NSString *)stringForObjectValue:(id)obj {
	NSNumber *convertedNumber = [unitConverter convertToDisplay:obj];	
	NSString *result = [super stringForObjectValue:convertedNumber];
	NSString *unit = [UnitAbbreviationMapper abbreviationForUnit:self.unitConverter.displayUnit];
	return [NSString stringWithFormat:@"%@ %@", result, unit];
}

- (BOOL)getObjectValue:(out id *)obj forString:(NSString *)string errorDescription:(out NSString **)error {
	const char *cstr = [string cStringUsingEncoding:NSUTF8StringEncoding]; 
	char s[10];
	sscanf(cstr, "%*f%10s", s); //todo: check result and create error message if required
	NSString *units = [NSString stringWithUTF8String:s];
	NSRange range = [string rangeOfString:units];
	NSString *stringWithoutUnits = [string substringToIndex:range.location];
	
	BOOL result = [super getObjectValue:obj forString:stringWithoutUnits errorDescription:error];
	
	EConversionUnit fromUnit = [UnitAbbreviationMapper unitForAbbreviation:units]; // todo: check result
	id<IConverter> tempConverter = [Converter converterFromCannonicalUnit:self.unitConverter.cannonicalUnit toDisplayUnit:fromUnit];
	NSNumber *convertedObj = [tempConverter convertToCannonical:*obj];
	*obj = convertedObj;
	[tempConverter release];
	
	return result;
}

- (void) dealloc {
	[unitConverter release];
	[super dealloc];
}

@end

