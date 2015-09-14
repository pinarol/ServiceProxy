//
//  NSObject+PNRPropertyInspector.h
//  ServiceProxy
//
//  Created by Pinar Olguc in 2015.
//

#import <Foundation/Foundation.h>

/**
 *  This category includes methods for inspecting the properties of an object.
 */
@interface NSObject (PNRPropertyInspector)

/**
 *  @return The list of property names of this object or Class type.
 */
- (NSArray *)pnr_allPropertyNames;

/**
 *  @return The class name of a non-primitive type of property.
 */
- (NSString *)pnr_classNameOfPropertyWithName:(NSString *)propertyName;

/**
 *  @return The class type of a non-primitive type of property.
 */
- (Class)pnr_classTypeOfPropertyWithName:(NSString *)propertyName;

/**
 *  @return A new instance for the property with given name.
 */
- (id)pnr_newInstanceForPropertyWithName:(NSString *)propertyName;

/**
 *  Iterates all the properties of this object or Class type.
 */
- (void)pnr_iteratePropertiesWithBlock:(void (^)(NSString *propertyName))block;

/**
 *  @return YES if the property with the given name is int or NSInteger.
 */
- (BOOL)pnr_isPropertyIntegerWithName:(NSString *)propertyName;

/**
 *  @return YES if the property with the given name is int or NSUInteger.
 */
- (BOOL)pnr_isPropertyUnsignedIntegerWithName:(NSString *)propertyName;

/**
 *  @return YES if the property with the given name is BOOL.
 */
- (BOOL)pnr_isPropertyBoolWithName:(NSString *)propertyName;

/**
 *  @return YES if the property with the given name is float.
 */
- (BOOL)pnr_isPropertyFloatWithName:(NSString *)propertyName;

/**
 *  @return YES if the property with the given name is CGFloat.
 */
- (BOOL)pnr_isPropertyCGFloatWithName:(NSString *)propertyName;

/**
 *  @return YES if the property with the given name is double.
 */
- (BOOL)pnr_isPropertyDoubleWithName:(NSString *)propertyName;

/**
 *  @return YES if the property with the given name has the same type with the classType parameter.
 */
- (BOOL)pnr_propertyWithName:(NSString *)propertyName isExactTypeOfClass:(Class)classType;

/**
 *  @return YES if the property with the given name is a kind of the classType parameter.
 */
- (BOOL)pnr_propertyWithName:(NSString *)propertyName isKindOfClass:(Class)classType;

@end
