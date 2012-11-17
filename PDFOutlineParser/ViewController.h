/*
 *  ViewController.h
 *  PDFOutlineParser
 *
 *  Created by 弘樹 豊川 on 5/13/12.
 *  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
 */

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    NSArray* titleArray_;
    NSArray* pageNumArray_;
    
    IBOutlet UITableView *tableView_;
}
@end
