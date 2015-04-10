//
//  ImageViewController.h
//  Igloo
//
//  Created by Spencer Fontein on 4/2/15.
//  Copyright (c) 2015 Spencer Fontein. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "ScreenCaptureView.h"

@interface ImageViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    
    IBOutlet ScreenCaptureView *captureView;
}

@property (strong, nonatomic) UIImage *myImage;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIButton *select;

@property (strong, nonatomic) NSURL *videoURL;
@property (strong, nonatomic) NSURL *otherVideoURL;
@property (strong, nonatomic) MPMoviePlayerController *videoController;

- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer;

@property (strong, nonatomic) IBOutlet UIView *moveView;





@end
