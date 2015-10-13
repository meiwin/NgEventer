//
//  NSObject+NgEventer.h
//  NgEventer
//
//  Created by Meiwin Fu on 11/10/15.
//  Copyright © 2015 blockthirty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NgEventer.h"

@interface NSObject (NgEventer)

- (id<NgEventerObserverRegistry>)nge_eventNamed:(NSString *)name;
- (void)nge_send:(NSString *)eventName data:(id)data error:(NSError *)error;
- (void)nge_send:(NgEvent *)event;
- (id<NgEventerEventPromise>)nge_performPromisedBlock:(NgEventerPromisedBlock)block;
- (id<NgEventerEventPromise>)nge_setupPromiseWithCallback:(id<NgEventerEventPromiseCancelDelegate>(^)(id<NgEventerEventPromiseCallback>))setupBlock;

@end
