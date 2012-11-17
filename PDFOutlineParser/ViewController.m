/*
 *  ViewController.m
 *  PDFOutlineParser
 *
 *  Created by 弘樹 豊川 on 5/13/12.
 *  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
 */

#import "define.h"
#import "ViewController.h"
#import "PDFOutlineParser.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Outline Index";
    
    /* init */
	titleArray_ = [NSArray array];
    [titleArray_ retain];
    
    pageNumArray_ = [NSArray array];
    [pageNumArray_ retain];
    
    /* create pdf document */
    NSString *path;
    NSURL *url;
    CGPDFDocumentRef document;
    path = [[NSBundle mainBundle] pathForResource:FILE_NAME ofType:@"pdf"];
    url = [NSURL fileURLWithPath:path];
    document = CGPDFDocumentCreateWithURL((CFURLRef)url);
    
    /* parse pdf outline */
    PDFOutlineParser *pdfOutlineParser = [[PDFOutlineParser alloc] initWithCGPDFDocument:document];
    if ([pdfOutlineParser parsePDFOutline]) {
        titleArray_ = pdfOutlineParser.titleArray;
        pageNumArray_ = pdfOutlineParser.pageNumArray;
    }
}

- (void)viewDidUnload
{
    [tableView_ release];
    tableView_ = nil;
    [super viewDidUnload];
    /* Release any retained subviews of the main view. */
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)dealloc {
    [tableView_ release];
    [super dealloc];
}

/* ------------------------------------------ */
#pragma mark - table view delegate
/* ------------------------------------------ */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [titleArray_ count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"] autorelease];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"p.%@: %@", [pageNumArray_ objectAtIndex:indexPath.row], [titleArray_ objectAtIndex:indexPath.row]];
    
    return cell;
}

@end
