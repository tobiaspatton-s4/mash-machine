//
//  UnitConverter.h
//  MashMachine
//
//  Created by Tobias Patton on 11-03-08.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
	// mass
	kUnitGram,
	kUnitKilogram,
	kUnitPound,
	kUnitOunce,
	
	// volume
	kUnitMilliliter,
	kUnitLiter,
	kUnitFluidOunce,
	kUnitQuart,
	kUnitGallon
};

typedef int EConversionUnit;

@interface UnitAbbreviationMapper : NSObject {
}

+ (NSString *) abbreviationForUnit: (EConversionUnit) unit;
+ (EConversionUnit) unitForAbbreviation: (NSString *) abbreviation;

@end

@protocol IConverter<NSObject>

@property (nonatomic, retain) NSNumber *conversionFactor;
@property (assign) EConversionUnit cannonicalUnit;
@property (assign) EConversionUnit displayUnit;

- (NSNumber *) convertToDisplay: (NSNumber *)value;
- (NSNumber *) convertToCannonical: (NSNumber *)value;

@end

@interface Converter : NSObject<IConverter>
{
	EConversionUnit displayUnit;
	EConversionUnit cannonicalUnit;
	NSNumber *conversionFactor;
}

+ (id<IConverter>) converterFromCannonicalUnit: (EConversionUnit) cannonicalUnit toDisplayUnit: (EConversionUnit) displayUnit;

@end

@interface UnitNumberFormater : NSNumberFormatter {
	id<IConverter> unitConverter;
}

@property (nonatomic, retain) id<IConverter> unitConverter;

- (id) initWithCannonicalUnit: (EConversionUnit) cannonicalUnit andDisplayUnit: (EConversionUnit) displayUnit;

@end
