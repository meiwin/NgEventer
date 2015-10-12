//
//  NgEventPromise.h
//  NgEventer
//
//  Created by Meiwin Fu on 11/10/15.
//  Copyright © 2015 blockthirty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NgEventerProtocols.h"

#pragma mark -
@class NgEventer;
@interface NgEventPromise : NSObject
< NgEventerEventPromise
, NgEventerEventPromiseCallback >

@property (nonatomic, strong, readonly) NgEventer     * eventer;
- (instancetype)init __unavailable;
- (instancetype)initWithEventer:(NgEventer *)eventer;
@end

#pragma mark -
@interface NgEventCancelablePromise : NgEventPromise
@property (nonatomic, weak) id<NgEventerEventPromiseCancelDelegate>  delegate;
@end
