//
//  CommonMethod.h
//  TranscribeVideo
//
//  Created by 中商国际 on 2018/1/30.
//  Copyright © 2018年 中商国际. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface CommonMethod : NSObject

+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)getThumbnailImage:(NSURL *)videoURL;
+ (CGFloat) getFileSize:(NSString *)path;
+ (CGFloat) getVideoLength:(NSURL *)URL;
@end
