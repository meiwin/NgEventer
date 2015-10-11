//
//  NgEventer.m
//  NgEventer
//
//  Created by Meiwin Fu on 11/10/15.
//  Copyright © 2015 blockthirty. All rights reserved.
//

#import "NgEventer.h"
#import "NgEventPromise.h"
#import "NgEventSetter.h"

typedef NS_ENUM(int32_t, NgEventerObserverQueue) {
  NgEventerObserverQueueCurrent,
  NgEventerObserverQueueMain,
  NgEventerObserverQueueBackground
};

#pragma mark -
@interface NgEventerObserver : NSObject
@property (nonatomic, weak, readonly) id            target;
@property (nonatomic, readonly) SEL                 action;
@property (nonatomic, strong, readonly) NSString    * targetActionDescriptor;
@property (nonatomic) NgEventerObserverQueue        queue;

- (instancetype)init __unavailable;
- (instancetype)initWithTarget:(id)target action:(SEL)action queue:(NgEventerObserverQueue)queue;
- (void)send:(NgEvent *)event eventer:(NgEventer *)eventer backgroundQueue:(dispatch_queue_t)backgroundQueue;
@end

@implementation NgEventerObserver
- (instancetype)initWithTarget:(id)target action:(SEL)action queue:(NgEventerObserverQueue)queue {

  NSParameterAssert(target);
  
  self = [super init];
  if (self) {

    _target = target;
    _action = action;
    _targetActionDescriptor = [NSString stringWithFormat:@"[%p]-%@",
                               target,
                               action ? NSStringFromSelector(action) : @"nil"];
    _queue = queue;
  }
  return self;
}
- (id)safeTarget {
  __strong id safeTarget = self.target;
  return safeTarget;
}

#pragma mark Sending event
- (void)send:(NgEvent *)event eventer:(NgEventer *)eventer backgroundQueue:(dispatch_queue_t)backgroundQueue {
  
  id safeTarget = [self safeTarget];
  if (!safeTarget) return;

  SEL selector = self.action;
  if (!selector) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    selector = @selector(eventer:didFireEvent:);
#pragma clang diagnostic
  }
  
  if ([safeTarget respondsToSelector:selector]) {
    
    NSMethodSignature * sig = [safeTarget methodSignatureForSelector:selector];
    IMP imp = [safeTarget methodForSelector:selector];

    BOOL shouldDispatch = self.queue != NgEventerObserverQueueCurrent;
    dispatch_queue_t dispatchQueue = nil;
    if (self.queue == NgEventerObserverQueueBackground) {
      if (backgroundQueue) dispatchQueue = backgroundQueue;
      else dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    } else if (self.queue == NgEventerObserverQueueMain) {
      dispatchQueue = dispatch_get_main_queue();
    }
    
    if ([sig numberOfArguments] == 3) {

      void(*m)(id, SEL, NgEvent *) = (void *)imp;
      if (shouldDispatch) {
        dispatch_async(dispatchQueue, ^{
          m(safeTarget, selector, event);
        });
      } else {
        m(safeTarget, selector, event);
      }
      
    } else if ([sig numberOfArguments] == 4) {
      
      void(*m)(id, SEL, NgEventer *, NgEvent *) = (void *)imp;
      if (shouldDispatch) {
        dispatch_async(dispatchQueue, ^{
          m(safeTarget, selector, eventer, event);
        });
      } else {
        m(safeTarget, selector, eventer, event);
      }
    }
  }
}

#pragma mark Equality
- (NSUInteger)hash {
  return [self.targetActionDescriptor hash];
}
- (BOOL)isEqual:(id)object {
  if ([object isKindOfClass:[NgEventerObserver class]]) {
    NgEventerObserver * other = (NgEventerObserver *)object;
    return [self.targetActionDescriptor isEqual:other.targetActionDescriptor];
  }
  return NO;
}
@end

#pragma mark -
@interface NgEventerObserverRegistry : NSObject <NgEventerObserverRegistry>
@property (nonatomic, strong, readonly) NSString          * name;
@property (nonatomic, strong, readonly) NSRecursiveLock   * observersLock;
@property (nonatomic, strong, readonly) NSSet             * observers;
- (instancetype)init __unavailable;
- (instancetype)initWithName:(NSString *)name;
- (void)send:(NgEvent *)event eventer:(NgEventer *)eventer backgroundQueue:(dispatch_queue_t)backgroundQueue;
@end

@implementation NgEventerObserverRegistry

- (instancetype)initWithName:(NSString *)name {

  NSParameterAssert(name);
  
  self = [super init];
  if (self) {
    _name = name;
    _observersLock = [[NSRecursiveLock alloc] init];
  }
  return self;
}

#pragma mark NgEventerObserverRegistry
- (void)addObserver:(id)observer {
  [self addObserver:observer action:NULL];
}
- (void)addObserver:(id)observer action:(SEL)action {
  [self addObserver:observer action:action queue:NgEventerObserverQueueCurrent];
}
- (void)addObserverInMainThread:(id)observer {
  [self addObserverInMainThread:observer action:NULL];
}
- (void)addObserverInMainThread:(id)observer action:(SEL)action {
  [self addObserver:observer action:action queue:NgEventerObserverQueueMain];
}
- (void)addObserverInBackground:(id)observer {
  [self addObserverInBackground:observer action:NULL];
}
- (void)addObserverInBackground:(id)observer action:(SEL)action {
  [self addObserver:observer action:action queue:NgEventerObserverQueueBackground];
}
- (void)addObserver:(id)target action:(SEL)action queue:(NgEventerObserverQueue)queue {
  
  NgEventerObserver * observer = [[NgEventerObserver alloc] initWithTarget:target action:action queue:queue];
  [self.observersLock lock];
  NSMutableSet * observers = [NSMutableSet setWithSet:self.observers];
  [observers addObject:observer];
  _observers = observers;
  [self.observersLock unlock];
}
- (void)removeObserver:(id)observer {

  [self.observersLock lock];
  NSMutableSet * observers = [NSMutableSet setWithSet:self.observers];
  [observers filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NgEventerObserver *  _Nonnull evaluatedObserver, NSDictionary<NSString *,id> * _Nullable bindings) {
    return evaluatedObserver.target != observer;
  }]];
  _observers = observers;
  [self.observersLock unlock];
}

#pragma mark Sending Event
- (void)send:(NgEvent *)event eventer:(NgEventer *)eventer backgroundQueue:(dispatch_queue_t)backgroundQueue {
  
  [self.observers enumerateObjectsUsingBlock:^(NgEventerObserver *  _Nonnull observer, BOOL * _Nonnull stop) {
    [observer send:event eventer:eventer backgroundQueue:backgroundQueue];
  }];
}
@end

#pragma mark -
@interface NgEventer ()
@property (nonatomic, strong) NSRecursiveLock         * registryLock;
@property (nonatomic, strong) NSMutableDictionary     * registries;
@property (nonatomic, strong) NSOperationQueue        * promisesOperationQueue;
@end

@implementation NgEventer

- (instancetype)init {
  self = [super init];
  if (self) {
    self.registryLock = [[NSRecursiveLock alloc] init];
    self.registries = [NSMutableDictionary dictionary];
    
    self.promisesOperationQueue = [[NSOperationQueue alloc] init];
    self.promisesOperationQueue.maxConcurrentOperationCount = 3;
  }
  return self;
}
- (void)dealloc {
  
  [self.promisesOperationQueue cancelAllOperations];
  self.promisesOperationQueue = nil;
  self.registries = nil;
}

#pragma mark NgEventerEventRegistry
- (id<NgEventerObserverRegistry>)eventNamed:(NSString *)name {
  NSParameterAssert(name);
  [self.registryLock lock];
  id<NgEventerObserverRegistry> registry = self.registries[name];
  if (!registry) {
    registry = [[NgEventerObserverRegistry alloc] initWithName:name];
    self.registries[name] = registry;
  }
  [self.registryLock unlock];
  return registry;
}

#pragma mark NgEventerEventDelivery
- (void)send:(NSString *)eventName data:(id)data error:(NSError *)error {
  NSParameterAssert(eventName);
  
  NgEventerObserverRegistry * registry = self.registries[eventName];
  if (registry) {
    NgEvent * event = [[NgEvent alloc] init];
    event.name = eventName;
    event.data = data;
    event.error = error;
    [self send:event];
  }
}
- (void)send:(NgEvent *)event {
  
  NgEventerObserverRegistry * registry = self.registries[event.name];
  [registry send:event eventer:self backgroundQueue:self.backgroundQueue];
}

#pragma mark NgEventerPerformWithPromise
- (id<NgEventerEventPromise>)performWithPromise:(NgEventerPerformWithPromiseBlock)block {
  
  NgEventPromise * promise = [[NgEventPromise alloc] initWithEventer:self block:block];
  dispatch_async(dispatch_get_main_queue(), ^{
    if (![promise isCancelled]) {
      [self.promisesOperationQueue addOperation:promise];
    }
  });
  return promise;
}

@end
