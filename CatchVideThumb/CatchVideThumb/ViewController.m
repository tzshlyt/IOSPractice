//
//  ViewController.m
//  CatchVideThumb
//
//  Created by lan on 16/6/14.
//  Copyright © 2016年 lan. All rights reserved.
//

#import "ViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
//#import <AVKit/AVKit.h>
#import <ImageIO/ImageIO.h>

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView1;

@property (weak, nonatomic) IBOutlet UIImageView *imageView2;

@property (weak, nonatomic) IBOutlet UIImageView *imageView3;



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _imageView1.contentMode = UIViewContentModeScaleAspectFit;
    _imageView2.contentMode = UIViewContentModeScaleAspectFit;
    _imageView3.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonClick:(id)sender {
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"jump" ofType:@"mp4"];
    
    MPMoviePlayerController *mvVC = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:path]];
    
    UIImage *img = [mvVC thumbnailImageAtTime:0.0 timeOption:MPMovieTimeOptionNearestKeyFrame];
    
    self.imageView1.image = img;
    
}


- (IBAction)avButtonClick:(id)sender {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"jump" ofType:@"mp4"];
    
    UIImage *img = [self getScreenShotImageFromVideoPath:path];
    self.imageView1.image = img;
    
    UIImage *img2 = [self generatePhotoThumbnail:img withSide:1024];
    self.imageView2.image = img2;

    UIImage *img3 = [self thumbnailWithImageWithoutScale:img size:CGSizeMake(1024, 1024)];
    self.imageView3.image = img3;
    
  
    [self save];
}

- (IBAction)photoThumButtonClick:(id)sender {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"jpg"];
    UIImage *img = [UIImage imageWithContentsOfFile:path];
    
    self.imageView1.image = img;
    
    UIImage *img2 = [self generatePhotoThumbnail:img withSide:1024];
    self.imageView2.image = img2;
    
    UIImage *img3 = [self thumbnailWithImageWithoutScale:img size:CGSizeMake(1024, 1024)];
    self.imageView3.image = img3;
    
    [self save];
}

- (void)save {
    
    NSArray *arry = [NSArray arrayWithObjects:self.imageView1.image, self.imageView2.image, self.imageView3.image, nil];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *pathStr = [paths objectAtIndex:0];
    for (int i = 0; i < 3; i++) {
        NSString *pngName = [NSString stringWithFormat:@"image_%d.png", i];
        NSString *jpegName = [NSString stringWithFormat:@"JPEGimage_%d.jpeg", i];
        NSString *pngFirePath = [pathStr stringByAppendingPathComponent:pngName];
        NSString *jpegFirePath = [pathStr stringByAppendingPathComponent:jpegName];
        BOOL result = [UIImagePNGRepresentation(arry[i]) writeToFile:pngFirePath atomically:YES];
        BOOL result1 = [UIImageJPEGRepresentation(arry[i], 1) writeToFile:jpegFirePath atomically:YES];
        
        NSLog(@"save state : %d  %d",result, result1);
    }
}

- (UIImage *)getScreenShotImageFromVideoPath:(NSString *)filePath{
    
    UIImage *shotImage;
    
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
   
    // 根据视频 URL 创建 AVURLAsset
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:fileURL options:nil];
    
    // 根据AVURLAsset 创建 AVAssetImageGenerator
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    gen.appliesPreferredTrackTransform = YES;
    
    //    
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    
    NSError *error = nil;
    
    CMTime actualTime;
    
    // 获取 time 处的视频截图
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    
    if (!error) {
         shotImage = [[UIImage alloc] initWithCGImage:image];
    }
    
    CGImageRelease(image);
    
    return shotImage;
}

// 缩放
- (UIImage *)generatePhotoThumbnail:(UIImage *)image withSide:(CGFloat)ratio
{
    // Create a thumbnail version of the image for the event object.
    CGSize size = image.size;
    CGSize croppedSize;
    
    CGFloat offsetX = 0.0;
    CGFloat offsetY = 0.0;
    
    // check the size of the image, we want to make it
    // a square with sides the size of the smallest dimension.
    // So clip the extra portion from x or y coordinate
    if (size.width > size.height) {
        offsetX = (size.height - size.width) / 2;
        croppedSize = CGSizeMake(size.height, size.height);
    } else {
        offsetY = (size.width - size.height) / 2;
        croppedSize = CGSizeMake(size.width, size.width);
    }
    
    // Crop the image before resize
    CGRect clippedRect = CGRectMake(offsetX * -1, offsetY * -1, croppedSize.width, croppedSize.height);
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], clippedRect);
    // Done cropping
    
    // Resize the image
    CGRect rect = CGRectMake(0.0, 0.0, ratio, ratio);
    
    UIGraphicsBeginImageContext(rect.size);
    [[UIImage imageWithCGImage:imageRef] drawInRect:rect];
    
    UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    // Done Resizing
    
    return thumbnail;
}

// 保持原比例缩放
- (UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)asize
{

    CGSize oldsize = image.size;
    CGRect rect;
    
    // 如果 宽 < 高
    if (asize.width/asize.height > oldsize.width/oldsize.height) {
        rect.size.width = asize.height*oldsize.width/oldsize.height;
        rect.size.height = asize.height;
        rect.origin.x = (asize.width - rect.size.width)/2;
        rect.origin.y = 0;
    }
    // 宽 > 高
    // 缩放后的宽 == 规定宽度
    //
    else{
        rect.size.width = asize.width;
        rect.size.height = asize.width*oldsize.height/oldsize.width;
        rect.origin.x = 0;
        rect.origin.y = (asize.height - rect.size.height)/2;
    }
    UIGraphicsBeginImageContext(asize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
    UIRectFill(CGRectMake(0, 0, asize.width, asize.height));//clear background
    [image drawInRect:rect];
    UIImage *newimage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newimage;
}


- (IBAction)clearButtonClick:(id)sender {
    self.imageView1.image = nil;
    self.imageView2.image = nil;
    self.imageView3.image = nil;
}


- (IBAction)writeEXIF:(id)sender {
    
//
//    NSMutableDictionary *metaData = [(__bridge NSDictionary*)CGImageSourceCopyPropertiesAtIndex(imageSource, 0,NULL) mutableCopy];
//
//    NSMutableDictionary *exifDic = [[NSMutableDictionary alloc] initWithDictionary:[metaData objectForKey:(NSString *)kCGImagePropertyExifDictionary]];
//    
//    
//    NSLog(@"ttt %@", myMetadate);
//    
//    
//    NSLog(@"exific %@",exifDic);
//    
//    NSLog(@"tiffDic %@", tiffDic);
//    
//    
//    
//    CFStringRef str1 = CFSTR("kamonMakeIt");
//    
//    CFStringRef str2 = CFSTR("fromPOCO");
//
//    [exifDic setObject:(__bridge id)(str1) forKey:(NSString *)kCGImagePropertyExifUserComment];
//    
//    [exifDic setObject:(__bridge id)(str2) forKey:(NSString *)kCGImagePropertyExifExposureProgram];
//    
//    //    [exifDic setValue:[NSString stringWithFormat:@"123"] forKey:(NSString*)kCGImagePropertyGPSImgDirectionRef];
//    
//    
//    
//    NSLog(@"%@",[exifDic valueForKey:(NSString *)kCGImagePropertyExifUserComment]);
//    
//    [metaData setObject:exifDic forKey:(NSString *)kCGImagePropertyExifDictionary];
//    
//    
//    
//    CFStringRef type = CGImageSourceGetType(imageSource);
//    
//    CGImageDestinationRef imageDestinationRef = CGImageDestinationCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"5" ofType:@"JPG"]], type, 1,nil);
//    
//    CGImageDestinationAddImageFromSource(imageDestinationRef, imageSource, 0, (__bridge CFDictionaryRef)(metaData));
//    
//    CGImageDestinationSetProperties(imageDestinationRef, (__bridge CFDictionaryRef)(metaData));
//    
//    CGImageDestinationFinalize(imageDestinationRef);
//    
//    
//    
//    NSLog(@"*****************************************************************************************************");
//    
//    
//    
//    CGImageSourceRef imageSource2 = CGImageSourceCreateWithData((__bridge CFDataRef)(data), NULL);
//    
//    NSMutableDictionary *metaData2 = (__bridge NSMutableDictionary*)CGImageSourceCopyPropertiesAtIndex(imageSource2, 0,NULL);
//    
//    NSMutableDictionary *exifDic2 = [[NSMutableDictionary alloc] initWithDictionary:[metaData2 objectForKey:(NSString *)kCGImagePropertyExifDictionary]];
//    
//    
//    NSString *dairy = [exifDic2 objectForKey:(NSString *)kCGImagePropertyExifExposureTime];
//    
//    
//    NSLog(@"%@",[exifDic2 valueForKey:(NSString *)kCGImagePropertyExifUserComment]);
//    
//    //    NSLog(@"%@",[exifDic2 valueForKey:(NSString*)kCGImagePropertyGPSImgDirectionRef]);
//    
//
//    
//    NSLog(@"%@",dairy);
//    
//    NSLog(@"%@",exifDic2);
    
    
    NSData *originalData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"test1" ofType:@"jpg"]]];
    NSMutableData *data = [NSMutableData dataWithData:originalData];
    
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)(data), NULL);
    CFStringRef type = CGImageSourceGetType(imageSource);
    

    NSMutableDictionary *exifDict = [NSMutableDictionary dictionary];
    [exifDict setObject:@"lanyutao" forKey:(__bridge NSString *)kCGImagePropertyExifUserComment];
    NSLog(@"exifDict --- %@", exifDict);
    CFDictionaryRef propDict0 = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, NULL);
    NSMutableDictionary *meteDict = [NSMutableDictionary dictionaryWithDictionary:(__bridge NSDictionary *)(propDict0)];
    [meteDict setObject:exifDict forKey:(__bridge NSString *)kCGImagePropertyExifDictionary];
    
    
    CGImageDestinationRef imgDest = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)(data), type, 0, NULL);
//    CGImageDestinationSetProperties(imgDest, (__bridge CFDictionaryRef) meteDict);
    CGImageDestinationAddImageFromSource(imgDest, imageSource, 0, (__bridge CFDictionaryRef) meteDict);
    CGImageDestinationFinalize(imgDest);
    
    NSLog(@"*_____________________________________________________________________*");
    
    NSData *reData = (NSData *)data;
    CGImageSourceRef resultImgSorce = CGImageSourceCreateWithData((__bridge CFDataRef)(reData), NULL);
    
    CFDictionaryRef rePropDict0 = CGImageSourceCopyPropertiesAtIndex(resultImgSorce, 0, NULL);
    NSDictionary *nsPropDict = (__bridge NSDictionary*)rePropDict0;
    NSDictionary *nsExifDict = [nsPropDict objectForKey:(__bridge NSString*)kCGImagePropertyExifDictionary];  // 获取 EXIF 信息
    NSLog(@"exifDict --- %@", nsExifDict);
    
}


- (IBAction)readExifButtonClick:(id)sender {
    //    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //    NSString *pathStr = [paths objectAtIndex:0];
    //    NSString *pngName = [NSString stringWithFormat:@"image_%d.png", 0];
    //    NSString *jpegName = [NSString stringWithFormat:@"JPEGimage_%d.jpeg", 0];
    //    NSString *pngFirePath = [pathStr stringByAppendingPathComponent:pngName];
    //    NSData *data = [NSData dataWithContentsOfFile:pngFirePath];
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"test1" ofType:@"jpg"]]];
    
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)(data), NULL);
    
    CFTypeID cfid = CGImageSourceGetTypeID(); // 获取图片源唯一标识
    NSLog(@"cfId ---- %lu", cfid);
    
    CFArrayRef array = CGImageSourceCopyTypeIdentifiers(); // 获取 Image I/O 支持的图片源格式标识
    NSLog(@"arrayRef --- %@", array);   //  CFShow(array);
   
    size_t count = CGImageSourceGetCount(imageSource);  // 获取包含图片数，比如gif格式图片包含多张图片
    NSLog(@"sourceCount --- %zu", count);
    
    CFDictionaryRef propDict =  CGImageSourceCopyProperties(imageSource, NULL);
    NSLog(@"propertiesDict --- %@", propDict);
    
    CFDictionaryRef propDict0 = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, NULL);
    NSLog(@"ProertiesDictAt0 --- %@", propDict0);
    
    NSDictionary *nsPropDict = (__bridge NSDictionary*)propDict0;
    NSDictionary *nsExifDict = [nsPropDict objectForKey:(__bridge NSString*)kCGImagePropertyExifDictionary];  // 获取 EXIF 信息
    NSLog(@"exifDict --- %@", nsExifDict);
    
    CGImageSourceStatus status = CGImageSourceGetStatus(imageSource);
    NSLog(@"status --- %d", status);
    
    CGImageSourceStatus status0 = CGImageSourceGetStatusAtIndex(imageSource, 0);
    NSLog(@"status0 --- %d", status0);
    
    // 注意最后应该 手动释放 cf 对象
}





@end
