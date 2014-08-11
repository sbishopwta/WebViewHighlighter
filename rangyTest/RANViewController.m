//
//  RANViewController.m
//  rangyTest
//
//  Created by Steven Bishop on 8/10/14.
//  Copyright (c) 2014 WillowTree Apps. All rights reserved.
//

#import "RANViewController.h"


@interface RANViewController () <UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation RANViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.webView.delegate = self;
    [self configureWebView];
    [self configureMenuController];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)setUpJavascript
{
    [self injectJavascriptFile:@"rangy-core"];
    [self injectJavascriptFile:@"rangy-serializer"];
    [self injectJavascriptFile:@"rangy-cssclassapplier"];
    [self injectJavascriptFile:@"rangy-highlighter"];
    [self injectJavascriptFile:@"rangy-textrange"];
    [self injectJavascriptFile:@"claritas"];
    [self.webView stringByEvaluatingJavaScriptFromString:@"rangy.init();"];
    [self.webView stringByEvaluatingJavaScriptFromString:
     [NSString stringWithFormat:@"claritas.init(%@);", UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? @"true" : @"false"]];

        [UIView animateWithDuration:0.25 animations:^{
        [self.webView setAlpha:1.0];
    } completion:^(BOOL finished) {
        [self forceRedrawInWebView:self.webView];
    }];


}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if( action == @selector(removeHighlight))
    {
        NSString* ret = [self.webView stringByEvaluatingJavaScriptFromString:@"claritas.hiliter.selectionOverlapsHighlight();"];
        BOOL isHighlighted = [ret boolValue];
        return isHighlighted;
    }
//    if(action == @selector(addNote))
//    {
//        return !self.showNote;
//    }
    
    return [super canPerformAction:action withSender:sender];
}


- (void)configureWebView
{
   [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"file:///Users/stevenbishop/Downloads/testHighlight.html"]]];
}

- (void)configureMenuController
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
    UIMenuItem *highlightItem = [[UIMenuItem alloc] initWithTitle:@"Highlight" action:@selector(hightlightText)];
        UIMenuItem *removeHighlight = [[UIMenuItem alloc] initWithTitle:@"Remove Highlight" action:@selector(removeHighlight)];
    [[UIMenuController sharedMenuController] setMenuItems:@[highlightItem, removeHighlight]];
    });
}

- (void)hightlightText
{
    //Just to see if it works
//    NSString *highlightedText = [self.webView stringByEvaluatingJavaScriptFromString:@"document.write('This Works')"];
    
    [self.webView stringByEvaluatingJavaScriptFromString:@"claritas.hiliter.highlightSelection(\"claritasHilite\");"];
    self.webView.userInteractionEnabled = NO;
    self.webView.userInteractionEnabled = YES;
    
    NSString* hilites = [self.webView stringByEvaluatingJavaScriptFromString:@"claritas.hiliter.serialize();"];
    NSString *test = [self.webView stringByEvaluatingJavaScriptFromString:@"createNoteFromSelection();"];
    NSLog(@"%@", test);

}

- (void)removeHighlight
{
    [self.webView stringByEvaluatingJavaScriptFromString:@"claritas.hiliter.unhighlightSelection();"];
    self.webView.userInteractionEnabled = NO;
    self.webView.userInteractionEnabled = YES;
    
    NSString* hilites = [self.webView stringByEvaluatingJavaScriptFromString:@"claritas.hiliter.serialize();"];
    
}

- (void)injectJavascriptFile:(NSString*)file
{
    NSString *jsPath = [[NSBundle mainBundle] pathForResource:file ofType:@"js"];
    NSString *js = [NSString stringWithContentsOfFile:jsPath encoding:NSUTF8StringEncoding error:NULL];
    
    [self.webView stringByEvaluatingJavaScriptFromString:js];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self setUpJavascript];
    NSLog(@"Webview finished loading");
}

- (void)forceRedrawInWebView:(UIWebView*)webView {
    NSArray *views = webView.scrollView.subviews;
    
    for(int i = 0; i<views.count; i++){
        UIView *view = views[i];
        
        if([NSStringFromClass([view class]) isEqualToString:@"UIWebBrowserView"]){
            [view setNeedsDisplayInRect:webView.bounds]; //Webkit Repaint, usually fast
            [view setNeedsLayout]; //Webkit Relayout
            
            //Causes redraw of *entire* UIWebView, onscreen and off, usually intensive
            [view setNeedsDisplay]; [view setNeedsLayout];
            break;
        }
    }
}


@end
