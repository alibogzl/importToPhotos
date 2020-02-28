//
//  ViewController.m
//  test
//
//  Created by Alina Boguslavskaya on 27.02.2020.
//  Copyright © 2020 Alina Boguslavskaya. All rights reserved.
//

#import "ViewController.h"
#import "PhotoExporter.h"
#import <Photos/Photos.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *imgInFolderLabel;
@property (weak, nonatomic) IBOutlet UILabel *imgExportedLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@end

@implementation ViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *testString = @"test";
    NSURL* url = [self fullPathToFile:@"testFile.txt"];
    [testString writeToURL:url atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    _imgInFolderLabel.text = [NSString stringWithFormat: @"%i", (int)[self amountOfImagesInFolder]];
}

#pragma mark - Actions

- (IBAction)exportPressed:(id)sender {
    NSInteger* totalAmountImg = [self amountOfImagesInFolder];
    NSURL* pathToFolder = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    PhotoExporter *photoExporter = [[PhotoExporter alloc] initWithUrl:pathToFolder];
    [photoExporter checkExportedPhotos:^(BOOL success, NSError * _Nonnull error, NSInteger amountAllPhotos, NSInteger amountExportedPhotos) {
        if ( success ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self->_imgInFolderLabel.text = [NSString stringWithFormat: @"%li", (long)amountAllPhotos];
                self->_imgExportedLabel.text = [NSString stringWithFormat: @"%li", (long)amountExportedPhotos];
                [self.progressView setProgress:( (float)amountExportedPhotos / (int)totalAmountImg)];
            });
        } else {
            NSLog( @"Could not save Image to photo library: %@", error );
        }
    }];
}

- (NSInteger *)amountOfImagesInFolder
{
    NSError *error = nil;
    NSInteger totalCount = 0;
    NSURL* pathToFolder = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];

    NSArray *desktopFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:pathToFolder error:&error];
    for(id filename in desktopFiles)
    {
        CFStringRef fileExtension = (CFStringRef) CFBridgingRetain([[self fullPathToFile:filename] pathExtension]);
        CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
        if (UTTypeConformsTo(fileUTI, kUTTypeImage)) {
            totalCount++;
        }
    }
    return totalCount;
}

- (NSURL *)fullPathToFile:(NSString *)lastComponent
{
    return [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:lastComponent];
}

@end
