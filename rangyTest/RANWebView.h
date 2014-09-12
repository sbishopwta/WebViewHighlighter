//
//  RANWebView.h
//  rangyTest
//
//  Created by Matt Jones on 9/12/14.
//  Copyright (c) 2014 WillowTree Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RANWebView;
@class RANWebViewNote;

@protocol RANWebViewDelegate <UIWebViewDelegate>

@optional
- (void)webView:(RANWebView *)webView didAddNote:(RANWebViewNote *)note;
- (void)webView:(RANWebView *)webView didSelectNote:(RANWebViewNote *)note;

@end


@interface RANWebView : UIWebView

@property(nonatomic, assign) id<RANWebViewDelegate> delegate;
@property(nonatomic, strong) NSArray *notes;

- (void)selectNote:(RANWebViewNote *)note;
- (void)addNote:(RANWebViewNote *)note;
- (void)removeNote:(RANWebViewNote *)note;
- (void)removeAllNotes;

- (void)performSearchForString:(NSString *)string;
- (void)jumpToNextOccurrenceOfSearchString;

@end


@interface RANWebViewNote : NSObject
@property (nonatomic, strong) NSString *noteID;
@property (nonatomic, strong) NSString *highlightedContent;
@property (nonatomic, strong) NSString *serializedHighlight;
@property (nonatomic, strong) NSString *textNote;
@end
