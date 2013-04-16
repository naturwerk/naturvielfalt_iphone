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
    NSString *name;
    NSString *description;
    NSDate *date;
    NSMutableArray *pictures;
    NSMutableArray *inventories;
    BOOL submitToServer;
    DrawMode typeOfArea;
}

@property (nonatomic, assign) long long int areaId;
@property (nonatomic) NSString *author;
@property (nonatomic) NSString *name;
@property (nonatomic) NSDate *date;
@property (nonatomic) NSMutableArray *pictures;
@property (nonatomic) NSMutableArray *inventories;
@property (nonatomic) NSString *description;
@property (nonatomic, assign) BOOL submitToServer;
@property (nonatomic, assign) BOOL locationLocked;
@property (nonatomic) DrawMode typeOfArea;


@end
