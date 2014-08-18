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
}

- (void)setUpJavascript
{
    [self injectJavascriptFile:@"rangy-core"];
    [self injectJavascriptFile:@"rangy-serializer"];
    [self injectJavascriptFile:@"rangy-cssclassapplier"];
    [self injectJavascriptFile:@"rangy-highlighter"];
    [self injectJavascriptFile:@"rangy-textrange"];
    [self injectJavascriptFile:@"jquery-2.1.1"];
    [self injectJavascriptFile:@"jquery"];
    [self injectJavascriptFile:@"rangy-selectionsaverestore"];
    [self injectJavascriptFile:@"guidelines"];
    [self.webView stringByEvaluatingJavaScriptFromString:@"rangy.init();"];
   NSString *test =  [self.webView stringByEvaluatingJavaScriptFromString:
    [NSString stringWithFormat:@"guidelines.init(%@);", UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? @"true" : @"false"]];

    
//    [self.webView stringByEvaluatingJavaScriptFromString:@"init()"];
}

- (void)configureWebView
{
    NSString *formatString = [NSString stringWithFormat:@"<!DOCTYPE html>\n"
                              "<html lang=\"en\">\n"
                              "  <head>\n"
                              "    <meta charset=\"utf-8\">\n"
                              "    <meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\">\n"
                              "    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n"
                              "\n"
                              "    <link href=\"bootstrap-theme.css\" rel=\"stylesheet\">\n"
                              "    <link href=\"bootstrap.min.css\" rel=\"stylesheet\">\n"
                              "<link href=\"guidelines_light.css\" rel=\"stylesheet\">\n"
                              "  </head>\n"
                              "  <body>\n"
                              "    \n"
                              "    <div class=\"container\">%@",@"blah blah blah blah"];
    
    NSString *footerString = @"</div><!-- /div.container -->\n"
    "\n"
    "    <!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->\n"
    "    <script src=\"https://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js\"></script>\n"
    "    <!-- Include all compiled plugins (below), or include individual files as needed -->\n"
    "    <script src=\"js/bootstrap.min.js\"></script>\n"
    "  </body>\n"
    "</html>";

   
    NSString *formattedString = [NSString stringWithFormat:@"%@ %@", formatString, footerString];
    NSURL *bundlePath= [[NSBundle mainBundle] bundleURL];
    [self.webView loadHTMLString:formattedString baseURL:bundlePath];
}

- (void)configureMenuController
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
    UIMenuItem *highlightItem = [[UIMenuItem alloc] initWithTitle:@"Add Note" action:@selector(createNoteFromSelection)];
        UIMenuItem *removeHighlight = [[UIMenuItem alloc] initWithTitle:@"Remove Note" action:@selector(removeNoteFromSelection)];
    [[UIMenuController sharedMenuController] setMenuItems:@[highlightItem, removeHighlight]];
    });
}

- (void)createNoteFromSelection
{
    NSString *createdNoteString = [self.webView stringByEvaluatingJavaScriptFromString:@"guidelines.createNoteFromSelection();"];
    
    NSString *saveNoteString = [self.webView stringByEvaluatingJavaScriptFromString:@"saveHighlightedText();"];

}

- (void)removeNoteFromSelection
{
    
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


//- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
//{
//    if( action == @selector(removeNoteFromSelection))
//    {
//        NSString* ret = [self.webView stringByEvaluatingJavaScriptFromString:@"guidelines.hiliter.selectionOverlapsHighlight();"];
//        BOOL isHighlighted = [ret boolValue];
//        return isHighlighted;
//    }
////    if(action == @selector(addNote))
////    {
////        return !self.showNote;
////    }
//
//    return [super canPerformAction:action withSender:sender];
//}


@end
