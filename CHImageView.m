//
//  CHImageView.m
//  003-cocoapod演练
//
//  Created by CrazyHacker on 16/6/9.
//  Copyright © 2016年 itcast. All rights reserved.
//

#import "CHImageView.h"
#import <UIImageView+WebCache.h>
#import <SDWebImageManager.h>
#import <NSData+ImageContentType.h>
#import <ImageIO/ImageIO.h>

/**
 思路：用 CPU 换内存
 
 1> 建立一个 定时器
 2> 定义两个成员变量
 - 记录下载的 NSData
 - 记录当前播放的帧数
 3> 每次定时器触发的时候，播放下一帧
 */
@interface CHImageView()
/**
 * 定时器
 */
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation CHImageView {
    /**
     * GIF 的二进制数据
     */
    NSData *_gifData;
    /**
     * 当前播放的帧数
     */
    NSInteger _currentIndex;
}

/**
 * 定时器的懒加载
 * - 不好确定开发是 IB ／ 纯代码
 */
- (NSTimer *)timer {
    if (_timer == nil) {
        _timer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];
        
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    return _timer;
}

/**
 * 时钟触发方法
 */
- (void)updateTimer {
    // 设置 _currentIndex 对应的图像
    self.image = [self ch_animatedGIFWithData:_gifData];
}

- (void)ch_setImageWithURL:(NSURL *)url {
    
    //[self sd_setImageWithURL:url];
    // 1. 使用 sd 的下载图像方法，先下载二进制数据
    [[SDWebImageManager sharedManager].imageDownloader downloadImageWithURL:url options:0 progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
        
        // 下载的完成回调在异步
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // 判断 data 是否是 gif
            if ([[NSData sd_contentTypeForImageData:data] isEqualToString:@"image/gif"]) {
                NSLog(@"是 gif");
                
                // 1> 设置成员变量
                _currentIndex = 0;
                // 2> gif 数据
                _gifData = data;
                
                // 启动时钟
                self.timer.fireDate = [NSDate dateWithTimeIntervalSinceNow:0.1];
                
                return;
            }
            
            // 清空 gif 数据
            _gifData = nil;
            // 暂停时钟 - 触发时间设置到非常远
            self.timer.fireDate = [NSDate distantFuture];
            
            // 下载完成设置图像
            self.image = image;
        });
    }];
}

/**
 * 播放 GIF
 */
- (UIImage *)ch_animatedGIFWithData:(NSData *)data {
    
    // 1. 判断数据是否为 nil，如果 nil，直接 return
    if (!data) {
        return nil;
    }
    
    // 2. 创建一个 CGImageRef
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    
    // 3. 读取图片的帧数
    size_t count = CGImageSourceGetCount(source);
    
    // 4. 定义一个图像
    UIImage *animatedImage;
    
    // 5. 判断张数
    if (count <= 1) {
        // 创建图像并且返回
        animatedImage = [[UIImage alloc] initWithData:data];
    }
    else {
        
        // 1> 创建帧数对应 的 CG 图像
        CGImageRef image = CGImageSourceCreateImageAtIndex(source, _currentIndex, NULL);
        
        // 2> 更新帧数
        _currentIndex = (_currentIndex + 1) % count;
        
        // 3> 定义临时 uiimage
        /**
         参数
         CGImage
         屏幕分辨率
         图像方向
         */
        animatedImage = [UIImage imageWithCGImage:image scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
        
        // 4> 是否 CGImage
        CGImageRelease(image);
    }
    
    CFRelease(source);
    
    return animatedImage;
}
@end
