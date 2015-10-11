//
//  NgEventerProtocols.h
//  NgEventer
//
//  Created by Meiwin Fu on 11/10/15.
//  Copyright © 2015 blockthirty. All rights reserved.
//

#ifndef NgEventerProtocols_h
#define NgEventerProtocols_h


#pragma mark -
@protocol NgEventerObserverRegistry <NSObject>
@required
- (void)addObserver:(id)observer;
- (void)addObserver:(id)observer action:(SEL)action;
- (void)addObserverInMainThread:(id)observer;
- (void)addObserverInMainThread:(id)observer action:(SEL)action;
- (void)addObserverInBackground:(id)observer;
- (void)addObserverInBackground:(id)observer action:(SEL)action;
- (void)removeObserver:(id)observer;
@end

#pragma mark -
@protocol NgEventerEventRegistry <NSObject>
@required
- (id<NgEventerObserverRegistry>)eventNamed:(NSString *)name;
@end

#pragma mark -
@class NgEvent;
@protocol NgEventerEventDelivery <NSObject>
@required
- (void)send:(NSString *)eventName data:(id)data error:(NSError *)error;
- (void)send:(NgEvent *)event;
@end

#pragma mark -
@class NgEvent;
typedef void(^NgEventerEventPromiseNgeHandlerBlock)(NgEvent *);
typedef void(^NgEventerEventPromiseHandlerBlock)(NSString *, id result, NSError *);
@protocol NgEventerEventPromise <NSObject>
@required

- (id<NgEventerEventPromise>)nge_handle:(NgEventerEventPromiseNgeHandlerBlock)handler;
- (id<NgEventerEventPromise>)handle:(NgEventerEventPromiseHandlerBlock)handler;

- (id<NgEventerEventPromise>)nge_handleInMainThread:(NgEventerEventPromiseNgeHandlerBlock)handler;
- (id<NgEventerEventPromise>)handleInMainThread:(NgEventerEventPromiseHandlerBlock)handler;

- (id<NgEventerEventPromise>)nge_handleInBackground:(NgEventerEventPromiseNgeHandlerBlock)handler;
- (id<NgEventerEventPromise>)handleInBackground:(NgEventerEventPromiseHandlerBlock)handler;
- (void)cancel;
@end

#pragma mark -
@protocol NgEventerEventPromiseCallback <NgEventerEventDelivery>
@end

#pragma mark -
typedef void(^NgEventerPerformWithPromiseBlock)(id<NgEventerEventPromiseCallback> callback);
@protocol NgEventerPerformWithPromise <NSObject>
- (id<NgEventerEventPromise>)performWithPromise:(NgEventerPerformWithPromiseBlock)block;
@end

#endif /* NgEventerProtocols_h */
