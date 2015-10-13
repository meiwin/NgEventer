//
//  NSObject+NgEventer.m
//  NgEventer
//
//  Created by Meiwin Fu on 11/10/15.
//  Copyright © 2015 blockthirty. All rights reserved.
//

#import "NSObject+NgEventer.h"
#import <objc/runtime.h>

static void * NgEventer_NSObject_EventerKey = &NgEventer_NSObject_EventerKey;

@implementation NSObject (NgEventer)

- (NgEventer *)nge_eventer {
  
  NgEventer * eventer = objc_getAssociatedObject(self, NgEventer_NSObject_EventerKey);
  if (!eventer) {
    eventer = [[NgEventer alloc] init];
    objc_setAssociatedObject(self, NgEventer_NSObject_EventerKey, eventer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  }
  return eventer;
}

- (id<NgEventerObserverRegistry>)nge_eventNamed:(NSString *)name {
  return [[self nge_eventer] eventNamed:name];
}
- (void)nge_send:(NgEvent *)event {
  [[self nge_eventer] send:event];
}
- (void)nge_send:(NSString *)eventName data:(id)data error:(NSError *)error {
  [[self nge_eventer] send:eventName data:data error:error];
}
- (id<NgEventerEventPromise>)nge_performPromisedBlock:(NgEventerPromisedBlock)block {
  return [[self nge_eventer] performPromisedBlock:block];
}
- (id<NgEventerEventPromise>)nge_setupPromiseWithCallback:(id<NgEventerEventPromiseCancelDelegate> (^)(id<NgEventerEventPromiseCallback>))setupBlock {
  return [[self nge_eventer] setupPromiseWithCallback:setupBlock];
}

@end
