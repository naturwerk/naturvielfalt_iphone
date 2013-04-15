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
    NSString *author;
    NSString *inventoryName;
    NSString *description;
    NSDate *date;
    NSMutableArray *pictures;
    BOOL submitToServer;
    Area *area;
}

@property (nonatomic, assign) long long int inventoryId;
@property (nonatomic) NSString *author;
@property (nonatomic) NSString *inventoryName;
@property (nonatomic) NSString *description;
@property (nonatomic) NSDate *date;
@property (nonatomic) NSMutableArray *pictures;
@property (nonatomic, assign) BOOL submitToServer;
@property (nonatomic) Area *area;

@end
