#import "Bird.h"

@implementation Bird

-(id)initWithName: (NSString*)aName
    withLatinName:(NSString*)aLatinName
andWithDescription:(NSString*)aDescr {
    self = [super init];
    if (self) {
        self.name = aName;
        self.latinName = aLatinName;
        self.descr = aDescr;
    }
    return self;
}

- (id)initWithName:(NSString *)aName
   withLatinName:(NSString *)aLatinName
 withDescription:(NSString *)aDescr
    withLatitude:(NSString *)aLat
andWithLongitude:(NSString *)aLon {
    self = [self initWithName:aName withLatinName:aLatinName andWithDescription:aDescr];
    if (self) {
        self.latitude = aLat;
        self.longitude = aLon;
    }
    return self;
}

- (id)initWithId:(NSString *)aId
        withName:(NSString *)aName
   withLatinName:(NSString *)aLatinName
         withPic:(NSString *)aPic
 withDescription:(NSString *)aDescr
andWithPositions:(NSMutableArray*)aPositions {
    self = [self initWithName:aName withLatinName:aLatinName andWithDescription:aDescr];
    if (self) {
        self.id = aId;
        self.picture = aPic;
        self.observedPositions = aPositions;
    }
    return self;
}

+(instancetype)BirdWithId:(NSString *)aId
                 withName:(NSString *)aName
            withLatinName:(NSString *)aLatinName
                  withPic:(NSString *)aPic
          withDescription:(NSString *)aDescr
         andWithPositions:(NSMutableArray*)aPositions {
    return [[self alloc] initWithId:aId withName:aName withLatinName:aLatinName withPic:aPic withDescription:aDescr andWithPositions:aPositions];
}

+ (instancetype)BirdWithName:(NSString *)aName
               withLatinName:(NSString *)aLatinName
             withDescription:(NSString *)aDescr
                withLatitude:(NSString *)aLat
             andWithLongitude:(NSString *)aLon {
    return [[self alloc] initWithName:aName withLatinName:aLatinName withDescription:aDescr withLatitude:aLat andWithLongitude:aLon];
}

@end
