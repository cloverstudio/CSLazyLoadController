//
//  CSCacheController.h
//  BeatSeekr
//
//  Created by Josip Bernat on 12/12/13.
//  Copyright (c) 2013 Clover Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CSURL;

/**
 *  CSCacheController class is intented to work in pair with CSLazyLoadController. It caches UIImage objects downloaded from network using RAM as default storage and optionaly to disk. Saving files to disk sometimes can take some time so it is an option.
 */

@interface CSCacheManager : NSObject

/**
 *  If the shared cache object does not exist yet, it is created.
 *
 *  @return The shared cache object.
 */
+ (CSCacheManager *)defaultCache;

#pragma mark - Saving Images

/**
 *  Caches image to RAM and optionaly to disk storage for given URL key.
 *
 *  @param image      Image object to be saved. If object is nil it will remove existing object for given URL.
 *  @param URL        URL for which image will be cached. If nil NSInvalidArgumentException is raised.
 *  @param shouldSave Boolean value determening whether image should be written to device disk or not.
 */
- (void)cacheImage:(UIImage *)image
               url:(CSURL *)URL
        saveToDisk:(BOOL)shouldSave;

#pragma mark - Getting Images
/**
 *  Returns the image associated with the specified URL.
 *
 *  @param URL          URL object which describes image in cache.
 *  @param readFromDisk Boolean value determening should try to read from device disk if image is not in RAM memory.
 *
 *  @return Image object associated with URL object.
 */
- (UIImage *)readCachedImage:(CSURL *)URL
                    fromDisk:(BOOL)readFromDisk;

@end
