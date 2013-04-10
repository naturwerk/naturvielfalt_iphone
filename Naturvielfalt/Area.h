//
//  Area.h
//  Naturvielfalt
//
//  Created by Albert von Felten on 04.04.13.
//
//

#import <Foundation/Foundation.h>
#import "AreasViewController.h"

@interface Area : NSObject {
    
    long long int areaId;
    NSString *author;
    NSString *areaName;
    NSString *inventoryName;
    NSDate *date;
    NSMutableArray *pictures;
    NSString *description;
    BOOL submitToServer;
    BOOL locationLocked;
    DrawMode typeOfArea;
}

@property (nonatomic, assign) long long int areaId;
@property (nonatomic) NSString *author;
@property (nonatomic) NSString *areaName;
@property (nonatomic) NSString *inventoryName;
@property (nonatomic) NSDate *date;
@property (nonatomic) NSMutableArray *pictures;
@property (nonatomic) NSString *description;
@property (nonatomic, assign) BOOL submitToServer;
@property (nonatomic, assign) BOOL locationLocked;
@property (nonatomic) DrawMode typeOfArea;

- (Area *) getArea;
- (void) setArea:(Area *)area;

@end
