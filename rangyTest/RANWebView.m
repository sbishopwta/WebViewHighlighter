//
//  RANNoteController.m
//  rangyTest
//
//  Created by Matt Jones on 9/12/14.
//  Copyright (c) 2014 WillowTree Apps. All rights reserved.
//

#import "RANWebView.h"


@interface RANWebViewDelegateInterceptor : NSObject
@property (nonatomic, weak) id receiver;
@property (nonatomic, weak) id middleMan;
@end

@implementation RANWebViewDelegateInterceptor

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    id target = nil;
    
    if ([self.middleMan respondsToSelector:aSelector])
    {
        target = self.middleMan;
    }
    else if ([self.receiver respondsToSelector:aSelector])
    {
        target = self.receiver;
    }
    else
    {
        target = [super forwardingTargetForSelector:aSelector];
    }
    
    return target;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    BOOL responds = NO;
    
    if ([self.middleMan respondsToSelector:aSelector])
    {
        responds = YES;
    }
    else if ([self.receiver respondsToSelector:aSelector])
    {
        responds = YES;
    }
    else
    {
        responds = [super respondsToSelector:aSelector];
    }
    
    return responds;
}

@end


#pragma mark -

@interface RANWebView ()
@property (nonatomic, strong) RANWebViewDelegateInterceptor *interceptor;
@end

@implementation RANWebView

#pragma mark - Synthesis Override

- (id<RANWebViewDelegate>)delegate
{
    return self.interceptor.receiver;
}

- (void)setDelegate:(id<RANWebViewDelegate>)delegate
{
    self.interceptor.receiver = delegate;
    [super setDelegate:(id)self.interceptor];
}


#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (void)setup
{
    self.interceptor = [RANWebViewDelegateInterceptor new];
    self.interceptor.middleMan = self;
    [super setDelegate:(id)self.interceptor];
    
    UIMenuItem *addNoteItem = [[UIMenuItem alloc] initWithTitle:@"Add Note"
                                                         action:@selector(addNoteFromSelection:)];
    UIMenuItem *removeNotItem = [[UIMenuItem alloc] initWithTitle:@"Remove Note"
                                                           action:@selector(removeNoteFromSelection:)];
    [[UIMenuController sharedMenuController] setMenuItems:@[addNoteItem, removeNotItem]];
}


#pragma mark - RANWebViewDelegateInterceptor

- (BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType
{
    BOOL load = YES;
    
    if (navigationType == UIWebViewNavigationTypeOther
        && [request.URL.scheme isEqualToString:@"glc"])
    {
        load = NO;
        // TODO: Callback for note selected
    }
    else if ([self.delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)])
    {
        load = [self.delegate webView:webView
           shouldStartLoadWithRequest:request
                       navigationType:navigationType];
    }
    
    return load;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self setUpJavaScript];
    if ([self.delegate respondsToSelector:@selector(webViewDidFinishLoad:)])
    {
        [self.delegate webViewDidFinishLoad:webView];
    }
}


#pragma mark - JavaScript

- (void)setUpJavaScript
{
    [self injectJavaScriptFile:@"rangy-core"];
    [self injectJavaScriptFile:@"rangy-serializer"];
    [self injectJavaScriptFile:@"rangy-cssclassapplier"];
    [self injectJavaScriptFile:@"rangy-highlighter"];
    [self injectJavaScriptFile:@"rangy-textrange"];
    [self injectJavaScriptFile:@"jquery-2.1.1"];
    [self injectJavaScriptFile:@"jquery"];
    [self injectJavaScriptFile:@"rangy-selectionsaverestore"];
    [self injectJavaScriptFile:@"guidelines"];
    [self stringByEvaluatingJavaScriptFromString:@"rangy.init();"];
    [self stringByEvaluatingJavaScriptFromString:@"guidelines.init();"];
    
    
}

- (void)injectJavaScriptFile:(NSString *)file
{
    NSString *jsPath = [[NSBundle mainBundle] pathForResource:file ofType:@"js"];
    NSString *js = [NSString stringWithContentsOfFile:jsPath
                                             encoding:NSUTF8StringEncoding
                                                error:NULL];
    [self stringByEvaluatingJavaScriptFromString:js];
}


#pragma mark - UIMenuItem

- (void)addNoteFromSelection:(id)sender
{
    NSString *createdNoteString = [self stringByEvaluatingJavaScriptFromString:@"guidelines.createNoteFromSelection();"];
    NSLog(@"%@", createdNoteString);
    
    NSData *jsonData = [createdNoteString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:NULL];
    
    RANNote *note = [RANNote new];
    note.noteID = dict[@"noteId"];
    note.highlightedContent = dict[@"selection"];
    note.serializedHighlight = dict[@"serializedHighlights"];
    _notes = [self.notes arrayByAddingObject:note]; // avoid the overridden setter
    
    NSString *javaScript = [NSString stringWithFormat:@"guidelines.addNoteClickListener(\"%@\",\"%@\");",
                            note.noteID, note.highlightedContent];
    [self stringByEvaluatingJavaScriptFromString:javaScript];
    
    
    
//    [self parseSerializedHighlights];
}

- (void)removeNoteFromSelection:(id)sender
{
    
}


#pragma mark - Notes

- (void)setNotes:(NSArray *)notes
{
    _notes = notes;
}

- (void)addNote:(RANNote *)note
{
    
}

- (void)deleteNote:(RANNote *)note
{
    
}

@end


@implementation RANNote
@end
