//
//  UnitConverter.h
//  MashMachine
//
//  Created by Tobias Patton on 11-03-08.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
	kUnitUnknown = 0,
	
	// mass
	kUnitGram = 1,
	kUnitKilogram = 2,
	kUnitPound = 3,
	kUnitOunce = 4,
	
	// volume
	kUnitMilliliter = 5,
	kUnitLiter = 6,
	kUnitFluidOunce = 7,
	kUnitQuart = 8,
	kUnitGallon = 9,
	
	// time
	kUnitSecond = 10,
	kUnitMinute = 11,
	kUnitHour = 12,
	kUnitDay = 13,
	
	// temperature
	kUnitCelsius = 14,
	kUnitFahrenheit = 15,
	
	// density
	kUnitQuartsPerPound = 16,
	kUnitLitresPerKilogram = 17
};

typedef int EConversionUnit;

@interface UnitAbbreviationMapper : NSObject {
}

+ (NSString *) abbreviationForUnit: (EConversionUnit) unit;
+ (EConversionUnit) unitForAbbreviation: (NSString *) abbreviation;

@end

@protocol IConverter<NSObject>

@property (assign) EConversionUnit cannonicalUnit;
@property (assign) EConversionUnit displayUnit;

- (NSNumber *) convertToDisplay: (NSNumber *)value;
- (NSNumber *) convertToCannonical: (NSNumber *)value;

@end

@interface Converter : NSObject {	
}

+ (id<IConverter>) converterFromCannonicalUnit: (EConversionUnit) cannonicalUnit toDisplayUnit: (EConversionUnit) displayUnit;

@end

@interface UnitNumberFormater : NSNumberFormatter {
	id<IConverter> unitConverter;
}

@property (nonatomic, retain) id<IConverter> unitConverter;

- (id) initWithCannonicalUnit: (EConversionUnit) cannonicalUnit andDisplayUnit: (EConversionUnit) displayUnit;

@end
