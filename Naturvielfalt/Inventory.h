//
//  Inventory.h
//  Naturvielfalt
//
//  Created by Albert von Felten on 11.04.13.
//
//

#import <Foundation/Foundation.h>
#import "Area.h"

@interface Inventory : NSObject {
    
    long long int inventoryId;
    long long int areaId;
    NSString *author;
    NSString *name;
    NSString *description;
    NSDate *date;
    NSMutableArray *observations;
    NSMutableArray *pictures;
    BOOL submitToServer;
    Area *area;
    int guid;
    BOOL submitted;
}

@property (nonatomic, assign) long long int inventoryId;
@property (nonatomic) BOOL submitted;
@property (nonatomic, assign) long long int areaId;
@property (nonatomic) NSString *author;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *description;
@property (nonatomic) NSDate *date;
@property (nonatomic) NSMutableArray *pictures;
@property (nonatomic) NSMutableArray *observations;
@property (nonatomic, assign) BOOL submitToServer;
@property (nonatomic) Area *area;
@property (nonatomic) int guid;

- (Inventory *) getInventory;
- (void) setInventory:(Inventory *)iv;
- (BOOL) checkAllObservationsFromInventorySubmitted;

@end

