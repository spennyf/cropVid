//
//  ImageViewController.m
//  Igloo
//
//  Created by Spencer Fontein on 4/2/15.
//  Copyright (c) 2015 Spencer Fontein. All rights reserved.
//

#import "ImageViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ImageViewController () 


@end

@implementation ImageViewController
@synthesize myImage, select;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    _imageView.image = myImage;
    
    select.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    select.layer.cornerRadius = 10.0f;
    select.clipsToBounds = YES;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 115, 115)];
    UIImageView *image = [[UIImageView alloc] init];
    image.layer.borderColor=[[UIColor whiteColor] CGColor];
    
    image.frame = CGRectMake(125, 365, 115, 115);
    CALayer *imageLayer = image.layer;
    [imageLayer setBorderWidth:1];
    [imageLayer setMasksToBounds:YES];
    [image.layer setCornerRadius:image.frame.size.width/2];
//    NSLog(@"%f", image.frame.size.width/2);
    
    self.moveView.layer.cornerRadius = 115/2;
    self.moveView.userInteractionEnabled = NO;
    
    [view addSubview:image];
    [self.view addSubview:view];



}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)record:(id)sender {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        picker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
        
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        CGPoint point = CGPointMake(0, 50);
        CGFloat radius = 15.0;
//        CGFloat lineLength = 25.0;
        
        [path moveToPoint:point];
        point.x += radius;
        [path addArcWithCenter:point radius:radius startAngle:M_PI endAngle:M_PI * 2 clockwise:NO];

        
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.path = [path CGPath];
        layer.lineWidth = 2.0;
        layer.fillColor = [[UIColor clearColor] CGColor];
        layer.strokeColor = [[UIColor blackColor] CGColor];
        
//        [self.view.layer addSublayer:layer];
//        [picker.view.layer addSublayer:layer];
        

        
        
        /*
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(context, 2);
        CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
        CGContextMoveToPoint(context, 10, 500);
        CGContextAddArc(context, 60, 500, 50, M_PI / 2, M_PI, 0);
        CGContextStrokePath(context);
        */
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-80)];
        UIImageView *image = [[UIImageView alloc] init];
        image.layer.borderColor=[[UIColor whiteColor] CGColor];
//        image.frame = CGRectMake(self.view.frame.size.width / 2 - 57.5 , self.view.frame.size.height / 2 - 57.5 , 115, 115);
        image.frame = CGRectMake(self.view.frame.size.width/2 - 58 , 00 , 116, 116);
        CALayer *imageLayer = image.layer;
        [imageLayer setBorderWidth:1];
        [imageLayer setMasksToBounds:YES];
//        [image.layer setCornerRadius:image.frame.size.width/2];
        
        [view addSubview:image];
        [picker setCameraOverlayView:view];
         

        [self presentViewController:picker animated:YES completion:NULL];
    }
    else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
        
        
        [self presentViewController:picker animated:YES completion:NULL];
    }

}

- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer {
    
    CGPoint translation = [recognizer translationInView:self.view];
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x, recognizer.view.center.y + translation.y);
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    
    self.videoURL = info[UIImagePickerControllerMediaURL];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    

    
    AVAsset *assest = [AVAsset assetWithURL:self.videoURL];
    
    
    
    
    NSString * documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *exportPath = [documentsPath stringByAppendingFormat:@"/croppedvideo1.mp4"];
    NSURL *exportUrl = [NSURL fileURLWithPath:exportPath];

//    NSLog(@"%@", exportPath);
    
    AVAssetExportSession *exporter = [AVAssetExportSession exportSessionWithAsset:assest presetName:AVAssetExportPresetLowQuality];
    
//    NSInteger x = roundf(self.view.frame.size.width/2 - 57.5 - 5);
//    NSInteger y = roundf(self.view.frame.size.height / 2 - 140);
    
//    CGRect rect = CGRectMake(x, y, 116, 86);
//    CGRect rect = CGRectMake(self.view.frame.size.width/2 - 58, 0, 115, 115);
    CGRect rect = CGRectMake(self.view.frame.size.width/2 - 58, 00, 116, 116);

    
    [self applyCropToVideoWithAsset:assest AtRect:rect OnTimeRange:CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(assest.duration.value, 1))
                        ExportToUrl:exportUrl ExistingExportSession:exporter WithCompletion:^(BOOL success, NSError *error, NSURL *videoUrl) {

                            if (success) {
                                
     
//                                self.videoController = [[MPMoviePlayerController alloc] init];
//                                
//                                [self.videoController setContentURL:videoUrl];
//                                [self.videoController.view setFrame:CGRectMake (0, 0, self.view.frame.size.width, 460)];
//                                [self.view addSubview:self.videoController.view];
//                                
//                                [[NSNotificationCenter defaultCenter] addObserver:self
//                                                                         selector:@selector(videoPlayBackDidFinish:)
//                                                                             name:MPMoviePlayerPlaybackDidFinishNotification
//                                                                           object:self.videoController];
//                                [self.videoController play];
                                
                                
                                UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 400, 400)];
                                NSLog(@"SUCCESS");
                                AVPlayer *player = [AVPlayer playerWithURL:videoUrl];
                                
                                AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:player];
//                                layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
                                layer.videoGravity = AVLayerVideoGravityResize;
//                                layer.frame = CGRectMake(self.view.frame.size.width / 2 - 57.5, self.view.frame.size.height / 2 - 57.5, 115, 85);
//                                layer.frame = CGRectMake(125, 365, 115, 115);
//                                layer.frame = CGRectMake(self.view.frame.size.width/2 - 58, 100, 116, 116);
                                layer.frame = CGRectMake(0, 0, 116, 116);
//                                layer.frame = CGRectMake(0, 0, self.view.frame.size.width, 460);
                                
//                                layer.cornerRadius = 115/2;
                                layer.masksToBounds = YES;
                                [view.layer addSublayer:layer];
                                self.moveView.userInteractionEnabled = YES;
                                // Put the AVPlayerLayer on top of the image view.
                                [self.moveView addSubview:view];
//                                [self.view.layer addSublayer:layer];
                                
//                                [player play];
                                
                                [captureView performSelector:@selector(startRecording) withObject:nil afterDelay:1.0];
                                [captureView performSelector:@selector(stopRecording) withObject:nil afterDelay:5.0];
                                
                                
                            }
                            else {
                                NSLog(@"NOO GOOD");
                            }
                            
                            
                        
                        }];
    
    
    /*
    NSLog(@"new: %@", exportUrl);
    
    AVPlayer *player = [AVPlayer playerWithURL:exportUrl];
    
    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:player];
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    layer.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.width);
    
//    layer.cornerRadius = diameter/2;
    layer.masksToBounds = YES;
    
    // Put the AVPlayerLayer on top of the image view.
    [self.view.layer addSublayer:layer];
    
    [player play];
     */
    
    
    /*
    AVPlayer *player = [AVPlayer playerWithURL:exportUrl];
    
    CGFloat diameter = 115;
    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:player];
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    layer.frame = CGRectMake(125, 365, diameter, diameter);
    
    layer.cornerRadius = diameter/2;
    layer.masksToBounds = YES;
    
    // Put the AVPlayerLayer on top of the image view.
    [self.view.layer addSublayer:layer];
    
    [player play];
    
*/
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoPlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:self.videoController];
    
//    [self.videoController play];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)videoPlayBackDidFinish:(NSNotification *)notification {
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];


}


- (UIImageOrientation)getVideoOrientationFromAsset:(AVAsset *)asset
{
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    CGSize size = [videoTrack naturalSize];
    CGAffineTransform txf = [videoTrack preferredTransform];
    
    if (size.width == txf.tx && size.height == txf.ty)
        return UIImageOrientationLeft; //return UIInterfaceOrientationLandscapeLeft;
    else if (txf.tx == 0 && txf.ty == 0)
        return UIImageOrientationRight; //return UIInterfaceOrientationLandscapeRight;
    else if (txf.tx == 0 && txf.ty == size.width)
        return UIImageOrientationDown; //return UIInterfaceOrientationPortraitUpsideDown;
    else
        return UIImageOrientationUp;  //return UIInterfaceOrientationPortrait;
}


- (AVAssetExportSession*)applyCropToVideoWithAsset:(AVAsset*)asset AtRect:(CGRect)cropRect OnTimeRange:(CMTimeRange)cropTimeRange ExportToUrl:(NSURL*)outputUrl ExistingExportSession:(AVAssetExportSession*)exporter WithCompletion:(void(^)(BOOL success, NSError* error, NSURL* videoUrl))completion
{
    
//    NSLog(@"CALLED");
    //create an avassetrack with our asset
    AVAssetTrack *clipVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    
    //create a video composition and preset some settings
    AVMutableVideoComposition* videoComposition = [AVMutableVideoComposition videoComposition];
    videoComposition.frameDuration = CMTimeMake(1, 30);
    
    CGFloat cropOffX = cropRect.origin.x;
    CGFloat cropOffY = cropRect.origin.y;
    CGFloat cropWidth = cropRect.size.width;
    CGFloat cropHeight = cropRect.size.height;
//    NSLog(@"width: %f - height: %f - x: %f - y: %f", cropWidth, cropHeight, cropOffX, cropOffY);
    
    videoComposition.renderSize = CGSizeMake(cropWidth, cropHeight);
    
    //create a video instruction
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = cropTimeRange;
    
    AVMutableVideoCompositionLayerInstruction* transformer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:clipVideoTrack];
    
    UIImageOrientation videoOrientation = [self getVideoOrientationFromAsset:asset];
    
    CGAffineTransform t1 = CGAffineTransformIdentity;
    CGAffineTransform t2 = CGAffineTransformIdentity;
    
    switch (videoOrientation) {
        case UIImageOrientationUp:
//            NSLog(@"UP ORIENTATION");
//            NSLog(@"nat height: %f", clipVideoTrack.naturalSize.height);
//            NSLog(@"x tans: %f", clipVideoTrack.naturalSize.height - cropOffX);
//            NSLog(@"y tans: %f", 0 - cropOffY);
            t1 = CGAffineTransformMakeTranslation(clipVideoTrack.naturalSize.height - cropOffX, 0 - cropOffY );
            t2 = CGAffineTransformRotate(t1, M_PI_2 );
            break;
        case UIImageOrientationDown:
            t1 = CGAffineTransformMakeTranslation(0 - cropOffX, clipVideoTrack.naturalSize.width - cropOffY ); // not fixed width is the real height in upside down
            t2 = CGAffineTransformRotate(t1, - M_PI_2 );
            break;
        case UIImageOrientationRight:
            t1 = CGAffineTransformMakeTranslation(0 - cropOffX, 0 - cropOffY );
            t2 = CGAffineTransformRotate(t1, 0 );
            break;
        case UIImageOrientationLeft:
            t1 = CGAffineTransformMakeTranslation(clipVideoTrack.naturalSize.width - cropOffX, clipVideoTrack.naturalSize.height - cropOffY );
            t2 = CGAffineTransformRotate(t1, M_PI  );
            break;
        default:
            NSLog(@"no supported orientation has been found in this video");
            break;
    }
    
    CGAffineTransform finalTransform = t2;
    [transformer setTransform:finalTransform atTime:kCMTimeZero];
    
    //add the transformer layer instructions, then add to video composition
    instruction.layerInstructions = [NSArray arrayWithObject:transformer];
    videoComposition.instructions = [NSArray arrayWithObject: instruction];
    
    //Remove any prevouis videos at that path
    [[NSFileManager defaultManager]  removeItemAtURL:outputUrl error:nil];
    
    if (!exporter){
        exporter = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetHighestQuality] ;
    }
    // assign all instruction for the video processing (in this case the transformation for cropping the video
    exporter.videoComposition = videoComposition;
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    if (outputUrl){
        exporter.outputURL = outputUrl;
        [exporter exportAsynchronouslyWithCompletionHandler:^{
            switch ([exporter status]) {
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"crop Export failed: %@", [[exporter error] localizedDescription]);
                    if (completion){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completion(NO,[exporter error],nil);
                        });
                        return;
                    }
                    break;
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"crop Export canceled");
                    if (completion){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completion(NO,nil,nil);
                        });
                        return;
                    }
                    break;
                default:
                    break;
            }
            if (completion){
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(YES,nil,outputUrl);
                });
            }
            
        }];
    }
    
    return exporter;
}








@end
