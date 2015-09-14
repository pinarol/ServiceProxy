#import "PNRObjectPopulator.h"
#import "NSObject+PNRPropertyInspector.h"
#import <Foundation/Foundation.h>
#import "NSDictionary+Additions.h"
#import "NSString+Additions.h"

static NSString *const kPNRObjectPopulatorDictionaryKey = @"DictionaryKey";
static NSString *const kPNRObjectPopulatorDateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZ";
static NSString *const kPNRObjectPopulatorArrayTypeMethodSuffix = @"Type";
static NSString *const kPNRObjectPopulatorNameValueTemplate = @"%@=%@";
static NSString *const kPNRObjectPopulatorFalse = @"false";
static NSString *const kPNRObjectPopulatorTrue = @"true";
static NSString *const kPNRObjectPopulatorAmp = @"&";

@implementation PNRObjectPopulator

#pragma mark - Public

+ (id)pnr_populateObject:(NSObject <PNRPopulatable> *)populatableObject withDictionary:(NSDictionary *)responseObject
{
    NSArray *propertyNames = [self includedPropertyNamesOfPopulatableObject:populatableObject];
    for (NSString *propertyName in propertyNames)
    {
        NSString *propertyNameDictionaryKey = [PNRObjectPopulator getPropertyNameDictionaryKeyForProperty:propertyName forPopulatable:populatableObject];
        
        id value = [responseObject valueForKey:propertyNameDictionaryKey];
        if (value && ![value isKindOfClass:[NSNull class]])
        {
            if ([PNRObjectPopulator hasMethodNamed:@"boundarySuperClass" onObject:populatableObject] &&
                [[populatableObject class] pnr_propertyWithName:propertyName isKindOfClass:[populatableObject boundarySuperClass]])
            {
                NSObject <PNRPopulatable> *newModelObj = [[populatableObject class] pnr_newInstanceForPropertyWithName:propertyName];
                [populatableObject setValue:[PNRObjectPopulator pnr_populateObject:newModelObj withDictionary:value] forKey:propertyName];
            }
            else if ([value isKindOfClass:[NSArray class]])
            {
                NSMutableArray *arrayResultValue = [[NSMutableArray alloc] init];
                NSArray *elements = (NSArray *)value;
                for (id element in elements)
                {
                    Class resultClass = [PNRObjectPopulator typeOfArrayPropertWithName:propertyName forObject:populatableObject];
                    id newObject;
                    if (resultClass == [NSString class])
                    {
                        newObject = [[NSString alloc] initWithString:element];
                    }
                    else if ([resultClass conformsToProtocol:@protocol(PNRPopulatable)])
                    {
                        NSObject <PNRPopulatable> *newModelObj = [[resultClass alloc] init];
                        newObject = [PNRObjectPopulator pnr_populateObject:newModelObj withDictionary:element];
                    }
                    else
                    {
                        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                                       reason:[NSString stringWithFormat:@"Error populating %@ object with array property: %@. Elements of array must conform to PNRPopulatable or must be type of NSString", NSStringFromClass([populatableObject class]), propertyName]
                                                     userInfo:nil];
                    }
                    if (newObject)
                    {
                        [arrayResultValue addObject:newObject];
                    }
                }
                [populatableObject setValue:arrayResultValue forKey:propertyName];
            }
            else if ([[populatableObject class] pnr_propertyWithName:propertyName isExactTypeOfClass:[NSDate class]])
            {
                NSDate *date = [[PNRObjectPopulator dateFormatterForObject:populatableObject] dateFromString:value];
                [populatableObject setValue:date forKey:propertyName];
            }
            else if ([[populatableObject class] pnr_propertyWithName:propertyName isExactTypeOfClass:[NSURL class]])
            {
                [populatableObject setValue:[NSURL URLWithString:value] forKey:propertyName];
            }
            else if ([[populatableObject class] pnr_propertyWithName:propertyName isKindOfClass:[NSDecimalNumber class]] && [value isKindOfClass:[NSString class]])
            {
                [populatableObject setValue:[NSDecimalNumber decimalNumberWithString:value] forKey:propertyName];
            }
            else if (([[populatableObject class] pnr_propertyWithName:propertyName isKindOfClass:[NSNumber class]] ||
                      [[populatableObject class] pnr_isPropertyIntegerWithName:propertyName] ||
                      [[populatableObject class] pnr_isPropertyUnsignedIntegerWithName:propertyName])
                     && [value isKindOfClass:[NSString class]])
            {
                NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                formatter.numberStyle = NSNumberFormatterDecimalStyle;
                [populatableObject setValue:[formatter numberFromString:value] forKey:propertyName];
            }
            else
            {
                [populatableObject setValue:value forKey:propertyName];
            }
        }
    }
    return populatableObject;
}

+ (NSDictionary *)pnr_dictionaryRepresentationOfObject:(NSObject <PNRPopulatable> *)populatableObject
{
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    NSArray *propertyNames = [self includedPropertyNamesOfPopulatableObject:populatableObject];
    for (NSString *propertyName in propertyNames)
    {
        id value = [populatableObject valueForKey:propertyName];
        if (value)
        {
            NSString *propertyNameDictionaryKey = [PNRObjectPopulator getPropertyNameDictionaryKeyForProperty:propertyName forPopulatable:populatableObject];
            
            if ([value isKindOfClass:[populatableObject boundarySuperClass]])
            {
                [result setObject:[PNRObjectPopulator pnr_dictionaryRepresentationOfObject:value] forKey:propertyNameDictionaryKey];
            }
            else if ([value isKindOfClass:[NSArray class]])
            {
                NSMutableArray *array = [[NSMutableArray alloc] init];
                NSArray *elements = (NSArray *)value;
                
                Class resultClass = [PNRObjectPopulator typeOfArrayPropertWithName:propertyName forObject:populatableObject];
                for (id element in elements)
                {
                    if (resultClass == [NSString class])
                    {
                        [array addObject:element];
                    }
                    else if ([element conformsToProtocol:@protocol(PNRPopulatable)])
                    {
                        [array addObject:[PNRObjectPopulator pnr_dictionaryRepresentationOfObject:element]];
                    }
                    else
                    {
                        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                                       reason:[NSString stringWithFormat:@"Error populating %@ object with array property: %@. Elements of array must conform to PNRPopulatable or must be type of NSString", NSStringFromClass([populatableObject class]), propertyName]
                                                     userInfo:nil];
                    }
                    
                }
                [result setObject:array forKey:propertyNameDictionaryKey];
            }
            else if ([value isKindOfClass:[NSDate class]])
            {
                NSDate *date = [PNRObjectPopulator adjustDate:value forPopulatable:populatableObject];
                NSString *formattedDate = [[PNRObjectPopulator dateFormatterForObject:populatableObject] stringFromDate:date];
                [result setObject:formattedDate forKey:propertyNameDictionaryKey];
            }
            else if ([[populatableObject class] pnr_isPropertyBoolWithName:propertyName])
            {
                BOOL propValue;
                
                if ([value isKindOfClass:[NSNumber class]])
                {
                    propValue = ![(NSNumber *)value isEqualToNumber:[NSNumber numberWithInt:0]];
                }
                else {//this else block is not expected to run but just in case it is implemented
                    propValue = value != 0;
                }
                [result pnr_setNonNilObject:@(propValue) forKey:propertyNameDictionaryKey];
            }
            else
            {
                [result setObject:value forKey:propertyNameDictionaryKey];
            }
        }
    }
    return result;
}

+ (NSString *)pnr_urlParameterRepresentationOfObject:(NSObject <PNRPopulatable> *)populatableObject
{
    NSMutableString *result = [NSMutableString string];
    NSArray *propertyNames = [self includedPropertyNamesOfPopulatableObject:populatableObject];
    BOOL isFirstParm = YES;
    for (NSString *propertyName in propertyNames)
    {
        id value = [populatableObject valueForKey:propertyName];
        if (value)
        {
            if (!isFirstParm)
            {
                [result appendString:kPNRObjectPopulatorAmp];
            }
            else
            {
                isFirstParm = NO;
            }
            NSString *propertyNameDictionaryKey = [PNRObjectPopulator getPropertyNameDictionaryKeyForProperty:propertyName forPopulatable:populatableObject];
            
            if ([value isKindOfClass:[NSDate class]])
            {
                [result appendString:[NSString stringWithFormat:kPNRObjectPopulatorNameValueTemplate, propertyNameDictionaryKey, [[PNRObjectPopulator dateFormatterForObject:populatableObject] stringFromDate:[PNRObjectPopulator adjustDate:value forPopulatable:populatableObject]]]];
            }
            else if ([value isKindOfClass:[NSNumber class]])
            {
                if ([populatableObject pnr_isPropertyBoolWithName:propertyName])
                {
                    [result appendString:[NSString stringWithFormat:kPNRObjectPopulatorNameValueTemplate, propertyNameDictionaryKey, [((NSNumber *)value) isEqualToNumber:@0] ? kPNRObjectPopulatorFalse : kPNRObjectPopulatorTrue]  ];
                }
                else
                {
                    [result appendString:[NSString stringWithFormat:kPNRObjectPopulatorNameValueTemplate, propertyNameDictionaryKey, ((NSNumber *)value)]];
                }
            }
            else if ([value isKindOfClass:[NSString class]])
            {
                [result appendString:[NSString stringWithFormat:kPNRObjectPopulatorNameValueTemplate, propertyNameDictionaryKey, ((NSNumber *)value)]];
            }
            else if ([value isKindOfClass:[NSData class]])
            {
                [result appendString:[NSString stringWithFormat:kPNRObjectPopulatorNameValueTemplate, propertyNameDictionaryKey, [(NSData *)value base64EncodedStringWithOptions:0]]];
            }
            else if ([value conformsToProtocol:@protocol(PNRPopulatable)])
            {
                NSString *urlParameters = [PNRObjectPopulator pnr_urlParameterRepresentationOfObject:value];
                [result appendString:urlParameters];
            }
        }
    }
    return [result pnr_URLEncodedString];
}

#pragma mark - Utilities

+ (NSArray *)includedPropertyNamesOfPopulatableObject:(NSObject <PNRPopulatable> *)populatableObject
{
    NSArray *includedPropertyNames = [[populatableObject class] pnr_allPropertyNames];
    
    if ([populatableObject respondsToSelector:@selector(excludedPropertyNames)])
    {
        NSArray *excludedPropertyNames = [populatableObject excludedPropertyNames];
        NSMutableArray *includedPropertyNamesInMutableArray = [includedPropertyNames mutableCopy];
        [includedPropertyNamesInMutableArray removeObjectsInArray:excludedPropertyNames];
        includedPropertyNames = [includedPropertyNamesInMutableArray copy];
    }
    
    return includedPropertyNames;
}

#pragma mark - Private

+ (NSDate *)adjustDate:(NSDate *)date forPopulatable:(NSObject <PNRPopulatable> *)populatableObject
{
    if ([populatableObject respondsToSelector:@selector(adjustedDateFromOriginalDate:)])
    {
        return [populatableObject adjustedDateFromOriginalDate:date];
    }
    return date;
}

+ (BOOL)hasMethodNamed:(NSString *)methodName onObject:(NSObject *)object
{
    SEL selector = NSSelectorFromString(methodName);
    return [object respondsToSelector:selector];
}

+ (NSString *)getPropertyNameDictionaryKeyForProperty:(NSString *)name forPopulatable:(NSObject <PNRPopulatable> *)populatableObject
{
    NSString *methodSuffix = kPNRObjectPopulatorDictionaryKey;
    if ([populatableObject respondsToSelector:@selector(customPropertyNameMethodSuffix)])
    {
        methodSuffix = [populatableObject customPropertyNameMethodSuffix];
    }
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%@%@", name, methodSuffix]);
    if ([populatableObject respondsToSelector:selector])
    {
        IMP imp = [populatableObject methodForSelector:selector];
        NSString * (*func)(id, SEL) = (void *)imp;
        NSString *result = func(populatableObject, selector);
        return result;
    }
    if ([populatableObject respondsToSelector:@selector(dictionaryKeyNameOfPropertyName:)])
    {
        return [populatableObject dictionaryKeyNameOfPropertyName:name];
    }
    return name;
}

+ (NSDateFormatter *)dateFormatterForObject:(NSObject <PNRPopulatable> *)populatableObject
{
    if ([populatableObject respondsToSelector:@selector(dateFormatter)])
    {
        return [populatableObject dateFormatter];
    }
    else
    {
        static NSDateFormatter *dateFormatter;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            [dateFormatter setLocale:[NSLocale systemLocale]];
            dateFormatter.dateFormat = kPNRObjectPopulatorDateFormat;
        });
        return dateFormatter;
    }
}

+ (Class)typeOfArrayPropertWithName:(NSString *)propertyName forObject:(NSObject <PNRPopulatable> *)populatableObject
{
    //due to the convention, method name which returns us the class type of the array is as following: <property name> + "Type"
    NSString *typeMethodName = [NSString stringWithFormat:@"%@%@", propertyName, kPNRObjectPopulatorArrayTypeMethodSuffix];
    SEL selector = NSSelectorFromString(typeMethodName);
    if ([populatableObject respondsToSelector:selector])
    {
        IMP imp = [populatableObject methodForSelector:selector];
        Class (*func)(id, SEL) = (void *)imp;
        Class resultClass = func(populatableObject, selector);
        return resultClass;
    }
    return nil;
}

@end
