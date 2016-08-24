//
//  ViewController.m
//  testHandoff
//
//  Created by lan on 16/7/18.
//  Copyright © 2016年 lan. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITextViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UITextField *noteTitleField;
@property (nonatomic, strong) UITextView * noteContentView;
@property (nonatomic, strong) NSUserActivity *userActivity;

@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated {
    _noteTitleField = [[UITextField alloc] initWithFrame:CGRectMake(12, 28, self.view.frame.size.width - 22, 20)];
    _noteTitleField.placeholder = @"Note Title";
    _noteTitleField.delegate = self;
    
    _noteContentView = [[UITextView alloc] initWithFrame:CGRectMake(8, 56, self.view.frame.size.width - 16, self.view.frame.size.height - 64)];
    _noteContentView.text = @"Note Content";
    _noteContentView.delegate = self;
    
    [self.view addSubview:_noteTitleField];
    [self.view addSubview:_noteContentView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSUserActivity *activity = [[NSUserActivity alloc] initWithActivityType:@"com.tutsplus.handoff-introduction.note"];
    activity.title = @"Note";
    activity.userInfo = @{@"title": @"", @"content": @""};
    
    _userActivity = activity;
    [_userActivity becomeCurrent];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@"Note Content"]) {
        textView.text = @"";
    }
}

- (void)updateUserActivityState:(NSUserActivity *)activity {
    [activity addUserInfoEntriesFromDictionary:@{@"title": self.noteTitleField.text, @"content": self.noteContentView.text}];
    [super updateUserActivityState:activity];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [self updateUserActivityState:self.userActivity];
    return true;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    [self updateUserActivityState:self.userActivity];
    return true;
}

@end
