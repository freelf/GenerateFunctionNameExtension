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
    NSString *functionName = [[seleteLineString stringByReplacingOccurrencesOfString:@"[self" withString:@""] stringByReplacingOccurrencesOfString:@"];" withString:@""];
    
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
        privateIndex = [invocation.buffer.lines indexOfObject:@"// MARK: - Private Method\n"] + 1;
    }
    if (privateIndex == -1) {
        privateIndex = invocation.buffer.lines.count - 1;
    }
    
    [invocation.buffer.lines insertObject:mustring atIndex:privateIndex];
    completionHandler(nil);
}

@end
