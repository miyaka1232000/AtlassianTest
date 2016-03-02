//
//  ViewController.h
//  AtlassianTest
//
//  Created by Carmelita Mendoza on 2/3/16.
//  Copyright (c) 2016 Carmelita Mendoza. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UITextViewDelegate>

@property(nonatomic, weak) IBOutlet UITextView * mInputView;
@property(nonatomic, weak) IBOutlet UITextView * mOutputView;

-(IBAction)parseMessage:(id)sender;

@end

