//
//  ALAssetsLibrary+CustomVideoAlbum.m
//  CustomVideoAlbumDemo
//  Created by Renjith N on 23/12/14.


#import "ALAssetsLibrary+CustomVideoAlbum.h"

@implementation ALAssetsLibrary (CustomVideoAlbum)


- (void)saveVideoAtPath:(NSString*)videoPath toAlbum:(NSString*)albumName withCompletionBlock:(SaveVideoCompletion)completionBlock{
    //write the Video data to the assets library (camera roll)
    
    [self requestAccessToAssetsLibraryWithCompletionBlock:^(BOOL granted, NSError *error) {
        if(granted){
            [self writeVideoAtPathToSavedPhotosAlbum:[NSURL URLWithString:videoPath] completionBlock:^(NSURL *assetURL, NSError *error) {
                //error handling
                if (error!=nil) {
                    if(completionBlock)
                    completionBlock(error);
                    
                    return;
                }

                //add the asset to the custom Video album
                [self addAssetURL: assetURL
                          toAlbum:albumName
              withCompletionBlock:completionBlock];
                
            }];
        }
        else{
            if(completionBlock)
            completionBlock(error);
        }
    }];
    
}

- (void)addAssetURL:(NSURL*)assetURL toAlbum:(NSString*)albumName withCompletionBlock:(SaveVideoCompletion)completionBlock{
    __block BOOL albumWasFound = NO;
    
    //search all Video albums in the library
    [self enumerateGroupsWithTypes:ALAssetsGroupAlbum
                        usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                            
                            //compare the names of the albums
                            if ([albumName compare: [group valueForProperty:ALAssetsGroupPropertyName]]== NSOrderedSame) {
                                
                                //target album is found
                                albumWasFound = YES;
                                
                                //get a hold of the Video's asset instance
                                [self assetForURL: assetURL
                                      resultBlock:^(ALAsset *asset) {
                                          
                                          //add Video to the target album
                                          [group addAsset: asset];
                                          
                                          if(completionBlock)
                                          completionBlock(nil);
                                          
                                      } failureBlock: completionBlock];
                                
                                //album was found, bail out of the method
                                return;
                            }
                            
                            if (group == nil && albumWasFound==NO) {
                                //Video albums are over, target album does not exist, thus create it
                                
                                __weak ALAssetsLibrary* weakSelf = self;
                                
                                //create new assets album
                                [self addAssetsGroupAlbumWithName:albumName
                                                      resultBlock:^(ALAssetsGroup *group) {
                                                          
                                                          //get the Video's instance
                                                          [weakSelf assetForURL: assetURL
                                                                    resultBlock:^(ALAsset *asset) {
                                                                        
                                                                        //add Video to the newly created album
                                                                        [group addAsset: asset];
                                                                        
                                                                        //call the completion block
                                                                        completionBlock(nil);
                                                                        
                                                                    } failureBlock: completionBlock];
                                                          
                                                      } failureBlock: completionBlock];
                                
                                //should be the last iteration anyway, but just in case
                                return;
                            }
                            
                        } failureBlock: completionBlock];
    
}

- (void) requestAccessToAssetsLibraryWithCompletionBlock:(void(^)(BOOL granted, NSError *error))block
{
    void(^callBlock)(BOOL granted, NSError *error) = ^(BOOL granted, NSError *error) {
        if (block) {
            block(granted, error);
        }
    };
    
    if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusAuthorized) {
        callBlock(YES, nil);
        return;
    }
    
    
    [self enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        /// avoid duplication call
        if (group || !*stop) {
            *stop = YES;
            callBlock(YES, nil);
        }
    } failureBlock:^(NSError *error) {
        callBlock(NO, error);
    }];
}
@end
