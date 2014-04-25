//
//  CSLazyLoadController.m
//  CSLazyLoadController
//
//  Created by Josip Bernat on 1/8/13.
//  Copyright (c) 2013 Clover-Studio. All rights reserved.
//

#import "CSLazyLoadController.h"
#import "CSCacheManager.h"

@interface CSLazyLoadController ()

@end

@implementation CSLazyLoadController

@synthesize delegate = _delegate;

#pragma mark - Class Methods

+ (NSOperationQueue *)sharedCacheOperationQueue {

    static NSOperationQueue *_cacheOperationQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _cacheOperationQueue = [[NSOperationQueue alloc] init];
        _cacheOperationQueue.maxConcurrentOperationCount = 3;
    });
    
    return _cacheOperationQueue;
}

+ (NSOperationQueue *)sharedDownloadingOperationQueue {

    static NSOperationQueue *_downloadingOperationQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _downloadingOperationQueue = [[NSOperationQueue alloc] init];
        _downloadingOperationQueue.maxConcurrentOperationCount = 3;
    });
    
    return _downloadingOperationQueue;
}

+ (NSMutableSet *)sharedReadingUrlsSet {

    static NSMutableSet   *_readingUrlsSet = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _readingUrlsSet = [[NSMutableSet alloc] init];
    });
    
    return _readingUrlsSet;
}

+ (NSMutableSet *)sharedDownloadingUrlsSet {

    static NSMutableSet   *_downloadingUrlsSet = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _downloadingUrlsSet = [[NSMutableSet alloc] init];
    });
    
    return _downloadingUrlsSet;
}

#pragma mark - Initialization

- (id)init {
    
    if (self = [super init]) {
        [CSCacheManager defaultCache];
    }
    
    return self;
}

#pragma mark - Actions

- (void)notifyDelegateForImage:(UIImage *)image
                       fromUrl:(CSURL *)imageURL
                     indexPath:(NSIndexPath *)indexPath {
    
    if ([(NSObject *)_delegate respondsToSelector:@selector(lazyLoadController:didReciveImage:fromURL:indexPath:)]) {
        
        if ([NSThread isMainThread]) {
            [_delegate lazyLoadController:self
                           didReciveImage:image
                                  fromURL:imageURL
                                indexPath:indexPath];
        }
        else {
            __weak id this = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                
                __strong CSLazyLoadController *strongThis = this;
                [strongThis.delegate lazyLoadController:strongThis
                                         didReciveImage:image
                                                fromURL:imageURL
                                              indexPath:indexPath];
            });
        }
    }
}

- (void)readURLCache:(CSURL *)url
           indexPath:(NSIndexPath *)indexPath {

    if (!url) {
        [self notifyDelegateForImage:nil
                             fromUrl:url
                           indexPath:indexPath];
        return;
    }
    
    [[CSLazyLoadController sharedReadingUrlsSet] addObject:url];
    
    __weak id this = self;
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        
        UIImage *image = [[CSCacheManager defaultCache] readCachedImage:url
                                                               fromDisk:YES];
        if (image) {
            __strong CSLazyLoadController *strongThis = this;
            [strongThis notifyDelegateForImage:image
                                       fromUrl:url
                                     indexPath:indexPath];
        }
        else {
            __strong CSLazyLoadController *strongThis = this;
            [strongThis readURLContnent:url indexPath:indexPath];
        }
        
        [[CSLazyLoadController sharedReadingUrlsSet] removeObject:url];
    }];
    operation.queuePriority = NSOperationQueuePriorityHigh;
    [[CSLazyLoadController sharedCacheOperationQueue] addOperation:operation];
}


- (void)readURLContnent:(CSURL *)url
              indexPath:(NSIndexPath *)indexPath {

    if (!url) {
        [self notifyDelegateForImage:nil
                             fromUrl:url
                           indexPath:indexPath];
        return;
    }
    
    [[CSLazyLoadController sharedDownloadingUrlsSet] addObject:url];
    
    __weak id this = self;
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        
        NSURLResponse *response = nil;
        NSError *error = nil;
        
        __strong CSLazyLoadController *strongThis = this;
        NSMutableURLRequest *request = [strongThis urlRequestForURL:url];
        
        NSData *data = [NSURLConnection sendSynchronousRequest:request
                                             returningResponse:&response
                                                         error:&error];
        
        [[CSCacheManager defaultCache] cacheImage:[UIImage imageWithData:data]
                                              url:url
                                       saveToDisk:YES];
        
        UIImage *downloadedImage = [UIImage imageWithData:data];
        
        [strongThis notifyDelegateForImage:downloadedImage
                                   fromUrl:url
                                 indexPath:indexPath];
        
        [[CSLazyLoadController sharedDownloadingUrlsSet] removeObject:url];
    }];
    operation.queuePriority = NSOperationQueuePriorityLow;
    [[CSLazyLoadController sharedDownloadingOperationQueue] addOperation:operation];
}

- (NSMutableURLRequest *)urlRequestForURL:(CSURL *)url {
    
    NSParameterAssert(url);
    NSAssert([url isKindOfClass:[CSURL class]], @"URL must be CSURL kind of class");
    if (!url){return nil;}
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url.httpURL
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:25];
    [request setHTTPMethod:[url httpMethod]];

    if (![url.httpMethod isEqualToString:CSHTTPMethodGET] && url.parameters.count) {
        
        NSMutableArray *parts = [[NSMutableArray alloc] init];
        for (NSString *key in url.parameters) {
            if (![key isKindOfClass:[NSString class]] || ![url.parameters[key] isKindOfClass:[NSString class]]) {
                continue;
            }
            
            NSString *encodedValue = [url.parameters[key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSString *encodedKey = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSString *part = [NSString stringWithFormat:@"%@=%@", encodedKey, encodedValue];
            [parts addObject:part];
        }
        
        NSString *encodedDictionary = [parts componentsJoinedByString:@"&"];

        NSData *httpBody = [encodedDictionary dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:httpBody];
        
        [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)httpBody.length] forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    }
    
    for (NSString *headerField in self.headerValues.allKeys) {
        
        NSString *headerValue = self.headerValues[headerField];
        if (![headerValue isKindOfClass:[NSString class]]) {
            continue;
        }
        [request setValue:headerValue forHTTPHeaderField:headerField];
    }
    return request;
}

- (void)startDownload:(CSURL *)url
         forIndexPath:(NSIndexPath *)indexPath {
    
    NSParameterAssert(url);
    NSAssert([url isKindOfClass:[CSURL class]], @"URL must be CSURL kind of class");
    
    [self readURLCache:url indexPath:indexPath];
}

- (void)loadImagesForOnscreenRows:(NSArray *) indexPaths {
    
    NSArray *copyPaths = [indexPaths copy];
    for (NSIndexPath *indexPath in copyPaths) {
        
        CSURL *url = nil;
        if ([(NSObject *)_delegate respondsToSelector:@selector(lazyLoadController:urlForImageAtIndexPath:)]) {
            
            url = [_delegate lazyLoadController:self
                         urlForImageAtIndexPath:indexPath];
        }
        
		if (url) {
            [self startDownload:url forIndexPath:indexPath];
		}
	}
}

- (UIImage *)fastCacheImage:(CSURL *)url {
    
    if (!url) { return nil; }
    NSAssert([url isKindOfClass:[CSURL class]], @"URL must be CSURL kind of class");
    
    return [[CSCacheManager defaultCache] readCachedImage:url
                                                 fromDisk:NO];
}

@end
