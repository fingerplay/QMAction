//
//  MacroDefine.h
//  QMActionDemo
//
//  Created by 罗谨 on 2018/10/19.
//  Copyright © 2018年 juanpi. All rights reserved.
//


#ifndef dispatch_queue_async_safe
#define dispatch_queue_async_safe(queue, block)\
if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(queue)) == 0) {\
block();\
} else {\
dispatch_async(queue, block);\
}
#endif

#ifndef dispatch_main_async_safe
#define dispatch_main_async_safe(block) dispatch_queue_async_safe(dispatch_get_main_queue(), block)
#endif

#ifndef dispatch_queue_sync_safe
#define dispatch_queue_sync_safe(queue, block)\
if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(queue)) == 0) {\
block();\
} else {\
dispatch_sync(queue, block);\
}
#endif

#ifndef dispatch_main_sync_safe
#define dispatch_main_sync_safe(block) dispatch_queue_sync_safe(dispatch_get_main_queue(), block)
#endif


