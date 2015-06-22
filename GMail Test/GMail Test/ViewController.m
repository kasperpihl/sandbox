//
//  ViewController.m
//  GMail Test
//
//  Created by demosten on 12/8/14.
//  Copyright (c) 2014 demosten.com. All rights reserved.
//

#import "ViewController.h"
#import "GTLGmail.h"
#import "GTMOAuth2Authentication.h"
#import "GTMOAuth2ViewControllerTouch.h"

static NSString* const kClientID = @"791921060265-b1d0c65g7spt9evnl2lug4g33cpbgfq6.apps.googleusercontent.com";
static NSString* const kClientSecret = @"mILogx6YkvKKoMo72YjT8Ksa";
static NSString* const kKeychainKeyName = @"gmail_test_gmail";

@interface ViewController ()

@property (nonatomic, strong) GTMOAuth2Authentication* googleAuth;
@property (nonatomic, strong) NSString* swipesLabelId;

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

- (IBAction)onLogin:(id)sender
{
    NSError* error;
    
    GTMOAuth2Authentication* auth = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainKeyName
                                                                                          clientID:kClientID
                                                                                      clientSecret:kClientSecret
                                                                                             error:&error];
    if (error) {
        GTMOAuth2ViewControllerTouch* vc = [GTMOAuth2ViewControllerTouch controllerWithScope:kGTLAuthScopeGmailModify clientID:kClientID clientSecret:kClientSecret keychainItemName:kKeychainKeyName completionHandler:^(GTMOAuth2ViewControllerTouch *viewController, GTMOAuth2Authentication *auth, NSError *error) {
            
            NSLog(@"Authenticated. Auth: %@, Error: %@", auth, error);
            if (nil == error) {
                _googleAuth = auth;
                [self doStuff1:nil];
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [self presentViewController:vc animated:YES completion:nil];
    }
    else {
        _googleAuth = auth;
        [self doStuff1:nil];
    }
}

- (IBAction)doStuff1:(id)sender
{
    // test code
    GTLQueryGmail* listLabels = [GTLQueryGmail queryForUsersLabelsList];
    GTLServiceGmail* service = [[GTLServiceGmail alloc] init];
    service.authorizer = _googleAuth;
    [service executeQuery:listLabels completionHandler:^(GTLServiceTicket *ticket, GTLGmailListLabelsResponse* object, NSError *error) {
//        NSLog(@"queried - error: %@", error);
        BOOL hasSwipes = NO;
        if (object) {
            for (GTLGmailLabel* label in object.labels) {
//                NSLog(@"label: %@", label);
                if (NSOrderedSame == [label.name caseInsensitiveCompare:@"[Mailbox]/Swipes"]) {
                    _swipesLabelId = label.identifier;
                    [self listMessages:nil];
                    hasSwipes = YES;
                    break;
                }
            }
        }
        if (!hasSwipes) {
            GTLQueryGmail* createLabel = [GTLQueryGmail queryForUsersLabelsCreate];
            GTLGmailLabel* label = [[GTLGmailLabel alloc] init];
            label.name = @"[Mailbox]/Swipes";
            label.labelListVisibility = @"labelShow";
            label.messageListVisibility = @"show";
            createLabel.label = label;
            GTLServiceGmail* serviceCreateLabel = [[GTLServiceGmail alloc] init];
            serviceCreateLabel.authorizer = _googleAuth;
            [serviceCreateLabel executeQuery:createLabel completionHandler:^(GTLServiceTicket *ticket, GTLGmailLabel* object, NSError *error) {
//                NSLog(@"queried - error: %@", error);
                if (nil == error) {
                    _swipesLabelId = object.identifier;
                    [self listMessages:nil];
                }
            }];
        }
    }];
}

- (void)listMessages:(NSString *)query
{
    GTLQueryGmail* listMessages = [GTLQueryGmail queryForUsersMessagesList];
    listMessages.labelIds = @[_swipesLabelId];
    listMessages.maxResults = 100;
    listMessages.q = query;
    
    GTLServiceGmail* service = [[GTLServiceGmail alloc] init];
    service.authorizer = _googleAuth;
    [service executeQuery:listMessages completionHandler:^(GTLServiceTicket *ticket, GTLGmailListMessagesResponse* object, NSError *error) {
        if (error)
            NSLog(@"queried - error: %@", error);
        for (GTLGmailMessage* message in object.messages) {
//            NSLog(@"message: %@", message);
            GTLQueryGmail* getMessage = [GTLQueryGmail queryForUsersMessagesGet];
            getMessage.identifier = message.identifier;
            GTLServiceGmail* serviceGetMessage = [[GTLServiceGmail alloc] init];
            serviceGetMessage.authorizer = _googleAuth;
            [serviceGetMessage executeQuery:getMessage completionHandler:^(GTLServiceTicket *ticket, GTLGmailMessage* object, NSError *error) {
//                NSLog(@"queried - message:%@, error: %@", object, error);
                if (nil == error) {
                    NSLog(@"Message: %@", object.snippet);
                }
            }];
            
        }
    }];
}

- (IBAction)signOut:(id)sender
{
    [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:kKeychainKeyName];
    _googleAuth = nil;
}

@end
