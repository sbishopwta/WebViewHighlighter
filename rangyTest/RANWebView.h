//
//  RANWebView.h
//  rangyTest
//
//  Created by Matt Jones on 9/12/14.
//  Copyright (c) 2014 WillowTree Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RANNote;

@protocol RANWebViewDelegate <UIWebViewDelegate>

@end


@interface RANWebView : UIWebView

@property(nonatomic, assign) id<RANWebViewDelegate> delegate;
@property(nonatomic, strong) NSArray *notes;

- (void)addNote:(RANNote *)note;

@end


@interface RANNote : NSObject
@property (nonatomic, strong) NSString *noteID;
@property (nonatomic, strong) NSString *highlightedContent;
@property (nonatomic, strong) NSString *serializedHighlight;
@property (nonatomic, strong) NSString *textNote;
@end
