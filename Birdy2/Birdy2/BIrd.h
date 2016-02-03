#import <Foundation/Foundation.h>

@interface Bird : NSObject

@property (strong, nonatomic) NSString *id;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *latinName;
@property (strong, nonatomic) NSString *pictureUrl;
@property (strong, nonatomic) NSString *description;
@property (strong, nonatomic) NSArray *observed;

+(instancetype)BirdWithId:(NSString*)aId
                 withName:(NSString*)aName
            withLatinName:(NSString*)aLatinName
           withPictureUrl:(NSString*)aUrl
          withDescription:(NSString*)aDescr
        andWithObservedAt:(NSArray*)aObserved;

- (id)initWithId:(NSString*)aId
        withName:(NSString*)aName
   withLatinName:(NSString*)aLatinName
  withPictureUrl:(NSString*)aUrl
 withDescription:(NSString*)aDescr
andWithObservedAt:(NSArray*)aObserved;

@end
