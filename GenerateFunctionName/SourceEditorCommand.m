//
//  SourceEditorCommand.m
//  GenerateFunctionName
//
//  Created by 张东坡 on 2020/1/21.
//  Copyright © 2020 张东坡. All rights reserved.
//

#import "SourceEditorCommand.h"

@implementation SourceEditorCommand

- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler
{
    // Implement your command here, invoking the completion handler when done. Pass it nil on success, and an NSError on failure.
    NSMutableArray *selecteLines = invocation.buffer.selections;
    XCSourceTextRange *range = selecteLines[0];
    XCSourceTextPosition position = range.start;
    
    NSMutableArray *lines = invocation.buffer.lines;
    NSString *seleteLineString = lines[position.line];
    NSRange functionNameRange = [seleteLineString rangeOfString:@"(?<=\\[self ).*?(?=])" options:NSRegularExpressionSearch];
    if (functionNameRange.location != NSNotFound) {
        NSString *functionName = [seleteLineString substringWithRange:functionNameRange];
        NSMutableArray *array = [[functionName componentsSeparatedByString:@" "] mutableCopy];
        [array removeObject:@""];
        NSMutableArray *functionNameArray = @[].mutableCopy;
        for (NSString *functionName in array) {
            [functionNameArray addObject:[[functionName componentsSeparatedByString:@":"] firstObject]];
        }
        NSMutableString *mustring = @"".mutableCopy;
        if ([functionName containsString:@":"]) {
            mustring = @"- (void)".mutableCopy;
            for (NSString *functionName in functionNameArray) {
                [mustring appendFormat:@"%@:(<#Type#>)<#para#> ", functionName];
            }
            [mustring appendFormat:@"{\n\n}"];

        } else {
            mustring = @"- (void)".mutableCopy;
            for (NSString *functionName in functionNameArray) {
                [mustring appendFormat:@"%@ ",[functionName stringByReplacingOccurrencesOfString:@"\n" withString:@""]];
            }
            [mustring appendFormat:@"{\n\n}"];

        }
        NSInteger privateIndex = -1;
        if ([invocation.buffer.lines containsObject:@"// MARK: - Private Method\n"]) {
            NSInteger index = [invocation.buffer.lines indexOfObject:@"// MARK: - Private Method\n"];
            NSInteger insertIndex = -1;
            for (NSInteger i = index + 1; i < invocation.buffer.lines.count; i++) {
                if ([invocation.buffer.lines[i] containsString:@"// MARK"]) {
                    insertIndex = i - 1;
                    break;
                }
            }
            privateIndex = insertIndex;
        }
        if (privateIndex == -1) {
            privateIndex = invocation.buffer.lines.count - 1;
        }
        [invocation.buffer.lines insertObject:mustring atIndex:privateIndex];
    }
    completionHandler(nil);
}

@end
