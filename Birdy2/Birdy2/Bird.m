//
//  BIrd.m
//  Birdy2
//
//  Created by veso on 1/31/16.
//  Copyright © 2016 veso. All rights reserved.
//

#import "Bird.h"

@implementation Bird {
    NSString *_id;
    NSString *_name;
    NSString *_latinName;
    NSString *_pictureUrl;
    NSString *_description;
    NSArray *_observed;
}

@synthesize id = _id;
@synthesize name = _name;
@synthesize latinName = _latinName;
@synthesize pictureUrl = _pictureUrl;
@synthesize description = _description;
@synthesize observed = _observed;

- (id)initWithId:(NSString*)aId
        withName:(NSString*)aName
   withLatinName:(NSString*)aLatinName
  withPictureUrl:(NSString*)aUrl
 withDescription:(NSString*)aDescr
andWithObservedAt:(NSArray*)aObserved {
    self = [super init];
    if (self) {
        self.id = aId;
        self.name = aName;
        self.latinName = aLatinName;
        self.pictureUrl = aUrl;
        self.description = aDescr;
        self.observed = aObserved;
    }
    return self;
}

+(instancetype)BirdWithId:(NSString*)aId
                 withName:(NSString*)aName
            withLatinName:(NSString*)aLatinName
           withPictureUrl:(NSString*)aUrl
          withDescription:(NSString*)aDescr
        andWithObservedAt:(NSArray*)aObserved {
    return [[self alloc] initWithId:aId withName:aName withLatinName:aLatinName withPictureUrl:aUrl withDescription:aDescr andWithObservedAt:aObserved];
}

@end
