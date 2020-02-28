//
//  PhotoExporter.h
//  test
//
//  Created by Alina Boguslavskaya on 27.02.2020.
//  Copyright © 2020 Alina Boguslavskaya. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PhotoExporter : NSObject

/**
 description of param
 
 @param url is a ;location ...
 */
- (id)initWithUrl:(NSURL *)url;
- (void)checkExportedPhotos:(void (^)(BOOL success, NSError* error, NSInteger amountAllPhotos, NSInteger amountExportedPhotos))block;

@end

NS_ASSUME_NONNULL_END
