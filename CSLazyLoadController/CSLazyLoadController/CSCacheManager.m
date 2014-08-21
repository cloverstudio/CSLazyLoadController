//
//  CSCacheController.m
//  BeatSeekr
//
//  Created by Josip Bernat on 12/12/13.
//  Copyright (c) 2013 Clover Studio. All rights reserved.
//

#import "CSCacheManager.h"
#import <UIKit/UIKit.h>
#import "CSURL.h"

@interface CSCacheManager ()

@property (atomic, strong) NSCache *cache;

@end

@implementation CSCacheManager

+ (CSCacheManager *)defaultCache {

    static CSCacheManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

#pragma mark - Initialization

- (id)init {

    if (self = [super init]) {
        self.cache = [[NSCache alloc] init];
        
        __weak id this = self;
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification
                                                          object:nil
                                                           queue:nil
                                                      usingBlock:^(NSNotification *note) {
                                                          
                                                          __strong CSCacheManager *strongThis = this;
                                                          [strongThis.cache removeAllObjects];
                                                      }];
    }
    return self;
}

#pragma mark - Saving Images

- (void)cacheImage:(UIImage *)image url:(CSURL *)URL saveToDisk:(BOOL)shouldSave {

    if (!URL) {
        NSParameterAssert(URL);
        return;
    }
    if (!image) {
        
        [self removeImageForURL:URL
                       fromDisk:shouldSave];
        return;
    }
    
    [self writeImageToCache:image url:URL];
    
    if (shouldSave) {
        [self writeImageToDisk:image url:URL];
    }
}

- (void)cacheData:(NSData *)data url:(CSURL *)URL saveToDisk:(BOOL)shouldSave {

}

#pragma mark - Image Writing

- (void)writeImageToCache:(UIImage *)image url:(CSURL *)URL {
    [self.cache setObject:image forKey:URL.hashValue];
}

- (void)writeImageToDisk:(UIImage *)image url:(CSURL *)URL {

    NSData *data = UIImagePNGRepresentation(image);
    [data writeToFile:[self imageFilePath:URL.hashValue] atomically:YES];
}

#pragma mark - Deleting Images

- (void)removeImageForURL:(CSURL *)URL
                 fromDisk:(BOOL)fromDisk {

    NSString *urlHash = URL.hashValue;
    [self.cache removeObjectForKey:urlHash];
    
    if (fromDisk) {
        [[NSFileManager defaultManager] removeItemAtPath:[self imageFilePath:urlHash]
                                                   error:nil];
    }
}

#pragma mark - Getting Images

- (UIImage *)readCachedImage:(CSURL *)URL
                    fromDisk:(BOOL)readFromDisk {

    if (!URL) {return nil;}
    
    NSString *urlHash = URL.hashValue;
    UIImage *image = [self.cache objectForKey:urlHash];
    
    if (!image && readFromDisk) {
        return [self readImageFromDisk:URL];
    }
    return image;
}

- (UIImage *)readImageFromDisk:(CSURL *)URL {

    NSData *data = [NSData dataWithContentsOfFile:[self imageFilePath:URL.hashValue]];
    UIImage *image = [UIImage imageWithData:data];
    if (image) {
        [self writeImageToCache:image url:URL];
    }
    return image;
}

#pragma mark - Cache Location

+ (NSString *)documentsDirectoryPath {
    
    static NSString *directoryPath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        directoryPath = [paths objectAtIndex:0];
    });
    return directoryPath;
}

- (NSString *)imageFilePath:(NSString *)hash {
    return [[CSCacheManager documentsDirectoryPath] stringByAppendingPathComponent:hash];
}

@end
