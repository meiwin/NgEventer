//
//  NgEventSetter.h
//  NgEventer
//
//  Created by Meiwin Fu on 11/10/15.
//  Copyright © 2015 blockthirty. All rights reserved.
//

#ifndef NgEventSetter_h
#define NgEventSetter_h

@interface NgEvent (Setter)
- (void)setName:(NSString *)name;
- (void)setData:(id)data;
- (void)setError:(NSError *)error;
@end

#endif /* NgEventSetter_h */
