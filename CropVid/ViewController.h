//
//  ViewController.h
//  CropVid
//
//  Created by Spencer Fontein on 4/9/15.
//  Copyright (c) 2015 Spencer Fontein. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "ScreenCaptureView.h"

@interface ViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    
    IBOutlet ScreenCaptureView *captureView;
}

@property (strong, nonatomic) NSURL *videoURL;


@end

