//
//  PNRObjectPopulator.h
//  ServiceProxy
//
//  Created by Pinar Olguc in 2015.
//

#import <Foundation/Foundation.h>

@protocol PNRPopulatable <NSObject>

@optional

/**
 *  If populatableObject does not implement a customPropertyNameMethodSuffix this category uses a default suffix which is "DictionaryKey"
 *  <br>
 *  If you need to use a different property name while populating you can implement a method named.
 *  <property name>+"DictionaryKey" and return the new name. For example if you do not want to use id as property name you can use:
 *  @code
 *  @property (assign, nonatomic) NSInteger myId;
 *
 *  - (NSString *)myIdDictionaryKey
 *  {
 *      return @"id";
 *  }
 */
- (NSString *)customPropertyNameMethodSuffix;

/*
 *  Date formatter used when populating property values of type NSDate.
 *  If PNRPopulatable object does not implement dateFormatter, this category uses a default date formatter with the following configuration:
 *  time zone: GMT+0
 *  locale: system locale
 *  dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
 */
- (NSDateFormatter *)dateFormatter;

/**
 *  If any adjustments needs to be done on the NSDate type properties before the population implement this method.
 *  If not implemented, default behaviour is doing nothing
 */
- (NSDate *)adjustedDateFromOriginalDate:(NSDate *)date;

/**
 *  If dictionary representation of a property is different, return the new key here. Use this when you have situations like this:
 *  UserId,
 *  ProfileImageUrl,
 *  FirstName
 *  are the dictionary representations and the corresponding properties are like:
 *  userId,
 *  profileImageUrl,
 *  firstName
 *
 *  In that case, implement this method and return [propertyName stringByCapitalizingFirstLetter];
 */
- (NSString *)dictionaryKeyNameOfPropertyName:(NSString *)propertyName;

/**
 *  This mehtod should return array of NSString. Strings should be the names of the properties. Excluded means PNRObjectPopulator will not populate the specified properties.
 *
 *  @warning Should be returned array of NSStrings.
 */
- (NSArray *)excludedPropertyNames;

@required

/**
 *  This class returned here must be subclassed by the populating class.
 *  The population will continue until it reaches this class type recursively(including itself).
 */
- (Class)boundarySuperClass;

@end

@interface PNRObjectPopulator : NSObject

/**
 *  Returns the dictionary representation of the populatable object.
 */
+ (NSDictionary *)pnr_dictionaryRepresentationOfObject:(NSObject <PNRPopulatable> *)populatableObject;

/**
 *  Sets the populatableObject property values from the dictionary. Keys of the dictionary should be same with property names.
 */
+ (id)pnr_populateObject:(NSObject <PNRPopulatable> *)populatableObject withDictionary:(NSDictionary *)responseObject;

/**
 *  Returns "name1=value1&name2=value2..." style representation of the populatable object.
 */
+ (NSString *)pnr_urlParameterRepresentationOfObject:(NSObject <PNRPopulatable> *)populatableObject;

@end
