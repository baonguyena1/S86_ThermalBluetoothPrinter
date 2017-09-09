//
//  PrinterFormat.m
//  BTDemoCJ
//
//  Created by Bao Nguyen on 9/6/17.
//

#import "PrinterFormat.h"

@implementation PrinterFormat

+ (NSString *)printTitle:(NSString *)title {
    NSMutableString *contentString = [NSMutableString new];
    if (title.length > CHAR_NORMAL_PER_LINE) {
        NSString *subTitle = [title substringToIndex:CHAR_NORMAL_PER_LINE];
        [contentString appendString:subTitle];
    } else {
        [contentString appendString:title];
    }
    [contentString appendString:@"\n"];
    return contentString.copy;
}

#pragma mark for order item
/**
 Print order with format 1  Hamburger   SGD 14.67

 @param orderItem
 @return
 */
+ (NSString *)printOrderNumber:(NSString *)orderNumber title:(NSString *)mTitle price:(NSString *)mPrice {
    int space = 3;
    int orderNumberSpace = 2;
    int currencySpace = 9;
    NSMutableString *contentString = [NSMutableString new];
    [contentString appendString:orderNumber];

    [contentString appendString:[self spaceString:space]];

    // Check and split title
    int titleSpace = CHAR_NORMAL_PER_LINE - (int)(orderNumberSpace + currencySpace + 2 * space);
    NSMutableString *titleString = [self SplitAndAppendString:mTitle destination:contentString maxLength:titleSpace];

    [contentString appendString:[self spaceString:space]];
    [contentString appendString:mPrice];

    while (titleString != nil || titleString.length > 0) {
        [contentString appendString:@"\n"];
        [contentString appendString:[self spaceString:orderNumberSpace + space]];
        titleString = [self SplitAndAppendString:titleString destination:contentString maxLength:titleSpace];
        [contentString appendString:[self spaceString:space + currencySpace]];
    }

    [contentString appendString:@"\n"];

    return contentString;
}

+ (NSString *)printSubOrderNumer:(NSString *)subOrderNumber title:(NSString *)mTitle {
    int leftSpace = 3;
    int space = 2;
    int rightSpace = 12;
    int subOrderNumberSpace = 2;

    NSMutableString *contentString = [NSMutableString new];
    [contentString appendString:[self spaceString:leftSpace]];
    [contentString appendString:subOrderNumber];
    [contentString appendString:[self spaceString:space]];
    
    int titleSpace = CHAR_NORMAL_PER_LINE - (int)(leftSpace + subOrderNumberSpace + rightSpace + space);
    NSString *titleString = [self SplitAndAppendString:mTitle destination:contentString maxLength:titleSpace];
    [contentString appendString:[self spaceString:rightSpace]];

    while (titleString != nil || titleString.length > 0) {
        [contentString appendString:@"\n"];
        [contentString appendString:[self spaceString:leftSpace + subOrderNumberSpace + space]];
        titleString = [self SplitAndAppendString:titleString destination:contentString maxLength:titleSpace];
        [contentString appendString:[self spaceString:rightSpace]];
    }
    [contentString appendString:@"\n"];

    return contentString;
}

#pragma mark for left right item
+ (NSString *)leftRightItem:(NSString *)leftTitle rightTitle:(NSString *)mRightTitle {
    int space = 3;
    int rightSpace = 10;
    int leftSapce = CHAR_NORMAL_PER_LINE - 10 - space;

    NSMutableString *contentString = [NSMutableString new];
    [self SplitAndAppendString:leftTitle destination:contentString maxLength:leftSapce];
    [contentString appendString:[self spaceString:space]];
    [contentString appendString:mRightTitle];
    [contentString appendString:@"\n"];

    return contentString;
}

#pragma mark utils
+ (NSMutableString *)SplitAndAppendString:(NSString *)source destination:(NSMutableString *)des maxLength:(int)len {
    if (source.length > len) {
        NSString *title = [source substringToIndex:len];
        [des appendString:title];
        return [NSMutableString stringWithString:[source substringFromIndex:len]];
    } else {
        int titleSpace = len - (int)source.length;
        [des appendString:source];
        [des appendString:[self spaceString:titleSpace]];
        return nil;
    }
}

+ (NSString *)spaceString:(int)space {
    NSMutableString *contentString = [NSMutableString new];
    for (int index = 0; index < space; index++) {
        [contentString appendString:@" "];
    }
    return  contentString.copy;
}

@end
