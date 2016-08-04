//
//  NSObject+WMError.h
//  字典转模型
//
//  Created by kc on 16/8/1.
//  Copyright © 2016年 凯创信息技术服务有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

void tryErroer(void(^block)(),void(^errorBlock)(NSException *));

@interface NSObject (WMError)



@end
