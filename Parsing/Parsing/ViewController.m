//
//  ViewController.m
//  Parsing
//
//  Created by CYJ on 16/1/18.
//  Copyright © 2016年 CYJ. All rights reserved.
//

#import "ViewController.h"

#define CLASS       @("\n@interface %@ :NSObject\n%@\n@end\n")
#define OC_PROPERTY(_strong)    ((_strong) == 'c' ? @("@property (nonatomic , copy) %@              * %@;\n") : @("@property (nonatomic , strong) %@              * %@;\n"))
#define OC_CLASS_M     @("@implementation %@\n\n@end\n")


#define SWIFT_CLASS @("\n@objc(%@)\nclass %@ :NSObject{\n%@\n}")
#define SWIFT_PROPERTY @("var %@: %@!;\n")

@interface ViewController()
{
    __weak IBOutlet NSTextField *classNameFiled;
    __weak IBOutlet NSTextField *jsonStringFiled;
    __weak IBOutlet NSButton    *swiftBox;

    
    __unsafe_unretained IBOutlet NSTextView *propertyTextView;
    __unsafe_unretained IBOutlet NSTextView *implementationTextView;
}

@property(nonatomic,copy)NSMutableString* classString;        //存类头文件内容
@property(nonatomic,copy)NSMutableString* classMString;       //存类源文件内容


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _classString = [NSMutableString new];
    _classMString = [NSMutableString new];
}

- (IBAction)clickActionMakePropertyString:(id)sender
{
    [_classString deleteCharactersInRange:NSMakeRange(0, _classString.length)];
    [_classMString deleteCharactersInRange:NSMakeRange(0, _classMString.length)];
    
    NSString  * className = classNameFiled.stringValue;
    NSString  * json = jsonStringFiled.stringValue;
    if(className == nil){
        className = @"CYJ";
    }
    if(className.length == 0){
        className = @"CYJ";
    }
    if(json && json.length){
        NSDictionary  * dict = nil;
        NSData  * jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
        dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:NULL];
        if(swiftBox.state == 0){
            [_classMString appendFormat:OC_CLASS_M,className];
            [_classString appendFormat:CLASS,className,[self parseDataToProerty:dict]];
        }else{
            NSString *str = [self parseDataToProerty:dict];
            [_classString appendFormat:SWIFT_CLASS,className,className,str];
        }
        
        propertyTextView.string = _classString;
        implementationTextView.string = _classMString;
        
    }else{
        NSAlert * alert = [NSAlert alertWithMessageText:@"WHC" defaultButton:@"确定" alternateButton:nil otherButton:nil informativeTextWithFormat:@"json或者xml数据不能为空"];
        [alert runModal];
    }
}



- (NSString *)parseDataToProerty:(id)object
{
    if (!object) {
        NSLog(@"obj不能为空！");
        return @"";
    }
    
    NSMutableString  * property = [NSMutableString new];
    if([object isKindOfClass:[NSDictionary class]]){
        NSDictionary  * dict = object;
        NSInteger       count = dict.count;
        NSArray       * keyArr = [dict allKeys];
        for (NSInteger i = 0; i < count; i++) {
            id subObject = dict[keyArr[i]];
            
            
            if([subObject isKindOfClass:[NSDictionary class]]){
                NSString * classContent = [self parseDataToProerty:subObject];
                if(swiftBox.state == 0){
                    [property appendFormat:OC_PROPERTY('s'),keyArr[i],keyArr[i]];
                    [_classString appendFormat:CLASS,keyArr[i],classContent];
                    [_classMString appendFormat:OC_CLASS_M,keyArr[i]];
                }else{
                    [property appendFormat:SWIFT_PROPERTY,keyArr[i],keyArr[i]];
                    [_classString appendFormat:SWIFT_CLASS,keyArr[i],keyArr[i],classContent];
                }
            }else if ([subObject isKindOfClass:[NSArray class]]){
                NSString * classContent = [self parseDataToProerty:subObject];
                if(swiftBox.state == 0){
                    [property appendFormat:OC_PROPERTY('s'),@"NSArray",keyArr[i]];
                    [_classString appendFormat:CLASS,keyArr[i],classContent];
                    [_classMString appendFormat:OC_CLASS_M,keyArr[i]];
                }else{
                    [property appendFormat:SWIFT_PROPERTY,keyArr[i],@"NSArray"];
                    [_classString appendFormat:SWIFT_CLASS,keyArr[i],keyArr[i],classContent];
                }
            }else if ([subObject isKindOfClass:[NSString class]]){
                if(swiftBox.state == 0){
                    [property appendFormat:OC_PROPERTY('c'),@"NSString",keyArr[i]];
                }else{
                    [property appendFormat:SWIFT_PROPERTY,keyArr[i],@"String"];
                }
            }else if ([subObject isKindOfClass:[NSNumber class]]){
                if(swiftBox.state == 0){
                    [property appendFormat:OC_PROPERTY('s'),@"NSNumber",keyArr[i]];
                }else{
                    [property appendFormat:SWIFT_PROPERTY,keyArr[i],@"NSNumber"];
                }
            }else{
                if(subObject == nil){
                    if(swiftBox.state == 0){
                        [property appendFormat:OC_PROPERTY('c'),@"NSString",keyArr[i]];
                    }else{
                        [property appendFormat:SWIFT_PROPERTY,keyArr[i],@"String"];
                    }
                }else if([subObject isKindOfClass:[NSNull class]]){
                    if(swiftBox.state == 0){
                        [property appendFormat:OC_PROPERTY('c'),@"NSString",keyArr[i]];
                    }else{
                        [property appendFormat:SWIFT_PROPERTY,keyArr[i],@"String"];
                    }
                }
            }
            
            
        }
    }else if ([object isKindOfClass:[NSArray class]]){
        NSArray  * dictArr = object;
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
            [property appendString:[self parseDataToProerty:tempObject]];
        }
    }
    
    return property;
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

@end
