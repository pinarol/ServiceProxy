//
//  NSObject+PNRPropertyInspector.m
//  ServiceProxy
//
//  Created by Pinar Olguc on 18/03/15.
//

#import "NSObject+PNRPropertyInspector.h"
#import <objc/runtime.h>
#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>

static NSInteger const kPNRPropertyNamePrefixLength = 3;
static NSInteger const kPNRPropertyNameUnnecessaryCharsLength = 4;
static NSInteger const kPNRPropertyInfoStringBufferLength = 256;

@interface PNRSampleEmptyClass : NSObject <NSObject>

@end

@implementation PNRSampleEmptyClass

@end

@implementation NSObject (PMBAPIPropertyInspector)

#pragma mark - Property type inspector methods

- (NSArray *)pnr_allPropertyNames
{
    Class classType = [self class];
    
    if (![NSStringFromClass(classType) isEqualToString:NSStringFromClass([NSObject class])])
    {
        unsigned count;
        objc_property_t *properties = class_copyPropertyList(classType, &count);
        
        NSMutableArray *propertyNameArray = [NSMutableArray array];
        
        [classType pnr_iteratePropertiesWithBlock:^(NSString *name) {
            if (![classType pnr_shouldExcludeProperty:name])
            {
                [propertyNameArray addObject:name];
            }
        }];
        
        NSArray *result = [[classType superclass] pnr_allPropertyNames];
        if (result)
        {
            [propertyNameArray addObjectsFromArray:result];
        }
        
        free(properties);
        
        return propertyNameArray;
    }
    return nil;
}

- (NSString *)pnr_classNameOfPropertyWithName:(NSString *)propertyName
{
    NSString *propertyTypeName = [[self class] pnr_nsStringTypeOfPropertyNamed:propertyName];
    if ([propertyTypeName length] > kPNRPropertyNamePrefixLength)
    {
        return [propertyTypeName substringWithRange:NSMakeRange(kPNRPropertyNamePrefixLength, [propertyTypeName length] - kPNRPropertyNameUnnecessaryCharsLength)];
    }
    return nil;
}

- (Class)pnr_classTypeOfPropertyWithName:(NSString *)propertyName
{
    NSString *className = [[self class] pnr_classNameOfPropertyWithName:propertyName];
    return NSClassFromString(className);
}

#pragma mark - Property instance creation methods

- (id)pnr_newInstanceForPropertyWithName:(NSString *)propertyName
{
    Class classType = [self pnr_classTypeOfPropertyWithName:propertyName];
    return [[classType alloc] init];
}

#pragma mark - Property iteration methods

- (void)pnr_iteratePropertiesWithBlock:(void (^)(NSString *propertyName))block
{
    Class classType = [self class];
    unsigned count;
    objc_property_t *properties = class_copyPropertyList(classType, &count);
    unsigned i;
    for (i = 0; i < count; i++)
    {
        objc_property_t property = properties[i];
        property_getAttributes(property);
        NSString *name = [NSString stringWithUTF8String:property_getName(property)];
        block(name);
    }
    free(properties);
}

#pragma mark - Property type check methods

- (BOOL)pnr_isPropertyIntegerWithName:(NSString *)propertyName
{
    return (strcmp(@encode(int), [[self class] pnr_rawTypeOfPropertyNamed:propertyName]) == 0) ||
    (strcmp(@encode(NSInteger), [[self class] pnr_rawTypeOfPropertyNamed:propertyName]) == 0);
}

- (BOOL)pnr_isPropertyUnsignedIntegerWithName:(NSString *)propertyName
{
    return (strcmp(@encode(NSUInteger), [[self class] pnr_rawTypeOfPropertyNamed:propertyName]) == 0);
}

- (BOOL)pnr_isPropertyFloatWithName:(NSString *)propertyName
{
    return (strcmp(@encode(float), [[self class] pnr_rawTypeOfPropertyNamed:propertyName]) == 0);
}

- (BOOL)pnr_isPropertyDoubleWithName:(NSString *)propertyName
{
    return  (strcmp(@encode(double), [[self class] pnr_rawTypeOfPropertyNamed:propertyName]) == 0);
}

- (BOOL)pnr_isPropertyCGFloatWithName:(NSString *)propertyName
{
    return  (strcmp(@encode(CGFloat), [[self class] pnr_rawTypeOfPropertyNamed:propertyName]) == 0);
}

- (BOOL)pnr_isPropertyBoolWithName:(NSString *)propertyName
{
    return (strcmp(@encode(BOOL), [[self class] pnr_rawTypeOfPropertyNamed:propertyName]) == 0);
}

- (BOOL)pnr_propertyWithName:(NSString *)propertyName isExactTypeOfClass:(Class)classType
{
    NSString *classTypeString = [[self class] pnr_classNameOfPropertyWithName:propertyName];
    return [classTypeString isEqualToString:NSStringFromClass(classType)];
}

- (BOOL)pnr_propertyWithName:(NSString *)propertyName isKindOfClass:(Class)classType
{
    NSString *classTypeString = [[self class] pnr_classNameOfPropertyWithName:propertyName];
    Class propertyClassType = NSClassFromString(classTypeString);
    return [propertyClassType isSubclassOfClass:classType];
}

#pragma mark - Private

/**
 * This method is for eleminating the default properties coming from <NSObject>.
 */
- (BOOL)pnr_shouldExcludeProperty:(NSString *)propertyName
{
    // Internal pnr_allPropertyNames is not utilized here because,
    // it causes infinite loop since it will again call pnr_shouldExcludeProperty
    NSMutableArray *propertyNameArray = [NSMutableArray array];
    [[PNRSampleEmptyClass class] pnr_iteratePropertiesWithBlock:^(NSString *name) {
        [propertyNameArray addObject:name];
    }];
    for (NSString *name in propertyNameArray)
    {
        if ([propertyName isEqualToString:name])
        {
            return YES;
        }
    }
    return NO;
}

- (NSString *)pnr_nsStringTypeOfPropertyNamed:(NSString *)name
{
    return [NSString stringWithUTF8String:[[self class] pnr_typeOfPropertyNamed:name]];
}

- (const char *)pnr_typeOfPropertyNamed:(NSString *)propertyName
{
    objc_property_t property = class_getProperty([self class], [propertyName UTF8String]);
    const char *attrs = property_getAttributes(property);
    if (attrs == NULL)
    {
        return (NULL);
    }
    
    static char buffer[kPNRPropertyInfoStringBufferLength];
    const char *e = strchr(attrs, ',');
    if (e == NULL)
    {
        return (NULL);
    }
    
    int len = (int)(e - attrs);
    memcpy(buffer, attrs, len);
    buffer[len] = '\0';
    
    return (buffer);
}

- (const char *)pnr_rawTypeOfPropertyNamed:(NSString *)propertyName
{
    objc_property_t property = class_getProperty([self class], [propertyName UTF8String]);
    if (!property)
    {
        return nil;
    }
    const char *type = property_getAttributes(property);
    NSString *typeString = [NSString stringWithUTF8String:type];
    NSArray *attributes = [typeString componentsSeparatedByString:@","];
    NSString *typeAttribute = [attributes objectAtIndex:0];
    NSString *propertyType = [typeAttribute substringFromIndex:1];
    const char *rawPropertyType = [propertyType UTF8String];
    return rawPropertyType;
}

@end
