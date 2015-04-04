//
//  ViewController.m
//  TestUIActivityView
//
//  Created by demosten on 3/11/15.
//  Copyright (c) 2015 Swipes. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UIPopoverControllerDelegate>

@property (nonatomic, strong) UIPopoverController* popover;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)openActivityViewWithArray:(NSArray *)array inFrame:(CGRect)frame
{
    UIActivityViewController *activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:array
                                      applicationActivities:nil];
    
    NSLog(@"fb is: %@", UIActivityTypePostToFacebook);
    activityViewController.excludedActivityTypes = @[@"com.demosten.TestUIActivityView.testShare"];
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        self.popover = [[UIPopoverController alloc] initWithContentViewController:activityViewController];
        self.popover.delegate = self;
        [self.popover presentPopoverFromRect:frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else {
        [self presentViewController:activityViewController
                           animated:YES
                         completion:^{
                             // ...
                         }];
    }
}

- (IBAction)onShowActivityView:(UIButton *)sender
{
    [self openActivityViewWithArray:@[@"Testing activity view"] inFrame:sender.frame];
}

- (IBAction)onMultiLine:(UIButton *)sender
{
    [self openActivityViewWithArray:@[@"Multi line\nText comes here\nWhere you can read it"] inFrame:sender.frame];
}

- (IBAction)onMultilineEmpty:(UIButton *)sender
{
    [self openActivityViewWithArray:@[@"\n\n\n \n\nMore multiline text"] inFrame:sender.frame];
}

@end
