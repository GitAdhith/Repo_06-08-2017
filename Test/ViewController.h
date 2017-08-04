//
//  ViewController.h
//  Test
//
//  Created by Adhith Ashok on 11/07/17.
//  Copyright © 2017 Adhith Ashok. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *tblList;
@property (strong) NSManagedObject * coredatadb;


@end

