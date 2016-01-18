//
//  ParseTools.h
//  Parsing
//
//  Created by CYJ on 16/1/18.
//  Copyright © 2016年 CYJ. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ParseType) {
    ParseTypeOC,
    ParseTypeSwift,
};

@interface ParseTools : NSObject

+(ParseTools*)sharedInstance;

@property(nonatomic,assign)ParseType parseType;


+ (NSString *)parseDataToProerty:(id)obj;

@end
