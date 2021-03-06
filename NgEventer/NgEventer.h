//
//  NgEventer.h
//  NgEventer
//
//  Created by Meiwin Fu on 11/10/15.
//  Copyright © 2015 blockthirty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NgEventerProtocols.h"
#import "NgEvent.h"

#import "NSOperation+NgEventer.h"
#import "NSURLSessionTask+NgEventer.h"

#pragma mark -
@interface NgEventer : NSObject
< NgEventerEventRegistry
, NgEventerEventDelivery
, NgEventerPerformPromise >

@property (nonatomic, strong) dispatch_queue_t  backgroundQueue;
@end