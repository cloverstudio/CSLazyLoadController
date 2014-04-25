CSLazyLoadController
====================

CSLazyLoadController helps you intergrate lazy loading images in iOS apps.

### Installation with CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries like JBMessage in your projects.

#### Podfile

```ruby
platform :ios, '6.0'
pod 'CSLazyLoadController', '~> 1.0'
```

## Usage
### Create property and conform to CSLazyLoadControllerDelegate 
```objective-c
	@interface CSViewController () <CSLazyLoadControllerDelegate>

	@property (nonatomic, strong) CSLazyLoadController *lazyLoadController;

	@end
```

### Create instance in your init 
```objective-c
	// I.e. initWithCoder
	- (id)initWithCoder:(NSCoder *)aDecoder {
    
    	if (self = [super initWithCoder:aDecoder]) {
        
        	self.lazyLoadController = [[CSLazyLoadController alloc] init];
        	self.lazyLoadController.delegate = self;
    	}
    	return self;
	}
```

### Set image when you dequeue cells 
```objective-c
	- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    	static NSString *cellIdentifier = @"CellIdentifier";
    	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    	cell.textLabel.text = [NSString stringWithFormat:@"Row: %ld", (long)indexPath.row];
    
    	NSString *stringUrl = self.items[indexPath.row]; // Some NSString instance holding url to the image.
    
    	UIImage *image = [self.lazyLoadController fastCacheImage:[CSURL URLWithString:stringUrl]]; // Find image in RAM memory.
    	cell.imageView.image = image; // Update the image in cell
    	// If there is not image download it
    	if (!image && !tableView.dragging) {
        	[self.lazyLoadController startDownload:[CSURL URLWithString:stringUrl parameters:[self parameters] method:CSHTTPMethodPOST]
                                	  forIndexPath:indexPath];
    	}
    
    return cell;
	}
```

### Respond to UIScrollViewDelegate
```objective-c
	// Once scrollView stops with scrolling we want to load images for visible rows
	- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    	if ([scrollView isEqual:_tableView] && !decelerate) {
        	[_lazyLoadController loadImagesForOnscreenRows:[_tableView indexPathsForVisibleRows]];
    	}
	}

	- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    	if ([scrollView isEqual:_tableView]){
        	[_lazyLoadController loadImagesForOnscreenRows:[_tableView indexPathsForVisibleRows]];
    	}
	}
```

### Respond to CSLazyLoadControllerDelegate
```objective-c
	// Controller asks us for URL so give him image URL
	- (CSURL *)lazyLoadController:(CSLazyLoadController *)loadController
       	urlForImageAtIndexPath:(NSIndexPath *)indexPath {
    
    	NSString *stringUrl = self.items[indexPath.row];
    	return [CSURL URLWithString:stringUrl];
	}
	
	// Image has finished with downloading so update the cell
	- (void)lazyLoadController:(CSLazyLoadController *)loadController
           	 	didReciveImage:(UIImage *)image
                   		fromURL:(CSURL *)url
                 		indexPath:(NSIndexPath *)indexPath {
    
    	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    	cell.imageView.image = image;
    	[cell setNeedsLayout];
	}
```