/**
 * Copyright Maarten Billemont (http://www.lhunath.com, lhunath@lyndir.com)
 *
 * See the enclosed file LICENSE for license information (LGPLv3). If you did
 * not receive this file, see http://www.gnu.org/licenses/lgpl-3.0.txt
 *
 * @author   Maarten Billemont <lhunath@lyndir.com>
 * @license  http://www.gnu.org/licenses/lgpl-3.0.txt
 */

//
//  StringUtils.m
//  Pearl
//
//  Created by Maarten Billemont on 05/11/09.
//  Copyright 2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "PearlStringUtils.h"

NSString *strf(NSString *format, ...) {

    if (!format)
        return nil;

    va_list argList;
    va_start( argList, format );
    NSString *string = [[NSString alloc] initWithFormat:format arguments:argList];
    va_end( argList );

    return string;
}

NSString *strl(NSString *format, ...) {

    if (!format)
        return nil;

    va_list argList;
    va_start( argList, format );
    NSString *msg = [[NSString alloc] initWithFormat:[[NSBundle mainBundle] localizedStringForKey:format value:nil table:nil]
                                           arguments:argList];
    va_end( argList );

    return msg;
}

NSString *strtl(NSString *tableName, NSString *format, ...) {

    if (!format)
        return nil;

    va_list argList;
    va_start( argList, format );
    NSString *msg = [[NSString alloc] initWithFormat:[[NSBundle mainBundle] localizedStringForKey:format value:nil table:tableName]
                                           arguments:argList];
    va_end( argList );

    return msg;
}

NSMutableAttributedString *stra(id string, NSDictionary *attributes) {

    if (!string)
        return nil;
    if ([string isKindOfClass:[NSMutableAttributedString class]]) {
        [string addAttributes:attributes range:NSMakeRange( 0, [string length] )];
        return string;
    }
    if ([string isKindOfClass:[NSAttributedString class]])
        return stra( [string mutableCopy], attributes );
    if ([string isKindOfClass:[NSString class]])
        return [[NSMutableAttributedString alloc] initWithString:string attributes:attributes];
    return stra( [string description], attributes );
}

NSMutableAttributedString *strra(id string, NSRange range, NSDictionary *attributes) {

    if (!string)
        return nil;
    if ([string isKindOfClass:[NSMutableAttributedString class]]) {
        [string addAttributes:attributes range:range];
        return string;
    }
    if ([string isKindOfClass:[NSAttributedString class]])
        return strra( [string mutableCopy], range, attributes );
    if ([string isKindOfClass:[NSString class]])
        return strra( [[NSMutableAttributedString alloc] initWithString:string], range, attributes );
    return strra( [string description], range, attributes );
}

NSMutableAttributedString *strarm(id string, id attributes, ...) {

    if (!string)
        return nil;
    if ([string isKindOfClass:[NSMutableAttributedString class]]) {
        va_list attributesList;
        va_start( attributesList, attributes );
        for (id attribute = attributes; attribute; attribute = va_arg( attributesList, id ))
            [string removeAttribute:attribute range:NSMakeRange( 0, [string length] )];
        va_end( attributesList );
        return string;
    }
    if ([string isKindOfClass:[NSAttributedString class]])
        return stra( [string mutableCopy], attributes );
    if ([string isKindOfClass:[NSString class]])
        return [[NSMutableAttributedString alloc] initWithString:string];
    return [[NSMutableAttributedString alloc] initWithString:[string description]];
}

NSMutableAttributedString *straf(id format, ...) {

    if (!format)
        return nil;

    NSMutableAttributedString *attributedString = [format isKindOfClass:[NSMutableAttributedString class]]? format:
                                                  [format isKindOfClass:[NSAttributedString class]]?
                                                  [[NSMutableAttributedString alloc] initWithAttributedString:format]:
                                                  [[NSMutableAttributedString alloc] initWithString:[format description]];

    va_list __list;
    va_start( __list, format );
    NSRange searchRange = NSMakeRange( 0, [attributedString length] );
    for (id __object; (__object = va_arg( __list, id ));) {
        NSRange injectionRange = [[attributedString string] rangeOfString:@"%@" options:0 range:searchRange];
        if (injectionRange.location == NSNotFound)
            break;

        if ([__object isKindOfClass:[NSAttributedString class]]) {
            NSAttributedString *injectionString = __object;
            [attributedString replaceCharactersInRange:injectionRange withAttributedString:injectionString];
            searchRange.location = injectionRange.location + [injectionString length];
        }
        else {
            NSString *injectionString = [__object isKindOfClass:[NSString class]]? __object: [__object description];
            [attributedString replaceCharactersInRange:injectionRange withString:injectionString];
            searchRange.location = injectionRange.location + [injectionString length];
        }

        searchRange.length = [attributedString length] - searchRange.location;
    }
    va_end( __list );

    return attributedString;
}

NSString *RPad(const NSString *string, const NSUInteger l) {

    NSMutableString *newString = [string mutableCopy];
    while (newString.length < l)
        [newString appendString:@" "];

    return newString;
}

NSString *LPad(const NSString *string, const NSUInteger l) {

    NSMutableString *newString = [string mutableCopy];
    while (newString.length < l)
        [newString insertString:@" " atIndex:0];

    return newString;
}

@implementation NSString(PearlStringUtils)

- (NSString *)stringByDeletingMatchesOf:(NSString *)pattern {

    NSError *error = nil;
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                                options:0 error:&error];
    if (error) {
        NSLog( @"Couldn't compile pattern: %@, reason: %@", pattern, error );
        return nil;
    }

    return [self stringByDeletingMatchesOfExpression:expression];
}

- (NSString *)stringByDeletingMatchesOfExpression:(NSRegularExpression *)expression {

    return [self stringByReplacingMatchesOfExpression:expression withTemplate:@""];
}

- (NSString *)stringByReplacingMatchesOf:(NSString *)pattern withTemplate:(NSString *)templ {

    NSError *error = nil;
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                                options:0 error:&error];
    if (error) {
        NSLog( @"Couldn't compile pattern: %@, reason: %@", pattern, error );
        return nil;
    }

    return [self stringByReplacingMatchesOfExpression:expression withTemplate:templ];
}

- (NSString *)stringByReplacingMatchesOfExpression:(NSRegularExpression *)expression withTemplate:(NSString *)templ {

    return [expression stringByReplacingMatchesInString:self options:0 range:NSMakeRange( 0, self.length ) withTemplate:templ];
}

- (NSArray *)firstMatchGroupsOfExpression:(NSRegularExpression *)expression {

    NSTextCheckingResult *result = [expression firstMatchInString:self options:0 range:NSMakeRange( 0, self.length )];
    NSMutableArray *groups = [NSMutableArray arrayWithCapacity:result.numberOfRanges];
    for (NSUInteger g = 0; g < result.numberOfRanges; ++g) {
        NSRange range = [result rangeAtIndex:g];
        [groups addObject:range.location == NSNotFound? [NSNull null]: [self substringWithRange:range]];
    }

    return groups;
}

@end
