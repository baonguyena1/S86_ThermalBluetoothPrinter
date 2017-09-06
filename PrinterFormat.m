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


/**
 Print order with format 1  Hamburger   SGD 14.67

 @param orderItem
 @return
 */
+ (NSString *)printOrderNumber:(NSString *)orderNumber title:(NSString *)mTitle price:(NSString *)mPrice {
    int space = 3;
    int itemNumerSpace = 2;
    int currencySpace = 9;
    NSMutableString *contentString = [NSMutableString new];
    [contentString appendString:orderNumber];

    [contentString appendString:[PrinterFormat spaceString:space]];

    // Check and split title
    int titleSpace = CHAR_NORMAL_PER_LINE - (int)(itemNumerSpace + currencySpace + 2 * space);
    NSMutableString *titleString = [PrinterFormat appendString:mTitle destination:contentString maxLength:titleSpace];

    [contentString appendString:[PrinterFormat spaceString:space]];
    [contentString appendString:mPrice];

    while (titleString != nil || titleString.length > 0) {
        [contentString appendString:@"\n"];
        [contentString appendString:[PrinterFormat spaceString:itemNumerSpace + space]];
        titleString = [PrinterFormat appendString:titleString destination:contentString maxLength:titleSpace];
        [contentString appendString:[PrinterFormat spaceString:space + currencySpace]];
    }

    [contentString appendString:@"\n"];

    return contentString;
}

+ (NSMutableString *)appendString:(NSString *)source destination:(NSMutableString *)des maxLength:(int)len {
    if (source.length > len) {
        NSString *title = [source substringToIndex:len];
        [des appendString:title];
        return [NSMutableString stringWithString:[source substringFromIndex:len]];
    } else {
        int titleSpace = len - (int)source.length;
        [des appendString:source];
        [des appendString:[PrinterFormat spaceString:titleSpace]];
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
