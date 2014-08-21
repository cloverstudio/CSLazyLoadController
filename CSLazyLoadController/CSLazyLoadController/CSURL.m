//
//  CSURL.m
//  CSUtils
//
//  Created by Josip Bernat on 04/02/14.
//  Copyright (c) 2014 Clover-Studio. All rights reserved.
//

#import "CSURL.h"
#import <CommonCrypto/CommonDigest.h>
#import "NSURL+Parameters.h"


CSHTTPMethod const CSHTTPMethodGET      = @"GET";
CSHTTPMethod const CSHTTPMethodPOST     = @"POST";
CSHTTPMethod const CSHTTPMethodPUT      = @"PUT";
CSHTTPMethod const CSHTTPMethodDELETE   = @"DELETE";


#pragma mark - Interface NSString (Hash)

@interface NSString (Hash)

/**
 @return NSString A hashed string using SHA256 hash function.
 */
- (NSString *)sha256String;

@end

#pragma mark - Interface CSURL

@interface CSURL ()

@property (nonatomic, strong) NSString *stringURL;
@property (nonatomic, strong) NSString *hashString;

@end

#pragma mark - Implementation CSURL

@implementation CSURL

+ (instancetype)URLWithString:(NSString *)string {
    return [self URLWithString:string parameters:nil method:CSHTTPMethodGET];
}

+ (instancetype)URLWithString:(NSString *)string
                   parameters:(NSDictionary *)parameters
                       method:(CSHTTPMethod)method {

    CSURL *url = [[self alloc] init];
    url.parameters = parameters;
    url.httpMethod = method;
    url.stringURL = string;
    url.hashString = nil;
    
    return url;
}

#pragma mark - Getters

- (NSURL *)httpURL {
    return [NSURL URLWithString:self.stringURL];
}

- (NSString *)hashValue {
    
    if (self.httpMethod == CSHTTPMethodGET || !self.parameters.count) {
        
        if (!self.ignoredHashParameters || !self.ignoredHashParameters.count) {
            return [self.stringURL sha256String];
        }
        
        NSString *stringUrl = [self.stringURL copy];
        NSURL *URL = [NSURL URLWithString:stringUrl];
        
        for (NSString *key in self.ignoredHashParameters) {
            
            NSString *value = [URL parameterForKey:key];
            if (value && value.length) {
                
                stringUrl = [stringUrl stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@=%@", key, value]
                                                                 withString:@""];
            }
        }
        
        return [stringUrl sha256String];
    }
    
    if (_hashString) { return _hashString; }
    
    NSMutableString *string = [NSMutableString stringWithFormat:@"%@?", self.stringURL];
    for (NSString *key in self.parameters.allKeys) {
        
        if (![key isKindOfClass:[NSString class]] ||
            ![self.parameters[key] isKindOfClass:[NSString class]]) {
            continue;
        }
        if ([self.ignoredHashParameters containsObject:key]) {
            continue;
        }
        
        [string appendFormat:@"%@=%@&", key, self.parameters[key]];
    }
    _hashString = [string sha256String];
    return _hashString;
}

@end

#pragma mark - Implementation NSString (Hash)

@implementation NSString (Hash)

- (NSString *)sha256String {
    
    const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:self.length];
    uint8_t digest[CC_SHA256_DIGEST_LENGTH];
    
    // This is an iOS5-specific method.
    // It takes in the data, how much data, and then output format, which in this case is an int array.
    CC_SHA256(data.bytes, (uint32_t)data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    
    // Parse through the CC_SHA256 results (stored inside of digest[]).
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

@end
