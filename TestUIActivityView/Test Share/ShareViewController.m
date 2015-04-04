//
//  ShareViewController.m
//  Test Share
//
//  Created by demosten on 3/11/15.
//  Copyright (c) 2015 Swipes. All rights reserved.
//

@import MobileCoreServices;
#import "ShareViewController.h"

@interface ShareViewController ()

@property (nonatomic, weak) IBOutlet UITextField* text;
@property (nonatomic, weak) IBOutlet UILabel* urlText;
@property (nonatomic, weak) IBOutlet UIButton* cancelButton;
@property (nonatomic, weak) IBOutlet UIButton* postButton;

@property (nonatomic, strong) NSURL* url;

@end

@implementation ShareViewController

- (BOOL)isContentValid {
    // Do validation of contentText and/or NSExtensionContext attachments here
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSExtensionItem* item = [self.extensionContext.inputItems.firstObject copy];
    self.text.text = item.attributedContentText.string;
    NSItemProvider* attachment = [item.attachments.firstObject copy];
    if ([attachment hasItemConformingToTypeIdentifier:(NSString *)kUTTypeURL]) {
        [attachment loadItemForTypeIdentifier:(NSString *)kUTTypeURL options:nil completionHandler:^(id<NSSecureCoding> item, NSError *error) {
            NSObject* itm = (NSObject *)item;
            if ([itm isKindOfClass:NSURL.class]) {
                self.url = (NSURL *)itm;
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.urlText.text = [self.url absoluteString];
//                    [self.view setNeedsDisplay];
                });
            }
        }];
    }
/*    else {
        self.text.text = item.attributedTitle.string;
    }*/
}

- (IBAction)didSelectPost:(id)sender {
    // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
    NSExtensionItem* item = self.extensionContext.inputItems.firstObject;
//    NSLog(@"title: %@", item.attributedTitle.string);
//    NSLog(@"content: %@", item.attributedContentText.string);

    
    NSLog(@"title: %@", (self.text.text.length == 0) ? item.attributedContentText.string : self.text.text);
    if (_url)
        NSLog(@"url: %@", [_url absoluteString]);
    
    [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
}

- (IBAction)didCancel:(id)sender
{
    [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
}

- (NSArray *)configurationItems {
    return @[];
}

@end
