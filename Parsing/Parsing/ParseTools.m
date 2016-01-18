//
//  ParseTools.m
//  Parsing
//
//  Created by CYJ on 16/1/18.
//  Copyright © 2016年 CYJ. All rights reserved.
//

#import "ParseTools.h"

#define DEFAULT_CLASS_NAME @("CYJ")
#define CLASS       @("\n@interface %@ :NSObject\n%@\n@end\n")
#define PROPERTY(_strong)    ((_strong) == 'c' ? @("@property (nonatomic , copy) %@              * %@;\n") : @("@property (nonatomic , strong) %@              * %@;\n"))
#define CLASS_M     @("@implementation %@\n\n@end\n")


#define SWIFT_CLASS @("\n@objc(%@)\nclass %@ :NSObject{\n%@\n}")
#define SWIFT_PROPERTY @("var %@: %@!;\n")

@implementation ParseTools

+(ParseTools*)sharedInstance
{
    static ParseTools *instance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

+ (NSString *)parseDataToProerty:(id)obj
{
    if (!obj) {
        NSLog(@"obj 为空");
        return  @"";
    }
    
    NSMutableString  * property = [NSMutableString new];
    
    //字典
    if ([obj isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary  * dict = obj;
        NSInteger       count = dict.count;
        NSArray       * keys = [dict allKeys];
        
        for (int i = 0; i < count; i++) {
            id subObject = dict[keys[i]];
            
            [property appendString:[ParseTools generatePropertyStringWithObj:subObject]];
            
        }

        
        
        //处理数组情况
    }else if ([obj isKindOfClass:[NSArray class]]){
        
        NSArray  * dictArr = obj;
        NSUInteger  count = dictArr.count;
        if(count){
            NSObject  * tempObject = dictArr[0];
            for (NSInteger i = 0; i < dictArr.count; i++) {
                NSObject * subObject = dictArr[i];
                if([subObject isKindOfClass:[NSDictionary class]]){
                    if(((NSDictionary *)subObject).count > ((NSDictionary *)tempObject).count){
                        tempObject = subObject;
                    }
                }
                if([subObject isKindOfClass:[NSDictionary class]]){
                    if(((NSArray *)subObject).count > ((NSArray *)tempObject).count){
                        tempObject = subObject;
                    }
                }
            }
            [property appendString:[ParseTools parseDataToProerty:obj]];
        }
    }
    
    
    
    return property;
}

+ (NSString *)generatePropertyStringWithObj:(id)subObject
{
    NSString *properTyString;
    
    
    
    
    return properTyString;
}


//+()

@end
