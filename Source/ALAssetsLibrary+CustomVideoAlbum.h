//
//  ALAssetsLibrary+CustomVideoAlbum.h
//  CustomPhotoAlbumDemo
//  Created by Renjith N on 23/12/14.


#import <AssetsLibrary/AssetsLibrary.h>
typedef void(^SaveVideoCompletion)(NSError* error);

@interface ALAssetsLibrary (CustomVideoAlbum)

- (void)saveVideoAtPath:(NSString*)videoPath toAlbum:(NSString*)albumName withCompletionBlock:(SaveVideoCompletion)completionBlock;
- (void)addAssetURL:(NSURL*)assetURL toAlbum:(NSString*)albumName withCompletionBlock:(SaveVideoCompletion)completionBlock;

- (void) requestAccessToAssetsLibraryWithCompletionBlock:(void(^)(BOOL granted, NSError *error))block;

@end
