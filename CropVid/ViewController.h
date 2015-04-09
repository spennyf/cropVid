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

@interface ViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) NSURL *videoURL;


@end

