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

#pragma mark -
@interface NgEventer : NSObject
<NgEventerEventRegistry
, NgEventerEventDelivery
, NgEventerPerformWithPromise>
@end