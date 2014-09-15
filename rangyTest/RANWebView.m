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

@interface RANWebViewNote ()
@property (nonatomic, strong) NSString *start;
@property (nonatomic, strong) NSString *end;
@end

@implementation RANWebViewNote

- (void)setSerializedHighlight:(NSString *)serializedHighlight
{
    _serializedHighlight = serializedHighlight;
    NSArray *parts = [serializedHighlight componentsSeparatedByString:@"$"];
    if ([parts count] >= 3)
    {
        NSParameterAssert([parts[2] isEqualToString:self.noteID]);
        self.start = parts[0];
        self.end = parts[1];
    }
}

- (BOOL)isEqual:(id)object
{
    BOOL equal = NO;
    
    if ([object isKindOfClass:[RANWebViewNote class]])
    {
        RANWebViewNote *note = object;
        equal = [note.noteID isEqualToString:self.noteID];
    }
    
    return equal;
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


#pragma mark - Lifecycle

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
    self.notes = @[];
    self.interceptor = [RANWebViewDelegateInterceptor new];
    self.interceptor.middleMan = self;
    [super setDelegate:(id)self.interceptor];
    
    UIMenuItem *addNoteItem = [[UIMenuItem alloc] initWithTitle:@"Add Note"
                                                         action:@selector(addNoteFromSelection:)];
    [[UIMenuController sharedMenuController] setMenuItems:@[addNoteItem]];
}

- (void)dealloc
{
    [[UIMenuController sharedMenuController] setMenuItems:nil];
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
        NSString *noteID = request.URL.lastPathComponent;
        [self selectNoteWithID:noteID];
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
    
    RANWebViewNote *note = [RANWebViewNote new];
    note.noteID = dict[@"noteId"];
    note.highlightedContent = dict[@"selection"];
    
    NSString *serializedHighlights = dict[@"serializedHighlights"];
    NSArray *highlights = [serializedHighlights componentsSeparatedByString:@"|"];
    for (NSString *highlight in highlights)
    {
        NSArray *parts = [highlight componentsSeparatedByString:@"$"];
        if ([parts count] >= 3 && [parts[2] isEqualToString:note.noteID])
        {
            note.serializedHighlight = highlight;
        }
    }
    
    _notes = [self.notes arrayByAddingObject:note]; // avoid the overridden setter
    
    // prevents funky selection after highlight
    [self setUserInteractionEnabled:NO];
    [self setUserInteractionEnabled:YES];
    
    if ([self.delegate respondsToSelector:@selector(webView:didAddNote:)])
    {
        [self.delegate webView:self didAddNote:note];
    }
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    BOOL canPerform = NO;
    NSString *actionString = NSStringFromSelector(action);
    if ([actionString isEqualToString:NSStringFromSelector(@selector(addNoteFromSelection:))])
    {
        canPerform = YES;
    }
    else
    {
        canPerform = [super canPerformAction:action withSender:sender];
    }
    
    return canPerform;
}


#pragma mark - Notes

- (void)setNotes:(NSArray *)notes
{
    _notes = notes;
    
    if (notes && [notes count] > 0)
    {
        NSMutableArray *highlights = [[notes valueForKeyPath:@"@unionOfObjects.serializedHighlight"] mutableCopy];
        [highlights insertObject:@"type:textContent" atIndex:0];
        NSString *highlightsString = [highlights componentsJoinedByString:@"|"];
        NSString *js = [NSString stringWithFormat:@"guidelines.highliteInitialSelections(\"%@\");", highlightsString];
        [self stringByEvaluatingJavaScriptFromString:js];
        
        // prevents funky selection after highlight
        [self setUserInteractionEnabled:NO];
        [self setUserInteractionEnabled:YES];
    }
    else
    {
        [self stringByEvaluatingJavaScriptFromString:@"guidelines.removeAllHighlights();"];
    }
}

- (void)addNote:(RANWebViewNote *)note
{
    self.notes = [self.notes arrayByAddingObject:note];
}

- (void)removeNote:(RANWebViewNote *)note
{
    NSMutableArray *notes = [self.notes mutableCopy];
    [notes removeObject:note];
    self.notes = [NSArray arrayWithArray:notes];
}

- (void)removeAllNotes
{
    self.notes = @[];
}

- (void)selectNote:(RANWebViewNote *)note
{
    NSString *js = [NSString stringWithFormat:@"guidelines.scrollToID(\"note_%@\");", note.noteID];
    [self stringByEvaluatingJavaScriptFromString:js];
}

- (void)selectNoteWithID:(NSString *)noteID
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"noteID = %@", noteID];
    RANWebViewNote *note = [[self.notes filteredArrayUsingPredicate:predicate] firstObject];
    [self selectNote:note];
    
    if ([self.delegate respondsToSelector:@selector(webView:didSelectNote:)])
    {
        [self.delegate webView:self didSelectNote:note];
    }
}


#pragma mark - Searching

- (void)performSearchForString:(NSString *)string
{
    NSString *js = [NSString stringWithFormat:@"guidelines.performSearch(\"%@\");", string];
    [self stringByEvaluatingJavaScriptFromString:js];
}

- (void)jumpToNextOccurrenceOfSearchString
{
    [self stringByEvaluatingJavaScriptFromString:@"guidelines.nextSearch();"];
}

@end
