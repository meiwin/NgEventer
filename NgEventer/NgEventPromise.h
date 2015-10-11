//
//  NgEventPromise.h
//  NgEventer
//
//  Created by Meiwin Fu on 11/10/15.
//  Copyright © 2015 blockthirty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NgEventerProtocols.h"

@class NgEventer;
@interface NgEventPromise : NSOperation
<NgEventerEventPromise
, NgEventerEventPromiseCallback>

@property (nonatomic, strong, readonly) NgEventer     * eventer;
- (instancetype)init __unavailable;
- (instancetype)initWithEventer:(NgEventer *)eventer
                          block:(NgEventerPerformWithPromiseBlock)block;
@end
