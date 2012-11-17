/*
 *
 *  PDFOutlineParser.m
 *  DigitalBook
 *  PDFOutlineParser
 *
 *  Created by 弘樹 豊川 on 5/13/12.
 *  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
 */

#import "PDFOutlineParser.h"

@implementation PDFOutlineParser

@synthesize displayTitleDepth = displayTitleDepth_;
@synthesize titleArray = titleArray_;
@synthesize pageNumArray = pageNumArray_;

- (id)initWithCGPDFDocument:(CGPDFDocumentRef)document
{
    self = [super init];
    if (self) {
        document_ = document;
        CFRetain(document_);
        
        titleArray_ = [NSMutableArray array];
        [titleArray_ retain];
        
        pageNumArray_ = [NSMutableArray array];
        [pageNumArray_ retain];
        
        if (!displayTitleDepth_) {
            displayTitleDepth_ = 1;
        }
    }
    return self;
}

- (void)dealloc
{
    CFRelease(document_);
    [titleArray_ release];
    [pageNumArray_ release];
    [super dealloc];
}

/* ---------------------------------------- */
#pragma mark - user define method
/* ---------------------------------------- */
- (BOOL)parsePDFOutline
{
    NSMutableDictionary *addressToPageNumDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *outlineIdToAddressDict = [NSMutableDictionary dictionary];
    NSMutableArray *outlineIdArray = [NSMutableArray array];
    
    // create catalog
    CGPDFDictionaryRef catalog=CGPDFDocumentGetCatalog(document_);
    if (!catalog) {
        return NO;
    }
    
    /*
     * Pages
     */
    CGPDFDictionaryRef pagesDict = NULL;
    CGPDFArrayRef pagesKidsArray = NULL;
    
    CGPDFDictionaryGetDictionary(catalog, "Pages", &pagesDict);        
    if (pagesDict) {
        CGPDFDictionaryGetArray(pagesDict, "Kids", &pagesKidsArray);
    } else {
        return NO;
    }
    
    /* search pages tree */
    [self searchPagesTree:0 addressToPageNumDict:addressToPageNumDict kidsArray:pagesKidsArray];
    /*
     * /Names
     */
    BOOL namesFlag = NO;
    CGPDFDictionaryRef namesDict = NULL;
    CGPDFDictionaryRef destsDict = NULL;
    CGPDFArrayRef namesKidsArray = NULL;
    
    CGPDFDictionaryGetDictionary(catalog, "Names", &namesDict);
    if (namesDict) {
        namesFlag = YES;
        CGPDFDictionaryGetDictionary(namesDict, "Dests", &destsDict);
        if(destsDict){
            CGPDFDictionaryGetArray(destsDict, "Kids", &namesKidsArray);
            if (namesKidsArray) {
                /* search names tree */
                [self searchNamesTree:outlineIdToAddressDict kidsArray:namesKidsArray];
            }
        }
    }
    
    
    /*
     * /Outlines
     */
    CGPDFDictionaryRef outlinesDict = NULL;
    CGPDFDictionaryRef firstDict = NULL;
    
    CGPDFDictionaryGetDictionary(catalog, "Outlines", &outlinesDict);
    if (outlinesDict) {
        CGPDFDictionaryGetDictionary(outlinesDict, "First", &firstDict);
        if (firstDict) {
            // search outlines tree 
            [self searchOutlinesTree:0 displayTitleDepth:displayTitleDepth_ outlineTitleArray:titleArray_ outlineIdArray:outlineIdArray firstDict:firstDict];
        } else {
            return NO;
        }
    } else {
        return NO;
    }
    
    
    /*
     * create outline title array and page num array
     */
    if (namesFlag) {
        for (NSInteger i=0; i<[titleArray_ count]; i++) {
            
            [pageNumArray_ addObject:[addressToPageNumDict objectForKey:[outlineIdToAddressDict objectForKey:[outlineIdArray objectAtIndex:i]]]];
        }
    } else {
        for (NSInteger i=0; i<[titleArray_ count]; i++) {
            
            [pageNumArray_ addObject:[addressToPageNumDict objectForKey:[outlineIdArray objectAtIndex:i]]];
        }
    }
    
    for (NSInteger i=0; i<[titleArray_ count]; i++) {
        [pageNumArray_ addObject:[addressToPageNumDict objectForKey:[outlineIdToAddressDict objectForKey:[outlineIdArray objectAtIndex:i]]]];
    }
    return YES;
}


- (void)searchOutlinesTree:(NSInteger)depth displayTitleDepth:(NSInteger)displayTitleDepth outlineTitleArray:(NSMutableArray*)outlineTitleArray outlineIdArray:(NSMutableArray*)outlineIdArray firstDict:(CGPDFDictionaryRef)firstDict
{
    CGPDFStringRef titleStr;
    CGPDFDictionaryRef dictA;
    CGPDFDictionaryRef childFirstDict;
    CGPDFDictionaryRef nextDict;
    
    if (CGPDFDictionaryGetString(firstDict, "Title", &titleStr) && CGPDFDictionaryGetDictionary(firstDict, "A", &dictA)) 
    {
        NSString *title = (NSString*)CGPDFStringCopyTextString(titleStr);
        
        CGPDFStringRef stringD;
        CGPDFArrayRef arrayD;
        if (CGPDFDictionaryGetString(dictA, "D", &stringD)) {
            
            [outlineTitleArray addObject:title];
            [outlineIdArray addObject:[NSString stringWithFormat:@"%s", CGPDFStringGetBytePtr(stringD)]];
        } else if (CGPDFDictionaryGetArray(dictA, "D", &arrayD)) {
            CGPDFDictionaryRef dict0;
            if (CGPDFArrayGetDictionary(arrayD, 0, &dict0)) {
                [outlineTitleArray addObject:title];
                [outlineIdArray addObject:[NSString stringWithFormat:@"%p", dict0]];
            }
        
            CGPDFStringRef stringD;
            if (CGPDFDictionaryGetString(dictA, "D", &stringD)) {
            
                [outlineTitleArray addObject:title];
                [outlineIdArray addObject:[NSString stringWithFormat:@"%s", CGPDFStringGetBytePtr(stringD)]];
            }
        }
    }
    
    /* First */
    if (CGPDFDictionaryGetDictionary(firstDict, "First", &childFirstDict)) {
        if (depth < displayTitleDepth) {
            [self searchOutlinesTree:depth+1 displayTitleDepth:displayTitleDepth outlineTitleArray:outlineTitleArray outlineIdArray:outlineIdArray firstDict:childFirstDict];
        }
    }
    
    /* Next */
    if (CGPDFDictionaryGetDictionary(firstDict, "Next", &nextDict)) {
        [self searchOutlinesTree:depth displayTitleDepth:displayTitleDepth outlineTitleArray:outlineTitleArray outlineIdArray:outlineIdArray firstDict:nextDict];
    }
}
    
- (void)searchNamesTree:(NSMutableDictionary*)addressToPageNumDict kidsArray:(CGPDFArrayRef)kidsArray
{
    NSInteger cnt = CGPDFArrayGetCount(kidsArray);
    
    for (NSInteger i=0; i<cnt; i++) {
        CGPDFDictionaryRef kidsDict;
        CGPDFArrayGetDictionary(kidsArray, i, &kidsDict);
        CGPDFArrayRef childKidsArray;
        
        /* has children */
        if (CGPDFDictionaryGetArray(kidsDict, "Kids", &childKidsArray)) {
            [self searchNamesTree:addressToPageNumDict kidsArray:childKidsArray];
            /* does not have children */
        } else {
            CGPDFArrayRef namesArray;
            if (CGPDFDictionaryGetArray(kidsDict, "Names", &namesArray)) 
            {
                NSInteger cnt = CGPDFArrayGetCount(namesArray);
                
                for (NSInteger j=0; j<cnt; j=j+2) 
                {
                    CGPDFStringRef outlineId;
                    CGPDFArrayRef oddArray;
                    CGPDFDictionaryRef oddDict;
                    
                    /* array ver */
                    if (CGPDFArrayGetString(namesArray, j, &outlineId) && CGPDFArrayGetArray(namesArray, j+1, &oddArray)) 
                    {
                        CGPDFDictionaryRef pageDict;
                        if (CGPDFArrayGetDictionary(oddArray, 0, &pageDict)) 
                        {
                            
                            [addressToPageNumDict setObject:[NSString stringWithFormat:@"%p", pageDict] forKey:[NSString stringWithCString:(const char*)CGPDFStringGetBytePtr(outlineId) encoding:NSASCIIStringEncoding]];
                        }
                        /* dict ver */
                        [addressToPageNumDict setObject:[NSString stringWithFormat:@"%p", pageDict] forKey:[NSString stringWithCString:(const char*)CGPDFStringGetBytePtr(outlineId) encoding:NSASCIIStringEncoding]];
                    }
                    else if (CGPDFArrayGetString(namesArray, j, &outlineId) && CGPDFArrayGetDictionary(namesArray, j+1, &oddDict)) {
                        CGPDFArrayRef arrayD;
                        
                        if (CGPDFDictionaryGetArray(oddDict, "D", &arrayD)) {
                            CGPDFDictionaryRef pageDict;
                            
                            if (CGPDFArrayGetDictionary(arrayD, 0, &pageDict)) {
                                
                                [addressToPageNumDict setObject:[NSString stringWithFormat:@"%p", pageDict] forKey:[NSString stringWithCString:(const char*)CGPDFStringGetBytePtr(outlineId) encoding:NSASCIIStringEncoding]];
                            }
                        }
                    }
                }
            } else {
                return;
            }
        }
    }
}

- (NSInteger)searchPagesTree:(NSInteger)parentPageNum addressToPageNumDict:(NSMutableDictionary*)addressToPageNumDict kidsArray:(CGPDFArrayRef)kidsArray
{
    NSInteger cnt = CGPDFArrayGetCount(kidsArray);
    NSInteger pageNum = parentPageNum;
    
    for (NSInteger i=0; i<cnt; i++) {
        CGPDFDictionaryRef pageDict;
        CGPDFArrayGetDictionary(kidsArray, i, &pageDict);
        const char *typeString;
        
        if (CGPDFDictionaryGetName(pageDict, "Type", &typeString)) {
            /* has children */
            if (strcmp("Pages", typeString) == 0) {
                CGPDFArrayRef childKidsArray;
                CGPDFDictionaryGetArray(pageDict, "Kids", &childKidsArray);
                
                pageNum = [self searchPagesTree:pageNum addressToPageNumDict:addressToPageNumDict kidsArray: childKidsArray];
                
                /* does not have children */
            } else if (strncmp("Page", typeString, strlen("Page")) == 0) {
                pageNum = pageNum + 1;
                
                [addressToPageNumDict setValue:[NSNumber numberWithInt:pageNum] forKey:[NSString stringWithFormat:@"%p", pageDict]];
            }
        }
    }
    return pageNum;
}

@end
