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
static NSDictionary *conversionFunctionMap;

typedef NSNumber *(^ConversionBlockType)(NSNumber *);

+ (void) initialize {
	unitMap = [[NSDictionary alloc] initWithObjectsAndKeys:
	           // mass
	           @"g",        [NSNumber numberWithInt:kUnitGram],
	           @"kg",       [NSNumber numberWithInt:kUnitKilogram],
	           @"lb",       [NSNumber numberWithInt:kUnitPound],
	           @"oz",       [NSNumber numberWithInt:kUnitOunce],

	           // volume
	           @"ml",       [NSNumber numberWithInt:kUnitMilliliter],
	           @"l",        [NSNumber numberWithInt:kUnitLiter],
	           @"oz",       [NSNumber numberWithInt:kUnitFluidOunce],
	           @"qt",       [NSNumber numberWithInt:kUnitQuart],
	           @"gal",      [NSNumber numberWithInt:kUnitGallon],

	           // time
	           @"sec",      [NSNumber numberWithInt:kUnitSecond],
	           @"min",      [NSNumber numberWithInt:kUnitMinute],
	           @"hour",     [NSNumber numberWithInt:kUnitHour],
	           @"day",      [NSNumber numberWithInt:kUnitDay],

	           // temperature
	           @"C",        [NSNumber numberWithInt:kUnitCelsius],
	           @"F",        [NSNumber numberWithInt:kUnitFahrenheit],

	           // density
	           @"qt/lb",    [NSNumber numberWithInt:kUnitQuartsPerPound],
	           @"l/kg",    [NSNumber numberWithInt:kUnitLitresPerKilogram],

	           nil];
}

+ (NSString *) abbreviationForUnit:(EConversionUnit) unit {
	return [unitMap objectForKey:[NSNumber numberWithInt:unit]];
}

+ (EConversionUnit) unitForAbbreviation:(NSString *) abbreviation {
	NSSet *set = [unitMap keysOfEntriesPassingTest:^ BOOL (id key, id obj, BOOL * stop) {
	                      return [(NSString *) obj compare:abbreviation options:NSCaseInsensitiveSearch] == NSOrderedSame;
		      }
	             ];

	if ([set count] == 0) {
		return kUnitUnknown;
	}

	return [(NSNumber *)[set anyObject] intValue];
}

@end

@interface ComplexConverter : NSObject <IConverter> {
	ConversionBlockType conversionBlock;
	ConversionBlockType inverseConversionBlock;
}

@property (nonatomic, retain) ConversionBlockType conversionBlock;
@property (nonatomic, retain) ConversionBlockType inverseConversionBlock;

@end

@implementation ComplexConverter

@synthesize displayUnit;
@synthesize cannonicalUnit;
@synthesize conversionBlock;
@synthesize inverseConversionBlock;

- (NSNumber *) convertToDisplay:(NSNumber *) value {
	return conversionBlock(value);
}

- (NSNumber *) convertToCannonical:(NSNumber *) value {
	return inverseConversionBlock(value);
}

- (void) dealloc {
	[conversionBlock release];
	[inverseConversionBlock release];
	[super dealloc];
}

@end

@interface SimpleConverter : NSObject <IConverter>
{
	EConversionUnit displayUnit;
	EConversionUnit cannonicalUnit;
	NSNumber *conversionFactor;
}

@property (nonatomic, retain) NSNumber *conversionFactor;

@end

@implementation SimpleConverter

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

	                       // from gallon
	                       [NSDictionary dictionaryWithObjectsAndKeys:
	                        [NSNumber numberWithFloat:3.78541178], [NSNumber numberWithInt:kUnitLiter],
	                        [NSNumber numberWithFloat:3785.41178], [NSNumber numberWithInt:kUnitMilliliter],
	                        [NSNumber numberWithFloat:4], [NSNumber numberWithInt:kUnitQuart],
	                        [NSNumber numberWithFloat:128], [NSNumber numberWithInt:kUnitFluidOunce],
	                        nil],
	                       [NSNumber numberWithInt:kUnitGallon],

	                       // from liters
	                       [NSDictionary dictionaryWithObjectsAndKeys:
	                        [NSNumber numberWithFloat:0.264172052], [NSNumber numberWithInt:kUnitGallon],
	                        [NSNumber numberWithFloat:1000], [NSNumber numberWithInt:kUnitMilliliter],
	                        [NSNumber numberWithFloat:1.05668821], [NSNumber numberWithInt:kUnitQuart],
	                        [NSNumber numberWithFloat:33.8140227], [NSNumber numberWithInt:kUnitFluidOunce],
	                        nil],
	                       [NSNumber numberWithInt:kUnitLiter],

	                       // from quarts
	                       [NSDictionary dictionaryWithObjectsAndKeys:
	                        [NSNumber numberWithFloat:0.25], [NSNumber numberWithInt:kUnitGallon],
	                        [NSNumber numberWithFloat:946.352946], [NSNumber numberWithInt:kUnitMilliliter],
	                        [NSNumber numberWithFloat:0.946352946], [NSNumber numberWithInt:kUnitLiter],
	                        [NSNumber numberWithFloat:32], [NSNumber numberWithInt:kUnitFluidOunce],
	                        nil],
	                       [NSNumber numberWithInt:kUnitQuart],

	                       // from fluid ounces
	                       [NSDictionary dictionaryWithObjectsAndKeys:
	                        [NSNumber numberWithFloat:0.0078125], [NSNumber numberWithInt:kUnitGallon],
	                        [NSNumber numberWithFloat:29.5735296], [NSNumber numberWithInt:kUnitMilliliter],
	                        [NSNumber numberWithFloat:0.0295735296], [NSNumber numberWithInt:kUnitLiter],
	                        [NSNumber numberWithFloat:0.03125], [NSNumber numberWithInt:kUnitQuart],
	                        nil],
	                       [NSNumber numberWithInt:kUnitFluidOunce],

	                       // from quarts per pound
	                       [NSDictionary dictionaryWithObjectsAndKeys:
	                        [NSNumber numberWithFloat:2.08635111], [NSNumber numberWithInt:kUnitLitresPerKilogram],
	                        nil],
	                       [NSNumber numberWithInt:kUnitQuartsPerPound],

	                       // from liters per kilogram
	                       [NSDictionary dictionaryWithObjectsAndKeys:
	                        [NSNumber numberWithFloat:0.479305709], [NSNumber numberWithInt:kUnitQuartsPerPound],
	                        nil],
	                       [NSNumber numberWithInt:kUnitLitresPerKilogram],

	                       // from seconds
	                       [NSDictionary dictionaryWithObjectsAndKeys:
	                        [NSNumber numberWithFloat:0.0166667], [NSNumber numberWithInt:kUnitMinute],
	                        [NSNumber numberWithFloat:0.0002778], [NSNumber numberWithInt:kUnitHour],
	                        [NSNumber numberWithFloat:0.0000116], [NSNumber numberWithInt:kUnitDay],
	                        nil],
	                       [NSNumber numberWithInt:kUnitSecond],

	                       // from minutes
	                       [NSDictionary dictionaryWithObjectsAndKeys:
	                        [NSNumber numberWithFloat:60], [NSNumber numberWithInt:kUnitSecond],
	                        [NSNumber numberWithFloat:0.0166667], [NSNumber numberWithInt:kUnitHour],
	                        [NSNumber numberWithFloat:0.0006944], [NSNumber numberWithInt:kUnitDay],
	                        nil],
	                       [NSNumber numberWithInt:kUnitMinute],

	                       // from hours
	                       [NSDictionary dictionaryWithObjectsAndKeys:
	                        [NSNumber numberWithFloat:3600], [NSNumber numberWithInt:kUnitSecond],
	                        [NSNumber numberWithFloat:60], [NSNumber numberWithInt:kUnitMinute],
	                        [NSNumber numberWithFloat:0.0416667], [NSNumber numberWithInt:kUnitDay],
	                        nil],
	                       [NSNumber numberWithInt:kUnitHour],

	                       // from days
	                       [NSDictionary dictionaryWithObjectsAndKeys:
	                        [NSNumber numberWithFloat:0.0000116], [NSNumber numberWithInt:kUnitSecond],
	                        [NSNumber numberWithFloat:0.0006944], [NSNumber numberWithInt:kUnitMinute],
	                        [NSNumber numberWithFloat:0.0416667], [NSNumber numberWithInt:kUnitHour],
	                        nil],
	                       [NSNumber numberWithInt:kUnitDay],

	                       nil];

	conversionFunctionMap = [[NSDictionary alloc] initWithObjectsAndKeys:

	                         // from Celsius
	                         [NSDictionary dictionaryWithObjectsAndKeys:
	                          ^NSNumber * (NSNumber * value) {
	                                  return [NSNumber numberWithFloat:(9.0f / 5.0f) * [value floatValue] + 32];
				  }, [NSNumber numberWithInt:kUnitFahrenheit],
	                          nil],
	                         [NSNumber numberWithInt:kUnitCelsius],

	                         // from Farhenheit
	                         [NSDictionary dictionaryWithObjectsAndKeys:
	                          ^NSNumber * (NSNumber * value) {
	                                  return [NSNumber numberWithFloat:(5.0f / 9.0f) * ([value floatValue] - 32)];
				  }, [NSNumber numberWithInt:kUnitCelsius],
	                          nil],
	                         [NSNumber numberWithInt:kUnitFahrenheit],


	                         nil];
}

- (NSNumber *) convertToDisplay:(NSNumber *) value {
	return [NSNumber numberWithFloat:[value floatValue] * [conversionFactor floatValue]];
}

- (NSNumber *) convertToCannonical:(NSNumber *) value {
	return [NSNumber numberWithFloat:[value floatValue] / [conversionFactor floatValue]];
}

- (void) dealloc {
	[conversionFactor release];
	[super dealloc];
}

@end

@implementation Converter

+ (id <IConverter>) converterFromCannonicalUnit:(EConversionUnit) cannonicalUnit toDisplayUnit:(EConversionUnit) displayUnit {
	id <IConverter> result;

	switch (cannonicalUnit) {
	case kUnitCelsius:
	case kUnitFahrenheit:
		result = [[ComplexConverter alloc] init];
		if (cannonicalUnit == displayUnit) {
			ConversionBlockType identityConverter = ^NSNumber * (NSNumber * value) {
				return value;
			};
			( (ComplexConverter *)result ).conversionBlock = identityConverter;
			( (ComplexConverter *)result ).inverseConversionBlock = identityConverter;
		}
		else {
			NSDictionary *converters = [conversionFunctionMap objectForKey:[NSNumber numberWithInt:cannonicalUnit]];
			ConversionBlockType block = [converters objectForKey:[NSNumber numberWithInt:displayUnit]];
			( (ComplexConverter *)result ).conversionBlock = block;

			converters = [conversionFunctionMap objectForKey:[NSNumber numberWithInt:displayUnit]];
			block = [converters objectForKey:[NSNumber numberWithInt:cannonicalUnit]];
			( (ComplexConverter *)result ).inverseConversionBlock = block;
		}

		break;

	default:
		result = [[SimpleConverter alloc] init];
		if (cannonicalUnit == displayUnit) {
			( (SimpleConverter *)result ).conversionFactor = [NSNumber numberWithFloat:1.0];
		}
		else {
			NSDictionary *converters = [conversionFactorMap objectForKey:[NSNumber numberWithInt:cannonicalUnit]];
			NSNumber *factor = [converters objectForKey:[NSNumber numberWithInt:displayUnit]];

			( (SimpleConverter *)result ).conversionFactor = factor;
		}
		break;
	}

	result.cannonicalUnit = cannonicalUnit;
	result.displayUnit = displayUnit;
	return [result autorelease];
}

@end


@implementation UnitNumberFormater

@synthesize unitConverter;

- (id) initWithCannonicalUnit:(EConversionUnit) cannonicalUnit andDisplayUnit:(EConversionUnit) displayUnit {
	if (self = [super init]) {
		id <IConverter> converter = [Converter converterFromCannonicalUnit:cannonicalUnit toDisplayUnit:displayUnit];
		self.unitConverter = converter;
	}
	return self;
}

- (NSString *)stringForObjectValue:(id) obj {
	NSNumber *convertedNumber = [unitConverter convertToDisplay:obj];
	NSString *result = [super stringForObjectValue:convertedNumber];
	NSString *unit = [UnitAbbreviationMapper abbreviationForUnit:self.unitConverter.displayUnit];
	return [NSString stringWithFormat:@"%@ %@", result, unit];
}

- (BOOL)getObjectValue:(out id *) obj forString:(NSString *) string errorDescription:(out NSString **) error {
	EConversionUnit fromUnit;
	NSString *stringWithoutUnits;

	const char *cstr = [string cStringUsingEncoding:NSUTF8StringEncoding];
	char s[11];
	int numMatches = sscanf(cstr, "%*f%10s", s); 

	if (numMatches < 1) {
		stringWithoutUnits = string;
		fromUnit = self.unitConverter.displayUnit;
	}
	else {
		NSString *units = [NSString stringWithUTF8String:s];
		NSRange range = [string rangeOfString:units];
		stringWithoutUnits = [string substringToIndex:range.location];
		fromUnit = [UnitAbbreviationMapper unitForAbbreviation:units]; // todo: check result

		if (fromUnit == kUnitUnknown) {
			fromUnit = self.unitConverter.cannonicalUnit;
		}
	}

	BOOL result = [super getObjectValue:obj forString:stringWithoutUnits errorDescription:error];
	id <IConverter> tempConverter = [Converter converterFromCannonicalUnit:self.unitConverter.cannonicalUnit toDisplayUnit:fromUnit];
	NSNumber *convertedObj = [tempConverter convertToCannonical:*obj];
	*obj = convertedObj;

	return result;
}

- (void) dealloc {
	[unitConverter release];
	[super dealloc];
}

@end