//
//  NgEventPromise.m
//  NgEventer
//
//  Created by Meiwin Fu on 11/10/15.
//  Copyright © 2015 blockthirty. All rights reserved.
//

#import "NgEventPromise.h"
#import "NgEvent.h"
#import "NgEventSetter.h"
#import "NgEventer.h"

typedef NS_ENUM(int32_t, NgEventPromiseQueue) {
  NgEventPromiseQueueCurrent,
  NgEventPromiseQueueMain,
  NgEventPromiseQueueBackground
};

#pragma mark -
@interface NgEventPromise () {
  NSMutableSet * _handlers;
  NSMutableSet * _nge_handlers;
}
@property (nonatomic, strong) NgEventer                           * eventer;
@property (nonatomic, strong, readonly) NSMutableSet              * handlers;
@property (nonatomic, strong, readonly) NSMutableSet              * nge_handlers;
@end

@implementation NgEventPromise

- (instancetype)initWithEventer:(NgEventer *)eventer {
  
  NSParameterAssert(eventer);
  self = [super init];
  if (self) {
    self.eventer = eventer;
  }
  return self;
}
#pragma mark Handlers (lazy loading)
- (NSMutableSet *)handlers {
  if (!_handlers) {
    _handlers = [NSMutableSet set];
  }
  return _handlers;
}
- (NSMutableSet *)nge_handlers {
  if (!_nge_handlers) {
    _nge_handlers = [NSMutableSet set];
  }
  return _nge_handlers;
}

#pragma mark NgEventerEventPromise
- (id<NgEventerEventPromise>)handle:(NgEventerEventPromiseHandlerBlock)handler {
  [self handle:handler queue:NgEventPromiseQueueCurrent];
  return self;
}
- (id<NgEventerEventPromise>)handleInBackground:(NgEventerEventPromiseHandlerBlock)handler {
  [self handle:handler queue:NgEventPromiseQueueBackground];
  return self;
}
- (id<NgEventerEventPromise>)handleInMainThread:(NgEventerEventPromiseHandlerBlock)handler {
  [self handle:handler queue:NgEventPromiseQueueMain];
  return self;
}
- (id<NgEventerEventPromise>)handle:(NgEventerEventPromiseHandlerBlock)handler queue:(NgEventPromiseQueue)queue {

  NSParameterAssert(handler);
  [[self handlers] addObject:@{
                               @"handler" : handler,
                               @"queue" : @(queue)
                               }];
  return self;
}
- (id<NgEventerEventPromise>)nge_handle:(NgEventerEventPromiseNgeHandlerBlock)handler {
  [self nge_handle:handler queue:NgEventPromiseQueueCurrent];
  return self;
}
- (id<NgEventerEventPromise>)nge_handleInMainThread:(NgEventerEventPromiseNgeHandlerBlock)handler {
  [self nge_handle:handler queue:NgEventPromiseQueueMain];
  return self;
}
- (id<NgEventerEventPromise>)nge_handleInBackground:(NgEventerEventPromiseNgeHandlerBlock)handler {
  [self nge_handle:handler queue:NgEventPromiseQueueBackground];
  return self;
}
- (id<NgEventerEventPromise>)nge_handle:(NgEventerEventPromiseNgeHandlerBlock)handler queue:(NgEventPromiseQueue)queue {
  NSParameterAssert(handler);
  [[self nge_handlers] addObject:@{
                                   @"handler" : handler,
                                   @"queue" : @(queue)
                                   }];
  return self;
}

#pragma mark NgEventerEventPromiseCallback
- (void)send:(NSString *)eventName data:(id)data error:(NSError *)error {

  NgEvent * event = [[NgEvent alloc] init];
  event.name = eventName;
  event.data = data;
  event.error = error;
  [self send:event];
}
- (void)_send:(NSDictionary *)dic event:(NgEvent *)event {

  int32_t queue = [dic[@"queue"] intValue];
  NgEventerEventPromiseHandlerBlock block = dic[@"handler"];
  if (queue == NgEventPromiseQueueCurrent) block(event.name, event.data, event.error);
  else {
    dispatch_queue_t dispatchQueue = nil;
    if (queue == NgEventPromiseQueueMain) dispatchQueue = dispatch_get_main_queue();
    else if (queue == NgEventPromiseQueueBackground) {
      if (self.eventer.backgroundQueue) dispatchQueue = self.eventer.backgroundQueue;
      else dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
      dispatch_async(dispatchQueue, ^{
        block(event.name, event.data, event.error);
      });
    }
  }
}
- (void)_nge_send:(NSDictionary *)dic event:(NgEvent *)event {

  int32_t queue = [dic[@"queue"] intValue];
  NgEventerEventPromiseNgeHandlerBlock block = dic[@"handler"];
  if (queue == NgEventPromiseQueueCurrent) block(event);
  else {
    dispatch_queue_t dispatchQueue = nil;
    if (queue == NgEventPromiseQueueMain) dispatchQueue = dispatch_get_main_queue();
    else if (queue == NgEventPromiseQueueBackground) {
      if (self.eventer.backgroundQueue) dispatchQueue = self.eventer.backgroundQueue;
      else dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
      dispatch_async(dispatchQueue, ^{
        block(event);
      });
    }
  }
}
- (void)send:(NgEvent *)event {

  [_handlers enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull dic, BOOL * _Nonnull stop) {
    [self _send:dic event:event];
  }];
  
  [_nge_handlers enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull dic, BOOL * _Nonnull stop) {
    [self _nge_send:dic event:event];
  }];

  if (event.name && event.name.length > 0) {
    [self.eventer send:event];
  }
}

#pragma mark Cancelling
- (void)cancel {}

@end

#pragma mark -
@implementation NgEventCancelablePromise

- (void)cancel {
  
  __strong id strongDelegate = self.delegate;
  if (!strongDelegate) return;
  
  if ([strongDelegate respondsToSelector:@selector(cancel)]) {
    [strongDelegate cancel];
  }
}
@end