//
//  Ball.m
//  AnglesUltimate
//
//  Created by xinglunxu on 9/20/15.
//  Copyright (c) 2015 xinglunxu. All rights reserved.
//

#import "Ball.h"

float Vector_X;
float Vector_Y;
float speed;
float speed_;
SKAction *ballMoveAction;
int attack;
int turnDamage;
int minorAttack;
int lifePoints;


const int BALLWIDTH = 20;
const int BALLHEIGHT = 20;
const float SPEEDUP = 9.5;
const int TURN_SPEED = 1000;
static const int TURN_SPEED_SUPER = 3;
static const int TURN_SPEED_FAST = 2;
static const int TURN_SPEED_NORMAL = 1;

@implementation Ball

-(id)initWithBallImage:(NSString *) name {
    self = [super initWithImageNamed:name];
    self.size = CGSizeMake(BALLWIDTH, BALLHEIGHT);
    self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.size.width-5,self.size.height-5)];
    Vector_X = -5000;
    Vector_Y = 0;
    speed = sqrt(pow(Vector_X,2) + pow(Vector_Y,2));
    speed_ = 0.5;
    ballMoveAction = [self getBallMovingAction:1];
    lifePoints = 5;
    attack = 1;
    minorAttack = 0;
    turnDamage = 1;
    return self;
}

-(float)getVector_X{ return Vector_X;}
-(float)getVector_Y{return Vector_Y;}

-(void)moveTowardsPoint:(int)x secondvalue:(int)y
{
    float vector_x = x - self.position.x;
    float vector_y = y - self.position.y;
    float factor = sqrt(pow(speed, 2)/(pow(vector_x, 2)+pow(vector_y, 2)));
    Vector_X = vector_x * factor;
    Vector_Y = vector_y * factor;
    [self removeAllActions];
    [self runAction:[SKAction moveByX:Vector_X*speed_ y:Vector_Y*speed_ duration:100]];
    [self runAction:ballMoveAction];
}


-(void) Collide:(float) x1 secondvalue:(float) y1 thirdvalue:(float) x2 finalvalue:(float) y2
{
    float A = y1 - y2, B = x2 - x1, C = 0;
    float OldVectorX = Vector_X, OldVectorY = Vector_Y;
    Vector_X = ((pow(B,2)-pow(A,2))*OldVectorX-2*A*B*OldVectorY-2*A*C)/(pow(A,2) + pow(B,2));
    Vector_Y = ((pow(A,2)-pow(B,2))*OldVectorY-2*A*B*OldVectorX-2*B*C)/(pow(A,2) + pow(B,2));
    [self removeAllActions];
    [self runAction:[SKAction moveByX:Vector_X*SPEEDUP y:Vector_Y*SPEEDUP duration:100]];
    [self runAction:[self getBallMovingAction:TURN_SPEED_FAST]];
}

- (void) speedUp
{
    [self removeAllActions];
    [self runAction:[SKAction moveByX:Vector_X*SPEEDUP y:Vector_Y*SPEEDUP duration:100]];
    [self runAction:[self getBallMovingAction:TURN_SPEED_SUPER]];

}

- (void) speedUpTowardPoint:(CGPoint)p
{
    CGPoint p_ = self.position;
    [self removeAllActions];
    [self runAction:[self getBallMovingAction:TURN_SPEED_SUPER]];
    float distance = sqrtf((p_.x-p.x)*(p_.x-p.x) + (p_.y-p.y)*(p_.y-p.y));
    float time = distance / speed * 10;
    [self runAction:[SKAction moveTo:p duration:time]];
}

- (SKAction *) getBallMovingAction:(int)factor
{
    SKAction *rotate = [SKAction rotateByAngle:1000*factor duration:200];
    return rotate;
}

-(SKAction*)returnPreviousAction
{
    SKAction * group = [SKAction group:[NSArray arrayWithObjects:[self getBallMovingAction:TURN_SPEED_NORMAL],[SKAction moveByX:Vector_X*SPEEDUP y:Vector_Y*SPEEDUP duration:100], nil]];
    return group;
}

-(int)getAttack
{
    return attack;
}


+(int)getBallNormalTurnSpeed{return TURN_SPEED_NORMAL;}
+(int)getBallFastTurnSpeed{return TURN_SPEED_FAST;}

-(void)resetTurnDamage
{
    turnDamage = attack;
}
-(void)turnDamageWeaken:(int)n
{
    turnDamage-=n;
}

-(int)getTurnDamageLeft
{
    return turnDamage;
}

-(void)increaseAttack
{
    minorAttack++;
    if(minorAttack == 3)
    {
        attack++;
        minorAttack = 0;
        speed_*=1.1;
    }
}

-(void)reset
{
    attack = 1;
    turnDamage = 1;
    minorAttack = 0;
    speed_ = 0.5;
}

-(bool)damaged
{
    lifePoints--;
    if(lifePoints<=0)
    {
        lifePoints = 5;
        return true;
    }
    return false;
}

@end
