//
//  PhotoExporter.m
//  test
//
//  Created by Alina Boguslavskaya on 27.02.2020.
//  Copyright © 2020 Alina Boguslavskaya. All rights reserved.
//

#import "PhotoExporter.h"
#import <Photos/Photos.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface PhotoExporter ()

@property (strong, nonatomic) NSURL *url;

@end

@implementation PhotoExporter

- (id)initWithUrl:(NSURL *)url
{
    self = [super init];
    if (self) {
        self.url = url;
    }
    return self;
}

- (void)checkExportedPhotos:(void (^)(BOOL success, NSError* error, NSInteger amountAllPhotos, NSInteger amountExportedPhotos))block
{
    NSError *error = nil;
    NSURL* pathToFolder = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSArray *desktopFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:pathToFolder error:&error];
    NSInteger *totalAmountImg = [self amountOfImagesInFolder];
    __block NSInteger exportedCount = 0;
    
    for (NSString* filename in desktopFiles) {
        CFStringRef fileExtension = (CFStringRef) CFBridgingRetain([[self fullPathToPhoto:filename] pathExtension]);
        CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
        [PHPhotoLibrary requestAuthorization:^( PHAuthorizationStatus status ) {
            if ( status == PHAuthorizationStatusAuthorized ) {
                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    if ( [PHAssetResourceCreationOptions class] ) {
                        PHAssetResourceCreationOptions *options = [[PHAssetResourceCreationOptions alloc] init];
                        options.shouldMoveFile = YES;
                        PHAssetCreationRequest *changeRequest = [PHAssetCreationRequest creationRequestForAsset];
                        [changeRequest addResourceWithType:PHAssetResourceTypePhoto fileURL: [self fullPathToPhoto:filename] options:options];
                    }
                } completionHandler:^( BOOL success, NSError *error ) {
                    if ( success ) {
                        exportedCount++;
                        block(success, error, [self amountOfImagesInFolder], exportedCount);
                        NSLog( @"Successfully saved" );
                    } else {
                        block(success, error, [self amountOfImagesInFolder], exportedCount);
                        NSLog( @"Could not save Image to photo library: %@", error );
                    }
                }];
            }
            else {
            }
        }];
    }
}

- (NSURL *)fullPathToPhoto:(NSString *)lastComponent
{
    NSURL *originalURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *aaNextURL = [originalURL URLByAppendingPathComponent:lastComponent];
    return aaNextURL;
}

- (NSInteger *)amountOfImagesInFolder
{
    NSError *error = nil;
    NSInteger totalCount = 0;
    NSURL* pathToFolder = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];

    NSArray *desktopFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:pathToFolder error:&error];
    for(id filename in desktopFiles)
    {
        CFStringRef fileExtension = (CFStringRef) CFBridgingRetain([[self fullPathToPhoto:filename] pathExtension]);
        CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
        if (UTTypeConformsTo(fileUTI, kUTTypeImage)) {
            totalCount++;
        }
    }
    return totalCount;
}

@end
