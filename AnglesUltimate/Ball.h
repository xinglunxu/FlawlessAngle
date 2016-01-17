//
//  Ball.h
//  AnglesUltimate
//
//  Created by xinglunxu on 9/20/15.
//  Copyright (c) 2015 xinglunxu. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Ball : SKSpriteNode

-(id)initWithBallImage:(NSString *) name;
-(float)getVector_X;
-(float)getVector_Y;
-(void)moveTowardsPoint:(int)x secondvalue:(int)y;
-(void) Collide:(float) x1 secondvalue:(float) y1 thirdvalue:(float) x2 finalvalue:(float) y2;
- (void) speedUp;
- (void) speedUpTowardPoint:(CGPoint)p;
-(SKAction*)returnPreviousAction;
- (SKAction *) getBallMovingAction:(int)factor;
+(int)getBallNormalTurnSpeed;
+(int)getBallFastTurnSpeed;
-(int)getAttack;
-(void)resetTurnDamage;
-(void)turnDamageWeaken:(int)n;
-(int)getTurnDamageLeft;
-(void)increaseAttack;
-(void)reset;
-(bool)damaged;
@end
