//
//  ViewController.m
//  Test
//
//  Created by Adhith Ashok on 11/07/17.
//  Copyright © 2017 Adhith Ashok. All rights reserved.
//

#import "ViewController.h"
#import "TableViewCell.h"
//#import "UIColor+CustomRed.h"

@interface ViewController ()<UITableViewDataSource>
{
    NSArray * arrItems;
}

@end

@implementation ViewController
@synthesize coredatadb;
- (void)viewDidLoad

{
    [super viewDidLoad];
    [self makeRestAPICall];
    self.view.backgroundColor = [UIColor CutomRedColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void) makeRestAPICall
{
    NSURL *URL = [NSURL URLWithString:@"https://reqres.in/api/users?page=2"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:
    ^(NSData *data, NSURLResponse *response, NSError *error)
    {
        id jsonResponse = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error: &error];
        
        for (NSArray * temparr in [jsonResponse valueForKey:@"data"])
        {
            NSManagedObjectContext *context = [self managedObjectContext];
            NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"TABLEONE"];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@", [temparr valueForKey:@"id"]];  //  Where condition
            [fetch setPredicate:predicate];
            NSArray * arrCheckExistance = [[context executeFetchRequest:fetch error:nil] mutableCopy];
            
            if(arrCheckExistance.count == 0)
            {
                //not there so create it and save
                NSManagedObject * newDevice = [NSEntityDescription insertNewObjectForEntityForName:@"TABLEONE" inManagedObjectContext:context];
                [newDevice setValue:[temparr valueForKey:@"first_name"] forKey:@"fname"];
                [newDevice setValue:[temparr valueForKey:@"last_name"] forKey:@"lname"];
                [newDevice setValue:[temparr valueForKey:@"id"] forKey:@"id"];
                [newDevice setValue:[temparr valueForKey:@"avatar"] forKey:@"image"];
                
                NSError  *err;
                if (![context save:&err])
                {
                    NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
                }
            }
        }
        
        NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"TABLEONE"];
        arrItems = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tblList reloadData];
        });
        
    }];
    
    [task resume];
}

- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)])
    {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identifier = @"TableViewCell";
    TableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell)
    {
        [tableView registerNib:[UINib nibWithNibName:@"TableViewCell" bundle:nil] forCellReuseIdentifier:identifier];
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    }
    
    cell.lblOne.text = [[arrItems objectAtIndex:indexPath.row] valueForKey:@"fname"];
    cell.lblTwo.text = [[[arrItems objectAtIndex:indexPath.row] valueForKey:@"id"] stringValue];
    cell.lblThree.text = [[arrItems objectAtIndex:indexPath.row] valueForKey:@"lname"];
    
    //   enters Background thread
    [self downloadImageWithURL:[NSURL URLWithString:[[arrItems valueForKey:@"image"] objectAtIndex:indexPath.row]] completionBlock:^(BOOL succeeded, UIImage *image)
    {
        if (succeeded)
        {
            dispatch_async(dispatch_get_main_queue(), ^{   //   enters Main thread
                cell.imgMain.image = image;
            });
        }
    }];
    
    
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  [arrItems count];
}

- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock
{
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:
    ^(NSData *data, NSURLResponse *response,  NSError *error)
    {
        if ( !error )
        {
            UIImage *image = [[UIImage alloc] initWithData:data];
            completionBlock(YES,image);
        }
        else
        {
            completionBlock(NO,nil);
        }
   }];
    
    [task resume];
}


@end
