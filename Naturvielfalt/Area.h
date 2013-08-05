//
//  Area.h
//  Naturvielfalt
//
//  Created by Albert von Felten on 04.04.13.
//
//

#import <Foundation/Foundation.h>

typedef enum DrawMode{
    POINT = 1,
    LINE = 2,
    POLYGON = 4,
}DrawMode;

@interface Area : NSObject {
    
    long long int areaId;
    NSString *author;
    NSString *name;
    NSString *description;
    NSDate *date;
    NSMutableArray *pictures;
    NSMutableArray *inventories;
    NSMutableArray *locationPoints;
    BOOL submitToServer;
    BOOL persisted;
    DrawMode typeOfArea;
    int guid;
    BOOL submitted;
}

@property (nonatomic, assign) long long int areaId;
@property (nonatomic) NSString *author;
@property (nonatomic) NSString *name;
@property (nonatomic) NSDate *date;
@property (nonatomic) NSMutableArray *pictures;
@property (nonatomic) NSMutableArray *inventories;
@property (nonatomic) NSMutableArray *locationPoints;
@property (nonatomic) NSString *description;
@property (nonatomic, assign) BOOL submitToServer;
@property (nonatomic, assign) BOOL locationLocked;
@property (nonatomic) DrawMode typeOfArea;
@property (nonatomic) BOOL persisted;
@property (nonatomic) int guid;
@property (nonatomic) BOOL submitted;

- (Area *) getArea;
- (void) setArea:(Area *)a;
- (BOOL) checkAllInventoriesFromAreaSubmitted;
@end