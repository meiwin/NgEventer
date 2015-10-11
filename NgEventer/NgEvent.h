//
//  NgEvent.h
//  NgEventer
//
//  Created by Meiwin Fu on 11/10/15.
//  Copyright © 2015 blockthirty. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NgEvent : NSObject
@property (nonatomic, strong, readonly) NSString    * name;
@property (nonatomic, strong, readonly) id          data;
@property (nonatomic, strong, readonly) NSError     * error;
@end
