//
//  RANViewController.m
//  rangyTest
//
//  Created by Steven Bishop on 8/10/14.
//  Copyright (c) 2014 WillowTree Apps. All rights reserved.
//

#import "RANViewController.h"


@interface RANViewController () <UIWebViewDelegate, UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) NSString *serializedHighlights;
@property (strong, nonatomic) NSString *noteID;
@property (strong, nonatomic) NSString *noteSelection;

@property (strong, nonatomic) NSString *start;
@property (strong, nonatomic) NSString *end;

@property (strong, nonatomic) NSMutableDictionary *notesDict;

@end

@implementation RANViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.webView.delegate = self;
    self.searchBar.delegate = self;
    [self configureWebView];
    [self configureMenuController];
    self.notesDict = [NSMutableDictionary new];
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
    [self.webView stringByEvaluatingJavaScriptFromString:
                       [NSString stringWithFormat:@"guidelines.init(%@);", UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? @"true" : @"false"]];
    
    
}

#pragma -mark Search Bar Delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSString *quoteText = [NSString stringWithFormat:@"\"%@\"", searchText];
    //Perform search
    [self.webView stringByEvaluatingJavaScriptFromString:
                                [NSString stringWithFormat:@"guidelines.performSearch(%@);", quoteText]];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.webView stringByEvaluatingJavaScriptFromString:@"guidelines.nextSearch();"];
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
                              "    <div class=\"container\">%@",@"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent varius nisl ut lacus venenatis blandit. Fusce orci augue, tristique ac dictum sed, rhoncus vitae velit. Etiam ullamcorper vel diam ut rutrum. Praesent quis felis turpis. Donec et consectetur est, accumsan luctus tortor. Fusce dui diam, placerat ut imperdiet ac, dapibus ac dui. Suspendisse efficitur vitae nisl mollis posuere. Duis cursus rutrum blandit. Duis laoreet odio a lectus ornare, at pretium lorem blandit. Donec sit amet nisl non tortor tristique efficitur. Ut non aliquet sem.Quisque vel sodales urna, sed suscipit turpis. Suspendisse augue lectus, condimentum eget pulvinar quis, pulvinar ut nunc. In ut malesuada diam. Proin consequat et turpis at fringilla. Nunc congue id sem non tincidunt. Proin condimentum cursus metus, quis posuere nulla varius sed. Donec interdum lectus nunc, sed consequat nibh faucibus sed. Fusce eleifend urna eu mauris mollis, vel lacinia mauris tincidunt. Mauris ac metus interdum, accumsan sem vitae, venenatis nunc. Sed condimentum dictum gravida. Ut faucibus rhoncus maximus. Donec pharetra egestas mauris, sed laoreet massa dapibus quis. Duis ex massa, volutpat et ante sed, laoreet luctus ligulaa"];
    
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
    UIMenuItem *highlightItem = [[UIMenuItem alloc] initWithTitle:@"Add Note" action:@selector(createNoteFromSelection)];
    UIMenuItem *removeHighlight = [[UIMenuItem alloc] initWithTitle:@"Remove Note" action:@selector(removeAllNotes)];
    [[UIMenuController sharedMenuController] setMenuItems:@[highlightItem, removeHighlight]];
}

- (void)createNoteFromSelection
{
    NSString *createdNoteString = [self.webView stringByEvaluatingJavaScriptFromString:@"guidelines.createNoteFromSelection();"];
    NSLog(@"%@", createdNoteString);
    NSData *jsonData = [createdNoteString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *e;
    NSDictionary *jSONDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&e];
    
    self.noteID = jSONDict[@"noteId"];
    self.noteSelection = jSONDict[@"selection"];
    self.serializedHighlights = jSONDict[@"serializedHighlights"];
    NSLog(@"%@ %@ %@", self.noteID, self.noteSelection, self.serializedHighlights);
    
    [self notesDict][self.noteID] = jSONDict;
    
    [self parseSerializedHighlights];
    [self.webView setUserInteractionEnabled:NO];
    [self.webView setUserInteractionEnabled:YES];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    BOOL load = YES;
    
    switch (navigationType)
    {
        case UIWebViewNavigationTypeLinkClicked:
            [[UIApplication sharedApplication] openURL:[request URL]];
            load = NO;
            break;
        case UIWebViewNavigationTypeOther:
            NSLog(@"%@", request);
            load = NO;
            break;
        case UIWebViewNavigationTypeFormSubmitted:
        case UIWebViewNavigationTypeBackForward:
        case UIWebViewNavigationTypeReload:
        case UIWebViewNavigationTypeFormResubmitted:
        default:
            break;
    }
    
    return load;
}

- (void)parseSerializedHighlights
{
    NSArray *parts = [self.serializedHighlights componentsSeparatedByString:@"|"];
    
    if (parts.count > 1)
    {
        for (NSString *part in parts)
        {
            NSArray *sections = [part componentsSeparatedByString:@"$"];
            if (sections.count > 3)
            {
                if ([sections[2] isEqualToString:self.noteID])
                {
                    self.start = sections[0];
                    self.end = sections[1];
                }
            }
        }

    }
    
}

- (void)removeNoteFromSelection
{
    
}

- (void)removeAllNotes
{
    NSString *newSerializedHighlights = [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"guidelines.removeNote(\"%@\", \"%@\", \"%@\");", self.noteID, self.start, self.end]];
    
    
    NSString *removeAllNotesString = [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"guidelines.highliteInitialSelections(\"%@\")", newSerializedHighlights]];
    
    [self.notesDict removeObjectForKey:self.noteID];
    NSLog(@"%@", removeAllNotesString);
    [self.webView setUserInteractionEnabled:NO];
    [self.webView setUserInteractionEnabled:YES];
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

@end
