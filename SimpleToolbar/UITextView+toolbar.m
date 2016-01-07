//
//  UITextView+toolbar.m
//  SimpleToolbar
//
//  Created by HoRyo on 16/1/7.
//  Copyright © 2016年 com.ucsmy. All rights reserved.
//

#import "UITextView+toolbar.h"

@implementation UITextView (toolbar)
//添加toolbar
//返回所有文本框
static NSArray * EditableTextInputsInView(UIView *view)
{
    NSMutableArray *textInputs = [NSMutableArray new];
    for (UIView *subview in view.subviews)
    {
        BOOL isTextField = [subview isKindOfClass:[UITextField class]] && [(UITextField *)subview isEnabled] ;
        BOOL isEditableTextView = [subview isKindOfClass:[UITextView class]] && [(UITextView *)subview isEditable] ;
        if (isTextField || isEditableTextView)
            [textInputs addObject:subview];
        else
            [textInputs addObjectsFromArray:EditableTextInputsInView(subview)];
    }
    return textInputs;
}
- (NSArray *) responders
{
    NSArray *textInputs = EditableTextInputsInView([[UIApplication sharedApplication] keyWindow]);
    return [textInputs sortedArrayUsingComparator:^NSComparisonResult(UIView *textInput1, UIView *textInput2) {
        UIView *commonAncestorView = textInput1.superview;
        while (commonAncestorView && ![textInput2 isDescendantOfView:commonAncestorView])
            commonAncestorView = commonAncestorView.superview;
        
        CGRect frame1 = [textInput1 convertRect:textInput1.bounds toView:commonAncestorView];
        CGRect frame2 = [textInput2 convertRect:textInput2.bounds toView:commonAncestorView];
        return [@(CGRectGetMinY(frame1)) compare:@(CGRectGetMinY(frame2))];
    }];
}

- (UIView *)inputAccessoryView
{
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    toolbar.tintColor = nil;
    toolbar.barStyle = UIBarStyleDefault;
    toolbar.translucent = YES;
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UIBarButtonItem *leftbarbutton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"leftarrow.png"] style:UIBarButtonItemStylePlain target:self action:@selector(selectLastResponder:)];
    UIBarButtonItem *fixSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixSpace.width = 10;
    UIBarButtonItem *rightbarbutton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"rightarrow.png"] style:UIBarButtonItemStylePlain target:self action:@selector(selectNextResponder:)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *DoneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    toolbar.items = @[ leftbarbutton,fixSpace, rightbarbutton, flexibleSpace,DoneButton];
    toolbar.frame = (CGRect){CGPointZero, [toolbar sizeThatFits:CGSizeZero]};
    
    return toolbar;
}

#pragma mark - Actions
- (void)selectLastResponder:(UIBarButtonItem*)sender
{
    NSArray *responders = [self responders];
    NSArray *firstResponders = [responders filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UIResponder *responder, NSDictionary *bindings) {
        return [responder isFirstResponder];
    }]];
    UIResponder *firstResponder = [firstResponders lastObject];
    NSInteger offset = -1;
    NSInteger firstResponderIndex = [responders indexOfObject:firstResponder];
    NSInteger adjacentResponderIndex = firstResponderIndex != NSNotFound ? firstResponderIndex + offset : NSNotFound;
    UIResponder *adjacentResponder = nil;
    if (adjacentResponderIndex >= 0 && adjacentResponderIndex < (NSInteger)[responders count]){
        //可用
        adjacentResponder = [responders objectAtIndex:adjacentResponderIndex];
        [adjacentResponder becomeFirstResponder];
    }else{
        //不可用，循环
        adjacentResponderIndex = [responders count] -1 ;
        adjacentResponder = [responders objectAtIndex:adjacentResponderIndex];
        [adjacentResponder becomeFirstResponder];
    }
}

- (void)selectNextResponder:(UIBarButtonItem*)sender
{
    NSArray *responders = self.responders;
    NSArray *firstResponders = [responders filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UIResponder *responder, NSDictionary *bindings) {
        return [responder isFirstResponder];
    }]];
    UIResponder *firstResponder = [firstResponders lastObject];
    NSInteger offset = +1;
    NSInteger firstResponderIndex = [responders indexOfObject:firstResponder];
    NSInteger adjacentResponderIndex = firstResponderIndex != NSNotFound ? firstResponderIndex + offset : NSNotFound;
    UIResponder *adjacentResponder = nil;
    if (adjacentResponderIndex >= 0 && adjacentResponderIndex < (NSInteger)[responders count]){
        adjacentResponder = [responders objectAtIndex:adjacentResponderIndex];
        [adjacentResponder becomeFirstResponder];
        
    }else{
        adjacentResponderIndex = 0 ;
        adjacentResponder = [responders objectAtIndex:adjacentResponderIndex];
        [adjacentResponder becomeFirstResponder];
    }
}

- (void) done
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}
@end
