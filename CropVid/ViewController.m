//
//  ViewController.m
//  CropVid
//
//  Created by Spencer Fontein on 4/9/15.
//  Copyright (c) 2015 Spencer Fontein. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}
- (IBAction)record:(id)sender {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        picker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
        
        
        UIImageView *image = [[UIImageView alloc] init];
        image.layer.borderColor=[[UIColor whiteColor] CGColor];
        image.frame = CGRectMake(self.view.frame.size.width/2 - 58 , 400 , 116, 116);
        CALayer *imageLayer = image.layer;
        [imageLayer setBorderWidth:1];
        [imageLayer setMasksToBounds:YES];
        [picker setCameraOverlayView:image];
        
        [self presentViewController:picker animated:YES completion:NULL];
        
    }
    
}



- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {


    self.videoURL = info[UIImagePickerControllerMediaURL];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    AVAsset *assest = [AVAsset assetWithURL:self.videoURL];

    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *exportPath = [documentsPath stringByAppendingFormat:@"/croppedvideo1.mp4"];
    NSURL *exportUrl = [NSURL fileURLWithPath:exportPath];

    AVAssetExportSession *exporter = [AVAssetExportSession exportSessionWithAsset:assest presetName:AVAssetExportPresetLowQuality];
    
    CGRect rect = CGRectMake(self.view.frame.size.width/2 - 58, 400, 116, 116);
    
    //call the crop
    [self applyCropToVideoWithAsset:assest AtRect:rect OnTimeRange:CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(assest.duration.value, 1))
                        ExportToUrl:exportUrl ExistingExportSession:exporter WithCompletion:^(BOOL success, NSError *error, NSURL *videoUrl) {
                            
                            if (success) {
                                NSLog(@"IT WORKED");
                                
                                AVPlayer *player = [AVPlayer playerWithURL:videoUrl];
                                AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:player];
                                layer.videoGravity = AVLayerVideoGravityResize;
                                 layer.frame = CGRectMake(self.view.frame.size.width/2 - 58 , 400, 116, 116);
                                [self.view.layer addSublayer:layer];
                                [player play];

                            }
                            else {
                                NSLog(@"IF FAILED");
                            }
                            
                        }];



}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
