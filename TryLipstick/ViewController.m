//
//  ViewController.m
//  TryLipstick
//
//  Created by Евгения Тверитинова on 27.11.16.
//  Copyright © 2016 Евгения Тверитинова. All rights reserved.
//

@import AVFoundation;

#import "ViewController.h"

@interface ViewController ()

@property(nonatomic, weak) IBOutlet UIView *placeHolder;
@property(nonatomic, weak) IBOutlet UIView *overlay;
@property(nonatomic, weak) IBOutlet UISwitch *cameraSwitch;

@property(nonatomic, strong) AVCaptureSession *session;
@property(nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Set up default camera settings.
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPresetMedium;
    self.cameraSwitch.on = NO;
    [self updateCameraSelection];
    
    
    //Output
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
    [self.session addOutput:output];
    output.videoSettings =
    @{ (NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA) };
    
    //Preview Layer
    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    UIView *myView = self.view;
    previewLayer.frame = myView.bounds;
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [[self.placeHolder layer] addSublayer:previewLayer];
    
    // Set up camera preview.
    [self setupCameraPreview];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.session startRunning];
}

- (void)updateCameraSelection {
    [self.session beginConfiguration];
    
    // Remove old inputs
    NSArray *oldInputs = [self.session inputs];
    for (AVCaptureInput *oldInput in oldInputs) {
        [self.session removeInput:oldInput];
    }
    
    AVCaptureDevicePosition desiredPosition = self.cameraSwitch.isOn?
    AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
    AVCaptureDeviceInput *input = [self cameraForPosition:desiredPosition];
    if (!input) {
        // Failed, restore old inputs
        for (AVCaptureInput *oldInput in oldInputs) {
            [self.session addInput:oldInput];
        }
    } else {
        // Succeeded, set input and update connection states
        [self.session addInput:input];
    }
    [self.session commitConfiguration];
}

- (AVCaptureDeviceInput *)cameraForPosition:(AVCaptureDevicePosition)desiredPosition {
    BOOL hadError = NO;
    for (AVCaptureDevice *device in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
        if ([device position] == desiredPosition) {
            NSError *error = nil;
            AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device
                                                                                error:&error];
            if (error) {
                hadError = YES;
                NSLog(@"Could not initialize for AVMediaTypeVideo for device %@", device);
            } else if ([self.session canAddInput:input]) {
                return input;
            }
        }
    }
    if (!hadError) {
        NSLog(@"No camera found for requested orientation");
    }
    return nil;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupCameraPreview {
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    [self.previewLayer setBackgroundColor:[[UIColor blueColor] CGColor]];
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    CALayer *rootLayer = [self.placeHolder layer];
    [rootLayer setMasksToBounds:YES];
    [self.previewLayer setFrame:[rootLayer bounds]];
    [rootLayer addSublayer:self.previewLayer];
}


@end
