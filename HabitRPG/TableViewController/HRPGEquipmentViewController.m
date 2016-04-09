//
//  HRPGTableViewController.m
//  HabitRPG
//
//  Created by Phillip Thelen on 08/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGEquipmentViewController.h"
#import "Gear.h"
#import "HRPGEquipmentDetailViewController.h"

@interface HRPGEquipmentViewController ()
@property NSString *readableName;
@property NSString *typeName;
@property User *user;

- (void)configureCell:(UITableViewCell *)cell
          atIndexPath:(NSIndexPath *)indexPath
        withAnimation:(BOOL)animate;
@end

@implementation HRPGEquipmentViewController {
    Gear *selectedGear;
    NSIndexPath *selectedIndex;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.user = [self.sharedManager getUser];
    self.tutorialIdentifier = @"equipment";
}

- (void)viewWillAppear:(BOOL)animated {
    NSIndexPath *tableSelection = [self.tableView indexPathForSelectedRow];
    if (tableSelection) {
        [self.tableView reloadRowsAtIndexPaths:@[ tableSelection ]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    [super viewWillAppear:animated];
}

- (NSDictionary *)getDefinitonForTutorial:(NSString *)tutorialIdentifier {
    if ([tutorialIdentifier isEqualToString:@"equipment"]) {
        return @{
            @"text" : NSLocalizedString(@"When you buy equipment, it appears here. Your Battle "
                                        @"Gear affects your stats, and your Costume (if enabled) "
                                        @"affects what your avatar wears.",
                                        nil)
        };
    }
    return nil;
}

#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return NSLocalizedString(@"Battle Gear", nil);
    } else if (section == 2) {
        return NSLocalizedString(@"Costume", nil);
    } else {
        return @"";//switch control
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //section for the wear custom switch
    if (section == 1) {
        return 1;
    }
    
    return 8;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    //section for the wear custom switch
    if (indexPath.section == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Switch" forIndexPath:indexPath];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    }
    
    
    [self configureCell:cell atIndexPath:indexPath withAnimation:NO];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Gear"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];

    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"owned == True"];
    [fetchRequest setPredicate:predicate];

    NSSortDescriptor *indexDescriptor =
        [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
    NSSortDescriptor *typeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"type" ascending:YES];
    NSArray *sortDescriptors = @[ typeDescriptor, indexDescriptor ];

    [fetchRequest setSortDescriptors:sortDescriptors];
    NSFetchedResultsController *aFetchedResultsController =
        [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                            managedObjectContext:self.managedObjectContext
                                              sectionNameKeyPath:nil
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

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView reloadData];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withAnimation:(BOOL)animate {
    if (indexPath.section == 1) {
        UISwitch *customSwitch = [cell viewWithTag:9];
        
        if (customSwitch.allTargets.count == 0) {
            [customSwitch addTarget:self action:@selector(changeWearingCostume:) forControlEvents:UIControlEventValueChanged];
        }
        
        UILabel *wearCustomLabel = [cell viewWithTag:8];
        
        if ([wearCustomLabel.text isEqualToString:@""]) {
            wearCustomLabel.text = NSLocalizedString(@"Wear costume", nil);
        }
    } else {
        UILabel *textLabel = (UILabel*)[cell viewWithTag:1];
        textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        
        NSString *searchedKey;
        NSString *typeName;
        Outfit *outfit;
        if (indexPath.section == 0) {
            outfit = self.user.equipped;
        } else  {
            outfit = self.user.costume;
        }
        if (indexPath.item == 0) {
            searchedKey = outfit.head;
            typeName = NSLocalizedString(@"Head", nil);
        } else if (indexPath.item == 1) {
            searchedKey = outfit.headAccessory;
            typeName = NSLocalizedString(@"Head Accessory", nil);
        } else if (indexPath.item == 2) {
            searchedKey = outfit.eyewear;
            typeName = NSLocalizedString(@"Eyewear", nil);
        } else if (indexPath.item == 3) {
            searchedKey = outfit.armor;
            typeName = NSLocalizedString(@"Armor", nil);
        }  else if (indexPath.item == 4) {
            searchedKey = outfit.body;
            typeName = NSLocalizedString(@"Body", nil);
        } else if (indexPath.item == 5) {
            searchedKey = outfit.back;
            typeName = NSLocalizedString(@"Back", nil);
        } else if (indexPath.item == 6) {
            searchedKey = outfit.shield;
            typeName = NSLocalizedString(@"Shield", nil);
        } else if (indexPath.item == 7) {
            searchedKey = outfit.weapon;
            typeName = NSLocalizedString(@"Weapon", nil);
        }
        Gear *searchedGear;
        for (Gear *gear in self.fetchedResultsController.fetchedObjects) {
            if ([gear.key isEqualToString:searchedKey]) {
                searchedGear = gear;
                break;
            }
        }
        textLabel.text = typeName;
        UILabel *detailLabel = (UILabel*)[cell viewWithTag:3];
        detailLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        UIImageView *imageView = (UIImageView*)[cell viewWithTag:4];
        if (searchedGear) {
            detailLabel.text = searchedGear.text;
            detailLabel.textColor = [UIColor blackColor];
            [self.sharedManager setImage:[NSString stringWithFormat:@"shop_%@", searchedGear.key] withFormat:@"png" onView:imageView];

        } else {
            detailLabel.text = NSLocalizedString(@"Nothing Equipped", nil);
            detailLabel.textColor = [UIColor grayColor];
            imageView.image = nil;
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    if ([segue.identifier isEqualToString:@"EquipmentDetailSegue"]) {
        HRPGEquipmentDetailViewController *equipmentDetailViewController =
            (HRPGEquipmentDetailViewController *)segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        if (indexPath.item == 0) {
            equipmentDetailViewController.type = @"head";
            equipmentDetailViewController.navigationItem.title = NSLocalizedString(@"Head", nil);
        } else if (indexPath.item == 1) {
            equipmentDetailViewController.type = @"headAccessory";
            equipmentDetailViewController.navigationItem.title =
                NSLocalizedString(@"Head Accessory", nil);
        } else if (indexPath.item == 2) {
            equipmentDetailViewController.type = @"eyewear";
            equipmentDetailViewController.navigationItem.title = NSLocalizedString(@"Eyewear", nil);
        } else if (indexPath.item == 3) {
            equipmentDetailViewController.type = @"armor";
            equipmentDetailViewController.navigationItem.title = NSLocalizedString(@"Armor", nil);
        } else if (indexPath.item == 4) {
            equipmentDetailViewController.type = @"body";
            equipmentDetailViewController.navigationItem.title = NSLocalizedString(@"Body", nil);
        } else if (indexPath.item == 5) {
            equipmentDetailViewController.type = @"back";
            equipmentDetailViewController.navigationItem.title = NSLocalizedString(@"Back", nil);
        } else if (indexPath.item == 6) {
            equipmentDetailViewController.type = @"shield";
            equipmentDetailViewController.navigationItem.title = NSLocalizedString(@"Shield", nil);
        } else if (indexPath.item == 7) {
            equipmentDetailViewController.type = @"weapon";
            equipmentDetailViewController.navigationItem.title = NSLocalizedString(@"Weapon", nil);
        }

        if (indexPath.section == 0) {
            equipmentDetailViewController.equipType = @"equipped";
        } else if (indexPath.section == 1) {
            equipmentDetailViewController.equipType = @"costume";
        }
    }
}

- (void)changeWearingCostume:(UISwitch *)switchState {
    [self.sharedManager updateUser:@{
        @"preferences.costume" : [NSNumber numberWithBool:switchState.on]
    }
        onSuccess:^() {
            switchState.on = [self.user.preferences.useCostume boolValue];
        }
        onError:^() {
            switchState.on = [self.user.preferences.useCostume boolValue];
        }];
}

@end
