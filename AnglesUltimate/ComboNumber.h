//
//  ComboNumber.h
//  AnglesUltimate
//
//  Created by xinglunxu on 9/25/15.
//  Copyright © 2015 xinglunxu. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface ComboNumber : SKLabelNode
-(id)initWithSize:(CGSize)size;
-(void)combo:(int)n;
-(void)comboLost:(CGPoint)p;
@end
