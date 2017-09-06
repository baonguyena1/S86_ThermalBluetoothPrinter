//
//  PrinterFormat.h
//  BTDemoCJ
//
//  Created by Bao Nguyen on 9/6/17.
//

#define CHAR_NORMAL_PER_LINE         48
#define CHAR_DOUBLE_PER_LINE         24
#define CHAR_SMALL_PER_LINE          72

#import <Foundation/Foundation.h>

@interface PrinterFormat : NSObject

+ (NSString *)printTitle:(NSString *)title;

+ (NSString *)printOrderNumber:(NSString *)orderNumber title:(NSString *)mTitle price:(NSString *)mPrice;

@end
