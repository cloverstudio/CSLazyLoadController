//
//  CSLazyLoadController.h
//  CSLazyLoadController
//
//  Created by Created by Giga on 1/8/13.
//  Copyright (c) 2013 Clover-Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSURL.h"

@class CSLazyLoadController;

/**
 *  The delegate of a CSLazyLoadController object must adopt the CSLazyLoadControllerDelegate protocol. Methods of the protocol provide delegate feedback when image is loaded or when aditional info is required. All methods are optional since CSLazyLoadController object can be used just for reading cache without need to notify delegate when image is loaded.
 */
@protocol CSLazyLoadControllerDelegate <NSObject>

@optional

/**
 *  Asks the delegate for URL object at which image can be founded. Image is described with indexPath argument.
 *
 *  @param loadController A load - controller object requesting the URL.
 *  @param indexPath      IndexPath object describing the image position in UITableView or UICollectionVIew.
 *
 *  @return The URL object describing image HTTP location.
 */
- (CSURL *)lazyLoadController:(CSLazyLoadController *)loadController
       urlForImageAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  Tells the delegate that image load is finished for given URL associated with indexPath.
 *
 *  @param loadController A load - controller object informing the delegate of this load.
 *  @param image          Image object received after the load.
 *  @param url            URL object describing image HTTP location.
 *  @param indexPath      IndexPath object describing the image position in UITableView or UICollectionView.
 */
- (void)lazyLoadController:(CSLazyLoadController *)loadController
            didReciveImage:(UIImage *)image
                   fromURL:(CSURL *)url
                 indexPath:(NSIndexPath *)indexPath;
@end

/**
 *  CSLazyLoadController class provides easy asynchronous image load. It is suitable to use with UITableView or UICollectionView.
 */

@interface CSLazyLoadController : NSObject

/**
 *  The object that acts as the delegate of receiving lazy load controller. The delegate must adopt the CSLazyLoadControllerDelegate protocol. The delegate is not retained.
 */
@property (nonatomic, assign) id<CSLazyLoadControllerDelegate> delegate;

/**
 *  A dictionary with the header values. HTTP header fields must be string values; therefore, each object and key in the headerValues dictionary must be a subclass of NSString. If either the key or value for a key-value pair is not a subclass of NSString, the key-value pair is skipped.
 */
@property (nonatomic, strong) NSDictionary *headerValues;

/**
 *  Starts the image download if image is not present in cache. When image is founded delegate lazyLoadController:didReciveImage:fromURL:indexPath: method is called. You usually call this method after fastCacheImage: returns nil.
 *
 *  @param url       URL object which contains image HTTP location.
 *  @param indexPath IndexPath object that describes image position.
 */
- (void)startDownload:(CSURL *)url
         forIndexPath:(NSIndexPath *)indexPath;


/**
 *  Starts multiply image download, for each object in given array. You usually call this method when tableView or collectionView stops with scrolling.
 *
 *  @param indexPaths Array object containing indexPath object. For each given indexPath in array delegate lazyLoadController:urlForImageAtIndexPath: will be called.
 */
- (void)loadImagesForOnscreenRows:(NSArray *)indexPaths;

/**
 *  Searches for image associated with given URL object stored in RAM cache using CSCacheManager. You usually call this method while UITableViewCell or UICollectionViewCell dequeue is in process.
 *
 *  @param url URL object which describes image in cache.
 *
 *  @return Image object associated with URL object.
 */
- (UIImage *)fastCacheImage:(CSURL *)url;

@end
