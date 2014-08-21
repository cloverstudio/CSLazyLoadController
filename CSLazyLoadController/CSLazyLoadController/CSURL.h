//
//  CSURL.h
//  CSUtils
//
//  Created by Josip Bernat on 04/02/14.
//  Copyright (c) 2014 Clover-Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  HTTP request method types.
 */
typedef NSString *CSHTTPMethod;

extern CSHTTPMethod const CSHTTPMethodGET;      ///HTTP GET method.
extern CSHTTPMethod const CSHTTPMethodPOST;     ///HTTP POST method.
extern CSHTTPMethod const CSHTTPMethodPUT;      ///HTTP PUT method.
extern CSHTTPMethod const CSHTTPMethodDELETE;   ///HTTP DELETE method.

@interface CSURL : NSObject

/**
 *  A dictionary with the parameter values. HTTP parameter must be string values; therefore, each object and key in the parameters dictionary must be a subclass of NSString. If either the key or value for a key-value pair is not a subclass of NSString, the key-value pair is skipped.
 */
@property (nonatomic, strong) NSDictionary *parameters;

/**
 *  HTTP method tipe. Default is POST.
 */
@property (nonatomic, strong) CSHTTPMethod httpMethod;

/**
 *  NSURL object containing HTTP address.
 */
@property (nonatomic, strong, readonly) NSURL *httpURL;

/**
 *  SH256 hash value of the CSURL object. Parameters are also included if httpMethod is not CSHTTPMethodGET. Used for saving data in cache.
 */
@property (nonatomic, strong, readonly) NSString *hashValue;

/**
 *  Array of keys which will be ignored when hash is created. This can be helpful if your file contains token which can be different each time you log in.
 */
@property (nonatomic, strong) NSArray *ignoredHashParameters;

#pragma mark - Initialization
/**
 *  Creates instance with given string and CSHTTPMethodGet as httpMethod.
 *
 *  @param string Object containing HTTP address.
 *
 *  @return Instance with default configuration and httpURL property as string argument.
 */
+ (instancetype)URLWithString:(NSString *)string;

/**
 *  Creates instance with given arguments.
 *
 *  @param string     Object containing HTTP address.
 *  @param parameters Dictionary object containing NSString parameters to be sent. Both key and value must be kind of NSString.
 *  @param method     HTTP method used when executing request.
 *
 *  @return Instance with configured values with given arguments.
 */
+ (instancetype)URLWithString:(NSString *)string
                   parameters:(NSDictionary *)parameters
                       method:(CSHTTPMethod)method;

@end
