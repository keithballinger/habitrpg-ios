//
//  HRPGPetViewController.m
//  Habitica
//
//  Created by Phillip on 07/06/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGMountViewController.h"
#import "Egg.h"
#import "HatchingPotion.h"

@interface HRPGMountViewController ()
@property(nonatomic) NSFetchedResultsController *fetchedResultsController;
@property(nonatomic) NSArray *eggs;
@property(nonatomic) NSArray *hatchingPotions;
@property(nonatomic) Pet *selectedMount;
@property UIBarButtonItem *navigationButton;
@property CGSize screenSize;
@property NSString *equippedMountName;
@end

@implementation HRPGMountViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.equippedMountName = [self.sharedManager getUser].currentMount;

    self.screenSize = [[UIScreen mainScreen] bounds].size;

    if (self.mountColor) {
        self.navigationItem.title = self.mountColor;
    } else {
        self.navigationItem.title = self.mountName;
    }

    NSError *error;

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity =
        [NSEntityDescription entityForName:@"Egg" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    self.eggs = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];

    fetchRequest = [[NSFetchRequest alloc] init];
    entity = [NSEntityDescription entityForName:@"HatchingPotion"
                         inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    self.hatchingPotions =
        [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
}

- (Egg *)eggWithKey:(NSString *)key {
    for (Egg *egg in self.eggs) {
        if ([egg.key isEqualToString:key]) {
            return egg;
        }
    }
    return nil;
}

- (HatchingPotion *)hatchingPotionWithKey:(NSString *)key {
    for (HatchingPotion *hatchingPotion in self.hatchingPotions) {
        if ([hatchingPotion.key isEqualToString:key]) {
            return hatchingPotion;
        }
    }
    return nil;
}

- (NSString *)niceMountName:(Pet *)mount {
    NSArray *nameParts = [mount.key componentsSeparatedByString:@"-"];

    NSString *niceMountName = [self eggWithKey:nameParts[0]].mountText;
    if (!niceMountName) {
        niceMountName = nameParts[0];
    }
    NSString *niceHatchingPotionName = [self hatchingPotionWithKey:nameParts[1]].text;
    if (!niceHatchingPotionName) {
        niceHatchingPotionName = nameParts[1];
    }
    return [NSString stringWithFormat:@"%@ %@", niceHatchingPotionName, niceMountName];
}

- (void)preferredContentSizeChanged:(NSNotification *)notification {
    [self.collectionView reloadData];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    id<NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                    layout:(UICollectionViewLayout *)collectionViewLayout
    sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 120.0f;
    height = height +
             [@" " boundingRectWithSize:CGSizeMake(135.0f, MAXFLOAT)
                                options:NSStringDrawingUsesLineFragmentOrigin
                             attributes:@{
                                 NSFontAttributeName :
                                     [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]
                             }
                                context:nil]
                     .size.height *
                 2;
    if (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
        return CGSizeMake(self.screenSize.width / 3 - 20, height);
    }
    return CGSizeMake(self.screenSize.width / 2 - 15, height);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *headerView =
        [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                           withReuseIdentifier:@"SectionCell"
                                                  forIndexPath:indexPath];
    UILabel *label = [headerView viewWithTag:1];
    NSString *sectionName = [[self.fetchedResultsController sections][indexPath.section] name];
    if ([sectionName isEqualToString:@"questPets"]) {
        label.text = NSLocalizedString(@"Quest Mounts", nil);
    } else if ([sectionName isEqualToString:@" "]) {
        label.text = NSLocalizedString(@"Special Mounts", nil);
    } else {
        label.text = NSLocalizedString(@"Base Mounts", nil);
    }
    return headerView;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell =
        [collectionView dequeueReusableCellWithReuseIdentifier:@"BaseCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView
    didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *equipString = NSLocalizedString(@"Mount", nil);
    Pet *mount = [self.fetchedResultsController objectAtIndexPath:indexPath];

    if (!mount.asMount) {
        equipString = nil;
    } else if ([self.equippedMountName isEqualToString:mount.key]) {
        equipString = NSLocalizedString(@"Unmount", nil);
    }

    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:[self niceMountName:mount]
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:equipString, nil];
    popup.tag = 1;
    self.selectedMount = mount;

    // get the selected cell so that the popup can be displayed near it on the iPad
    UICollectionViewCell *selectedCell =
        [self collectionView:collectionView cellForItemAtIndexPath:indexPath];

    CGRect rectIPad = CGRectMake(selectedCell.frame.origin.x,
                                 selectedCell.frame.origin.y + selectedCell.frame.size.height,
                                 selectedCell.frame.size.width, selectedCell.frame.size.height);
    // using the following form rather than [popup showInView:[UIApplication
    // sharedApplication].keyWindow]] to make it compatible with both iPhone and iPad
    [popup showFromRect:rectIPad inView:self.view animated:YES];
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity =
        [NSEntityDescription entityForName:@"Pet" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];

    if (self.mountName) {
        [fetchRequest
            setPredicate:[NSPredicate predicateWithFormat:@"key contains[cd] %@ && type = %@",
                                                          self.mountName, self.mountType]];
    } else {
        [fetchRequest
            setPredicate:[NSPredicate predicateWithFormat:@"key contains[cd] %@ && type = %@",
                                                          self.mountColor, self.mountType]];
    }

    NSSortDescriptor *typeSortDescriptor =
        [[NSSortDescriptor alloc] initWithKey:@"type" ascending:YES];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"key" ascending:YES];
    NSArray *sortDescriptors = @[ typeSortDescriptor, sortDescriptor ];

    [fetchRequest setSortDescriptors:sortDescriptors];

    NSFetchedResultsController *aFetchedResultsController =
        [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                            managedObjectContext:self.managedObjectContext
                                              sectionNameKeyPath:@"type"
                                                       cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;

    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    return _fetchedResultsController;
}

- (void)controller:(NSFetchedResultsController *)controller
    didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo
             atIndex:(NSUInteger)sectionIndex
       forChangeType:(NSFetchedResultsChangeType)type {
}

- (void)controller:(NSFetchedResultsController *)controller
    didChangeObject:(id)anObject
        atIndexPath:(NSIndexPath *)indexPath
      forChangeType:(NSFetchedResultsChangeType)type
       newIndexPath:(NSIndexPath *)newIndexPath {
    UICollectionView *collectionView = self.collectionView;
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [collectionView insertItemsAtIndexPaths:@[ newIndexPath ]];
            break;

        case NSFetchedResultsChangeDelete:
            [collectionView deleteItemsAtIndexPaths:@[ indexPath ]];
            break;

        case NSFetchedResultsChangeUpdate:
            [self configureCell:[collectionView cellForItemAtIndexPath:indexPath]
                    atIndexPath:indexPath];
            break;

        case NSFetchedResultsChangeMove:
            if (indexPath.item != newIndexPath.item) {
                [collectionView deleteItemsAtIndexPaths:@[ indexPath ]];
                [collectionView insertItemsAtIndexPaths:@[ newIndexPath ]];
            } else {
                [self.collectionView reloadItemsAtIndexPaths:@[ indexPath ]];
            }
            break;
    }
}

- (void)configureCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Pet *mount = [self.fetchedResultsController objectAtIndexPath:indexPath];
    UIImageView *imageView = [cell viewWithTag:1];
    UILabel *label = [cell viewWithTag:2];
    if (!mount.niceMountName) {
        mount.niceMountName = [self niceMountName:mount];
    }
    label.text = mount.niceMountName;
    label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    if ([mount.asMount boolValue]) {
        [mount setMountOnImageView:imageView];
        imageView.contentMode = UIViewContentModeScaleToFill;
        imageView.alpha = 1;
    } else {
        [self.sharedManager setImage:@"PixelPaw" withFormat:@"png" onView:imageView];
        imageView.contentMode = UIViewContentModeCenter;
        imageView.alpha = 0.3f;
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.numberOfButtons > 1 && buttonIndex == 0) {
        __weak HRPGMountViewController *weakSelf = self;
        [self.sharedManager equipObject:self.selectedMount.key
            withType:@"mount"
            onSuccess:^() {
                if ([weakSelf.equippedMountName isEqualToString:weakSelf.selectedMount.key]) {
                    weakSelf.equippedMountName = nil;
                } else {
                    weakSelf.equippedMountName = weakSelf.selectedMount.key;
                }
            }
            onError:^(){
            }];
    }
}

@end
