//
//  Bar.m
//  AnglesUltimate
//
//  Created by xinglunxu on 9/20/15.
//  Copyright (c) 2015 xinglunxu. All rights reserved.
//

#import "Bar.h"
const float ADJUSTMENT = 12;
const int THICKNESS = 10;
const float FURTHER_ADJUSTMENT = 1.5;
float difficulties;
float randomN1;
float randomN2;
int direction_;
static int previousDirection = 0;
int life;
float barWidth;
CGSize f;

float adjustedBarWidth;
float adjustedBarLength;

CGPoint destinationP;

@implementation Bar

-(id)initWithDirection:(int) direction SecondValue:(CGSize)frame 
{
    direction_ = direction;
    f = frame;
    difficulties = frame.height * 0.5;
    randomN1 = arc4random()%(int)(frame.height-difficulties);
    randomN2 = arc4random()%(int)(frame.width-difficulties);
    adjustedBarLength = frame.height/2;
    adjustedBarWidth = adjustedBarLength*28/181;
    CGPoint position = [self getBarPoint:frame secondValue:direction_];
    if(direction_ == 0 ||direction_ == 2)
    {
        self = [super initWithTexture:[SKTexture textureWithImageNamed:@"LRBar3"]];
        barWidth = self.size.width;
    }
    else
    {
        self = [super initWithTexture:[SKTexture textureWithImageNamed:@"TBBar3"]];
        barWidth = self.size.height;
    }
    self.size = [self getBarSize:direction_];
    [self runAction: [self appearanceAnimation:position]];
    self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
    //NSLog(@"width %f, height %f", size.width, size.height);
    //NSLog(@"x %f, y %f", self.position.x, self.position.y);
    //NSLog(@"n1 %f, n2 %f", randomN1, randomN2);
    //NSLog(@"width %f, height %f", frame.width, frame.height);
    previousDirection = direction_;
    life = 3;
    self.zPosition = 1;
    return self;
}


-(CGSize)getBarSize:(int)direction
{
    CGSize returnSize;
    //return CGSizeMake(THICKNESS, difficulties);
    switch (direction) {
        case 0:
        case 2:
            returnSize = CGSizeMake(adjustedBarWidth, adjustedBarLength);
            break;
        case 1:
        case 3:
            returnSize = CGSizeMake(adjustedBarLength, adjustedBarWidth);
            break;
        default:
            break;
    }
    return returnSize;
}

-(CGPoint)getBarPoint:(CGSize)frame secondValue:(int)direction
{
    int width = frame.width;
    int height = frame.height;
    //return CGPointMake(0, height/2);
    float n2;
    CGPoint returnPoint;
    switch (direction) {
        case 0:
            n2 = randomN1+difficulties;
            returnPoint = CGPointMake(ADJUSTMENT, (randomN1+n2)/2);
            break;
        case 1:
            n2 = randomN2+difficulties;
            returnPoint = CGPointMake((randomN2+n2)/2, ADJUSTMENT);
            break;
        case 2:
            n2 = randomN1+difficulties;
            returnPoint = CGPointMake(width-ADJUSTMENT, (randomN1+n2)/2);
            break;
        case 3:
            n2 = randomN2+difficulties;
            returnPoint = CGPointMake((randomN2+n2)/2, height-ADJUSTMENT);
            break;
        default:
            break;
    }
    //NSLog(@"x: %f  y: %f ", returnPoint.x, returnPoint.y);
    return returnPoint;
}

-(SKAction *)appearanceAnimation:(CGPoint)p
{
    if(direction_ == 0)
    {
        self.position = CGPointMake(p.x-30, p.y);
    }
    else if(direction_ == 2)
    {
        self.position = CGPointMake(p.x+30, p.y);
    }
    else if(direction_ == 1){
        self.position = CGPointMake(p.x, p.y-30);
    }
    else
    {
        self.position = CGPointMake(p.x, p.y+30);
    }
    destinationP = p;
    return [SKAction moveTo:p duration:0.2];
}

+(int)adjustDirection:(int)direction
{
    int adjustedDirection = direction;
    if(adjustedDirection == (previousDirection+2)%4 || adjustedDirection == previousDirection)
    {
        adjustedDirection = (direction+1)%4;
    }
    return adjustedDirection;
}

-(int)getDirection
{
    return direction_;
}

-(void)gone
{
    SKAction *selfRemoveAction = [SKAction customActionWithDuration:0.0 actionBlock:^(SKNode *node, CGFloat elapsedTime) {
    self.physicsBody.categoryBitMask = 0;
    [self removeFromParent];
    }];
    SKAction *moveAction;
    if(self.size.height > self.size.width)
    {
        moveAction = [SKAction moveByX:0 y:3000 duration:4];
    }
    else
    {
        moveAction = [SKAction moveByX:3000 y:0 duration:4];
    }
    SKAction *sequence = [SKAction sequence:[NSArray arrayWithObjects:moveAction, selfRemoveAction, nil]];
    [self runAction:sequence];
}

-(int)weakened:(int)damage
{
    life = life - damage;
    if(self.size.height > self.size.width)
    {
        if(life == 1)
        {
            [self runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"LRBar1"]]];
            self.size = CGSizeMake(barWidth*1/3, self.size.height);
            float adjust = 10;
            if(direction_ == 0){adjust = -10;}
            self.position = CGPointMake(self.position.x+adjust, self.position.y);
        }
        else{
            [self runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"LRBar2"]]];
            self.size = CGSizeMake(barWidth*2/3, self.size.height);
            float adjust = 5;
            if(direction_ == 0){adjust = -5;}
            self.position = CGPointMake(self.position.x+adjust, self.position.y);
        }
    }
    else{
        if(life == 1)
        {
            [self runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"TBBar1"]]];
            self.size = CGSizeMake(self.size.width, barWidth*1/3);
            float adjust = -15;
            if(direction_ == 1){adjust = 15;}
            self.position = CGPointMake(self.position.x, self.position.y+adjust);
        }
        else{
            [self runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"TBBar2"]]];
            self.size = CGSizeMake(self.size.width, barWidth*2/3);
            float adjust = -7;
            if(direction_ == 1){adjust = 7;}
            self.position = CGPointMake(self.position.x, self.position.y+adjust);
        }
    }
    
    return life;
}


-(int)damaged:(int)damage
{
    NSLog(@"Execute");
    life = life - damage;
    SKAction *dissapearAction;
//    float adjust;
    //NSLog(@"Direction: %i",direction_);
    switch (direction_) {
        case 0:
//            adjust = -15;
//            if(life==2){adjust = -8;}
            dissapearAction = [SKAction moveToX:self.position.x-barWidth*damage/3 duration:0.2];
            break;
        case 2:
//            adjust = 15;
//            if(life==2){adjust = 8;}
            dissapearAction = [SKAction moveToX:self.position.x+barWidth*damage/3 duration:0.2];
            break;
        case 1:
//            adjust = -15;
//            if(life==2){adjust = -8;}
            dissapearAction = [SKAction moveToY:self.position.y-barWidth*damage/3 duration:0.2];
            break;
        case 3:
//            adjust = 15;
//            if(life==2){adjust = 8;}
            dissapearAction = [SKAction moveToY:self.position.y+barWidth*damage/3 duration:0.2];
            break;
        default:
            break;
    }
    SKAction *reappearAction = [self getReappearAction:life];
    SKAction *sequence = [SKAction sequence:[NSArray arrayWithObjects:dissapearAction,reappearAction, nil]];
    //SKAction *sequence = [SKAction sequence:[NSArray arrayWithObjects:dissapearAction, nil]];
    [self runAction:sequence];
    return life;
}

-(SKAction*)getReappearAction:(int)lifePoints
{
    //NSLog(@"life points: %i",lifePoints);
    SKAction *sequence;
    int temp = direction_;
    direction_ = (direction_+1)%4;
    CGPoint newP = [self getBarPoint:f secondValue:direction_];
    SKAction *custom;
    if(direction_ == 0){
            custom = [SKAction customActionWithDuration:0.0 actionBlock:^(SKNode *node, CGFloat elapsedTime) {
                self.position = CGPointMake(newP.x-30, newP.y);
                [self setTexture:[SKTexture textureWithImageNamed:@"LRBar3"]];
                [self changeSize:temp];
                self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
                self.physicsBody.collisionBitMask = 0;
            }];
            sequence = [SKAction sequence:[NSArray arrayWithObjects:custom,[SKAction moveToX:ADJUSTMENT+FURTHER_ADJUSTMENT-(3-lifePoints)*barWidth/3 duration:0.2], nil]];
    }
    else if(direction_ == 2){
            custom = [SKAction customActionWithDuration:0.0 actionBlock:^(SKNode *node, CGFloat elapsedTime) {
                self.position = CGPointMake(newP.x+30, newP.y);
                [self setTexture:[SKTexture textureWithImageNamed:@"LRBar3"]];
                [self changeSize:temp];
                self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
                self.physicsBody.collisionBitMask = 0;
            }];
            sequence = [SKAction sequence:[NSArray arrayWithObjects:custom,[SKAction moveToX:f.width-ADJUSTMENT-FURTHER_ADJUSTMENT+(3-lifePoints)*barWidth/3 duration:0.2], nil]];
    }
    else if(direction_ == 1)
    {
            custom = [SKAction customActionWithDuration:0.0 actionBlock:^(SKNode *node, CGFloat elapsedTime) {
                self.position = CGPointMake(newP.x, newP.y-30);
                [self setTexture:[SKTexture textureWithImageNamed:@"TBBar3"]];
                [self changeSize:temp];
                self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
                self.physicsBody.collisionBitMask = 0;
            }];
            sequence = [SKAction sequence:[NSArray arrayWithObjects:custom,[SKAction moveToY:ADJUSTMENT+FURTHER_ADJUSTMENT-(3-lifePoints)*barWidth/3 duration:0.2], nil]];
    }
    else
    {
        custom = [SKAction customActionWithDuration:0.0 actionBlock:^(SKNode *node, CGFloat elapsedTime) {
            self.position = CGPointMake(newP.x, newP.y+30);
            [self setTexture:[SKTexture textureWithImageNamed:@"TBBar3"]];
            [self changeSize:temp];
            self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
            self.physicsBody.collisionBitMask = 0;
        }];
        sequence = [SKAction sequence:[NSArray arrayWithObjects:custom,[SKAction moveToY:f.height-ADJUSTMENT-FURTHER_ADJUSTMENT+(3-lifePoints)*barWidth/3 duration:0.2], nil]];
    }
    previousDirection = direction_;
    self.physicsBody.collisionBitMask = 0;
    self.physicsBody.contactTestBitMask = 0;
    //NSLog(@"lifePoints x barwidth/3: %f", lifePoints*barWidth/3);
    return sequence;
}

-(void)changeSize:(int)direction
{
    CGSize s = self.size;
    NSLog(@"Previous D: %i, New D: %i", direction, direction_);
    NSLog(@"Width: %f, Height: %f", self.size.width, self.size.height);
    //if(direction_%2 == direction){return;}
    if((direction_==0||direction_==2) && s.width>s.height)
    {
        self.size = CGSizeMake(self.size.height, self.size.width);
    }
    else if((direction_==1||direction_==3) && s.height>s.width)
    {
        self.size = CGSizeMake(self.size.height, self.size.width);
    }
    
}

-(int)getLifePoint
{
    return life;
}

-(CGPoint)getDestinationP
{
    return destinationP;
}
@end
