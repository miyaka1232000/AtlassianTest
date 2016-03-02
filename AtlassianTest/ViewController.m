//
//  ViewController.m
//  AtlassianTest
//
//  Created by Carmelita Mendoza on 2/3/16.
//  Copyright (c) 2016 Carmelita Mendoza. All rights reserved.
//

#import "ViewController.h"
#import "MessageManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [_mInputView setDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark IBAction methods
-(IBAction)parseMessage:(id)sender{
    
    //check the length before parsing
    if([_mInputView.text length ]> 0){
        //make the process asynchronous since it will try to connect to URL to fetch the title.
        dispatch_queue_t myQueue = dispatch_queue_create("My Queue",NULL);
        dispatch_async(myQueue, ^{
            NSString * output = [[MessageManager sharedManager] messagetoJsonString:_mInputView.text];
            dispatch_async(dispatch_get_main_queue(), ^{
                _mOutputView.text = output;
                
            });
        });
        
    }else{
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error",@"Error") message:NSLocalizedString(@"Please enter any string in the input field!", @"Please enter any string in the input field!") delegate:self cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok") otherButtonTitles:nil, nil];
        [alert show];
    }
    
}

@end
