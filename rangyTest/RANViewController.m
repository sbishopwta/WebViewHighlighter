//
//  RANViewController.m
//  rangyTest
//
//  Created by Steven Bishop on 8/10/14.
//  Copyright (c) 2014 WillowTree Apps. All rights reserved.
//

#import "RANViewController.h"
#import "RANWebView.h"

@interface RANViewController () <RANWebViewDelegate, UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet RANWebView *webView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation RANViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.webView.delegate = self;
    self.searchBar.delegate = self;
    [self configureWebView];
}

#pragma -mark Search Bar Delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self.webView performSearchForString:searchText];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.webView jumpToNextOccurrenceOfSearchString];
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
        case UIWebViewNavigationTypeFormSubmitted:
        case UIWebViewNavigationTypeBackForward:
        case UIWebViewNavigationTypeReload:
        case UIWebViewNavigationTypeFormResubmitted:
        default:
            break;
    }
    
    return load;
}

- (void)webView:(RANWebView *)webView didAddNote:(RANWebViewNote *)note
{
    
}

- (void)webView:(RANWebView *)webView didSelectNote:(RANWebViewNote *)note
{
    [webView removeNote:note];
}

@end
