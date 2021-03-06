//
//  Quest.h
//  HabitRPG
//
//  Created by Phillip Thelen on 02/04/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>
#import "BuyableItem.h"

@interface Quest : BuyableItem

@property(nonatomic, retain) NSNumber *bossHp;
@property(nonatomic, retain) NSNumber *bossRage;
@property(nonatomic, retain) NSString *bossName;
@property(nonatomic, retain) NSNumber *bossStr;
@property(nonatomic, retain) NSNumber *bossDef;
@property(nonatomic, retain) NSNumber *canBuy;
@property(nonatomic, retain) NSString *completition;
@property(nonatomic, retain) NSNumber *dropExp;
@property(nonatomic, retain) NSNumber *dropGp;
@property(nonatomic, retain) NSString *key;
@property(nonatomic, retain) NSString *notes;
@property(nonatomic, retain) NSString *previous;
@property(nonatomic, retain) NSString *text;
@property(nonatomic, retain) NSNumber *value;
@property(nonatomic, retain) NSOrderedSet *collect;
@property(nonatomic, retain) NSString *rageTitle;
@property(nonatomic, retain) NSString *rageDescription;

@end

@interface Quest (CoreDataGeneratedAccessors)

- (void)insertObject:(NSManagedObject *)value inCollectAtIndex:(NSUInteger)idx;

- (void)removeObjectFromCollectAtIndex:(NSUInteger)idx;

- (void)insertCollect:(NSArray *)value atIndexes:(NSIndexSet *)indexes;

- (void)removeCollectAtIndexes:(NSIndexSet *)indexes;

- (void)replaceObjectInCollectAtIndex:(NSUInteger)idx withObject:(NSManagedObject *)value;

- (void)replaceCollectAtIndexes:(NSIndexSet *)indexes withCollect:(NSArray *)values;

- (void)addCollectObject:(NSManagedObject *)value;

- (void)removeCollectObject:(NSManagedObject *)value;

- (void)addCollect:(NSOrderedSet *)values;

- (void)removeCollect:(NSOrderedSet *)values;
@end
