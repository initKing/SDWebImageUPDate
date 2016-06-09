//
//  CHImageView.h
//  003-cocoapod演练
//
//  Created by CrazyHacker on 16/6/9.
//  Copyright © 2016年 itcast. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CHImageView : UIImageView
/**
 * 用于替带 sd_setImageWithURL 方法
 */
- (void)ch_setImageWithURL:(NSURL *)url;@end
