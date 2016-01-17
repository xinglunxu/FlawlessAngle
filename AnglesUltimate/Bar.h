//
//  Bar.h
//  AnglesUltimate
//
//  Created by xinglunxu on 9/20/15.
//  Copyright (c) 2015 xinglunxu. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>


@interface Bar : SKSpriteNode


-(id)initWithDirection:(int) direction SecondValue:(CGSize)frame;
+(int)adjustDirection:(int)direnction;
-(int)getDirection;
-(void)gone;
-(int)weakened:(int)damage;
-(int)damaged:(int)damage;
-(int)getLifePoint;
-(CGPoint)getDestinationP;
@end
