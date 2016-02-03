#import <Foundation/Foundation.h>

@interface Bird : NSObject

@property (strong, nonatomic) NSString *id;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *latinName;
@property (strong, nonatomic) NSString *picture;
@property (strong, nonatomic) NSString *descr;
@property (strong, nonatomic) NSString *latitude;
@property (strong, nonatomic) NSString *longitude;
@property (strong, nonatomic) NSMutableArray *observedPositions;

- (id)initWithName:(NSString *)aName
     withLatinName:(NSString *)aLatinName
   withDescription:(NSString *)aDescr
      withLatitude:(NSString *)aLat
  andWithLongitude:(NSString *)aLon;

- (id)initWithId:(NSString *)aId
        withName:(NSString *)aName
   withLatinName:(NSString *)aLatinName
         withPic:(NSString *)aPic
 withDescription:(NSString *)aDescr
andWithPositions:(NSMutableArray*)aPositions;

+(instancetype)BirdWithId:(NSString*)aId
                 withName:(NSString*)aName
            withLatinName:(NSString*)aLatinName
                  withPic:(NSString*)aPic
          withDescription:(NSString*)aDescr
         andWithPositions:(NSMutableArray*)aPositions;

+(instancetype)BirdWithName:(NSString*)aName
              withLatinName:(NSString*)aLatinName
            withDescription:(NSString*)aDescr
               withLatitude:(NSString*)aLat
           andWithLongitude:(NSString*)aLon;

@end
