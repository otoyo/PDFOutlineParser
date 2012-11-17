/*
 *  PDFOutlineParser.h
 *  PDFOutlineParser
 *
 *  Created by 弘樹 豊川 on 5/13/12.
 *  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PDFOutlineParser : NSObject
{
    CGPDFDocumentRef document_;
    
    NSInteger displayTitleDepth_;
    
    NSMutableArray* titleArray_;
    NSMutableArray* pageNumArray_;
}
@property (assign) NSInteger displayTitleDepth;
@property (nonatomic, retain, readonly) NSArray *titleArray;
@property (nonatomic, retain, readonly) NSArray *pageNumArray;

- (id)initWithCGPDFDocument:(CGPDFDocumentRef)document;
- (BOOL)parsePDFOutline;

@end
