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

#pragma mark -
@interface NgEventPromise () {
  NSMutableSet * _handlers;
  NSMutableSet * _nge_handlers;
}
@property (nonatomic, strong) NgEventer                           * eventer;
@property (nonatomic, strong, readonly) NSMutableSet              * handlers;
@property (nonatomic, strong, readonly) NSMutableSet              * nge_handlers;
@property (nonatomic, strong) NgEventerPerformWithPromiseBlock    block;
@end

@implementation NgEventPromise

- (instancetype)initWithEventer:(NgEventer *)eventer
                          block:(NgEventerPerformWithPromiseBlock)block {
  NSParameterAssert(eventer);
  self = [super init];
  if (self) {
    self.eventer = eventer;
    self.block = block;
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
  NSParameterAssert(handler);
  NSAssert(![self isExecuting], @"Invalid state: executing.");
  NSAssert(![self isCancelled], @"Invalid state: cancelled.");
  NSAssert(![self isFinished], @"Invalid state: finished");
  
  [[self handlers] addObject:handler];
  return self;
}
- (id<NgEventerEventPromise>)nge_handle:(NgEventerEventPromiseNgeHandlerBlock)handler {
  NSParameterAssert(handler);
  NSAssert(![self isExecuting], @"Invalid state: executing.");
  NSAssert(![self isCancelled], @"Invalid state: cancelled.");
  NSAssert(![self isFinished], @"Invalid state: finished");

  [[self nge_handlers] addObject:handler];
  return self;
}

#pragma mark NgEventerEventPromiseCallback
- (void)send:(NSString *)eventName data:(id)data error:(NSError *)error {

  NSParameterAssert(eventName);
  NgEvent * event = [[NgEvent alloc] init];
  event.name = eventName;
  event.data = data;
  event.error = error;
  [self send:event];
}
- (void)send:(NgEvent *)event {

  [_handlers enumerateObjectsUsingBlock:^(NgEventerEventPromiseHandlerBlock  _Nonnull block, BOOL * _Nonnull stop) {
    block(event.name, event.data, event.error);
  }];
  
  [_nge_handlers enumerateObjectsUsingBlock:^(NgEventerEventPromiseNgeHandlerBlock  _Nonnull block, BOOL * _Nonnull stop) {
    block(event);
  }];

  [self.eventer send:event];
}

#pragma mark NSOperation
- (void)main {
  self.block(self);
}
- (BOOL)isConcurrent {
  return NO;
}
@end
