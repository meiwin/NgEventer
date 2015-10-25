//
//  NgEvent.m
//  NgEventer
//
//  Created by Meiwin Fu on 11/10/15.
//  Copyright © 2015 blockthirty. All rights reserved.
//

#import "NgEvent.h"

@interface NgEvent ()
@property (nonatomic, strong) NSString      * name;
@property (nonatomic, strong) id            data;
@property (nonatomic, strong) NSError       * error;
@end

@implementation NgEvent
- (NSString *)description {
  return [NSString stringWithFormat:@"(NgEvent) { name = %@, error = %@, data = %@}",
          self.name, self.error, self.data];
}
@end
