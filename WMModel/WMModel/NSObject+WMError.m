//
//  NSObject+WMError.m
//  字典转模型
//
//  Created by kc on 16/8/1.
//  Copyright © 2016年 凯创信息技术服务有限公司. All rights reserved.
//

#import "NSObject+WMError.h"
void tryErroer(void(^block)(),void(^errorBlock)(NSException *)){

    @try {
        if (block) {
            block();
        }
    } @catch (NSException *exception) {
        if (errorBlock) {
            errorBlock(exception);
        }
        
    } @finally {
        
        
    }
}

@implementation NSObject (WMError)

@end
