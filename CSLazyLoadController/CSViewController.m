//
//  CSViewController.m
//  CSLazyLoadController
//
//  Created by Josip Bernat on 25/04/14.
//  Copyright (c) 2014 Clover-Studio. All rights reserved.
//

#import "CSViewController.h"
#import "CSLazyLoadController.h"

@interface CSViewController () <CSLazyLoadControllerDelegate>

@property (nonatomic, strong) CSLazyLoadController *lazyLoadController;

@property (nonatomic, strong) NSArray *items;

@end

@implementation CSViewController

#pragma mark - Memory Management

- (void)dealloc {
    self.lazyLoadController.delegate = nil;
}

#pragma mark - Initialization

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    if (self = [super initWithCoder:aDecoder]) {
        
        self.lazyLoadController = [[CSLazyLoadController alloc] init];
        self.lazyLoadController.delegate = self;
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.items = @[@"http://a1282.phobos.apple.com/us/r30/Music6/v4/88/6a/f3/886af3d0-b9e4-5a1d-0261-56a1aeffe6e9/itunes.55x55-70.jpg",
                   @"http://a1029.phobos.apple.com/us/r30/Music/v4/35/95/8a/35958a0f-a433-500b-8e35-060209114f11/cover.60x60-50.jpg",
                   @"http://a3.mzstatic.com/us/r30/Features/b1/97/df/dj.ltnajmvk.60x60-50.jpg",
                   @"http://a1074.phobos.apple.com/us/r30/Music4/v4/ae/9b/9f/ae9b9f44-5cff-dde3-40d2-7fdd30c5aa97/itunes.60x60-50.jpg",
                   @"http://a1602.phobos.apple.com/us/r30/Music/v4/3a/bd/36/3abd3654-229d-4680-c345-7fe95392bcd7/cover.60x60-50.jpg",
                   @"http://a1853.phobos.apple.com/us/r30/Music4/v4/6c/66/53/6c665307-3e05-8bda-72fe-2454e77b34a4/itunes.60x60-50.jpg",
                   @"http://a595.phobos.apple.com/us/r30/Music/28/e2/b1/mzi.xbbqkgbn.60x60-50.jpg",
                   @"http://a107.phobos.apple.com/us/r30/Music/ac/3e/30/mzi.ihhqvuls.60x60-50.jpg",
                   @"http://a520.phobos.apple.com/us/r30/Music6/v4/f4/aa/28/f4aa28b0-aaec-58f8-0c97-6e943cf4f633/itunes.60x60-50.jpg",
                   @"http://a169.phobos.apple.com/us/r30/Music4/v4/77/99/4f/77994ffd-d0c9-01dd-fc0f-57ee0329067f/itunes.60x60-50.jpg",
                   @"http://a1666.phobos.apple.com/us/r30/Music/v4/54/3e/0d/543e0dcc-fa06-6f5f-f351-cd815e83676e/UMG_cvrart_00050087301637_01_RGB72_1500x1500_13DMGIM04437.60x60-50.jpg",
                   @"http://a283.phobos.apple.com/us/r30/Music/v4/8f/d9/70/8fd9703e-0c58-4648-4f6c-ac70c388642c/886444314022.60x60-50.jpg",
                   @"http://a1447.phobos.apple.com/us/r30/Music4/v4/7f/43/10/7f4310d4-61b9-83a8-d178-da90ceea6d2e/075679946706.60x60-50.jpg",
                   @"http://a1494.phobos.apple.com/us/r30/Music6/v4/9d/16/6a/9d166a68-8831-191e-2580-93cc148cc409/UMG_cvrart_00602537477357_01_RGB72_1500x1500_13UAAIM41955.60x60-50.jpg",
                   @"http://a1259.phobos.apple.com/us/r30/Music/v4/04/15/78/04157815-169d-9f91-d596-342dee2f4c46/UMG_cvrart_00602537150120_01_RGB72_1200x1200_12UMGIM46901.60x60-50.jpg",
                   @"http://a1462.phobos.apple.com/us/r30/Music4/v4/c3/76/61/c37661b6-6c2e-85ce-4dda-b8b30bb28dff/UMG_cvrart_00602537518982_01_RGB72_1500x1500_13UAAIM68691.60x60-50.jpg",
                   @"http://a321.phobos.apple.com/us/r30/Music/v4/67/c8/b5/67c8b57c-12ae-47ef-285e-efc887c1434c/Cover.60x60-50.jpg",
                   @"http://a1983.phobos.apple.com/us/r30/Music/v4/c9/af/58/c9af5813-7975-3644-d873-14983f05f767/075679948748.60x60-50.jpg",
                   @"http://a1153.phobos.apple.com/us/r30/Music4/v4/43/db/88/43db8879-4a63-c87d-a7b4-864493997cc2/UMG_cvrart_00602537654598_01_RGB72_1500x1500_13UAEIM30321.60x60-50.jpg",
                   @"http://a731.phobos.apple.com/us/r30/Features4/v4/f7/3e/40/f73e4011-5ed3-fc65-9107-2438acd70509/dj.hbxrueel.60x60-50.jpg",
                   ];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"Row: %ld", (long)indexPath.row];
    
    NSString *stringUrl = self.items[indexPath.row];
    
    UIImage *image = [self.lazyLoadController fastCacheImage:[CSURL URLWithString:stringUrl]];
    cell.imageView.image = image;
    if (!image && !tableView.dragging) {
        [self.lazyLoadController startDownload:[CSURL URLWithString:stringUrl parameters:[self parameters] method:CSHTTPMethodPOST]
                                  forIndexPath:indexPath];
    }
    
    return cell;
}

- (NSDictionary *)parameters {
    return @{@"fileItemId": @"177",
             @"token": @"66f97896-0a67-4a92-ad22-740a4994e10f"};
}

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

#pragma mark - CSLazyLoadControllerDelegate

- (CSURL *)lazyLoadController:(CSLazyLoadController *)loadController
       urlForImageAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *stringUrl = self.items[indexPath.row];
    return [CSURL URLWithString:stringUrl];
}

- (void)lazyLoadController:(CSLazyLoadController *)loadController
            didReciveImage:(UIImage *)image
                   fromURL:(CSURL *)url
                 indexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.imageView.image = image;
    [cell setNeedsLayout];
}


@end
