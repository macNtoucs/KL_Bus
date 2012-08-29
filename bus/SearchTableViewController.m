//
//  SearchTableViewController.m
//  bus
//
//  Created by mac_hero on 12/6/8.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "SearchTableViewController.h"

@implementation SearchTableViewController
@synthesize search;
@dynamic root_item;
@dynamic routes_item;
@dynamic stop_item;
@synthesize resultInfo;
@synthesize waitTime;
@synthesize sectionNum;
@synthesize routesName;
@synthesize waitTimeURL;
@synthesize memory;

-(void)setEnterFromRoot:(RootViewController *)delegate
{
    enterFromRoot = YES;
    rootdelegate = delegate;
}

-(NSMutableArray *) getSearchResult
{
    [self loadDataBase];
    return resultInfo;

}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle



-(void) setInfo : (NSString *)key
{
    search = [[NSString alloc] initWithString:key];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


- (NSString*) fixStringForName : (NSString*) oldString andOrder: (int) order
{
    NSString* newString ;
    
    if (order <=9) {newString = [oldString substringFromIndex:3];}
    else  { newString = [oldString substringFromIndex:4];}
   // newString = [newString stringByAppendingString : @" : "];
    // NSLog (@"%@",oldString);
    return newString;
   
}

- (NSString*) RemovetheBrackets : (NSString *) oldString
{
    NSString* newString = [NSString new] ;
    NSRange range = [oldString rangeOfString:@"("];  
    if (range.length!=0)
       return newString = [oldString substringToIndex:range.location];
    else
        return oldString;
}


-(NSString*) AccessStringFormBrackets : (NSString *)oldString
{
    NSString* newString = [NSString new] ;
    NSRange range = [oldString rangeOfString:@"("];  
    if (range.length!=0)
        return newString = [oldString substringFromIndex:range.location+1];
    else
        return oldString;

}

-(id) init{
    self = [super init];
    resultInfo = [[NSMutableArray alloc] init]; 
    waitTime = [[NSMutableArray alloc] init]; 
    sectionNum =[[NSMutableArray alloc]init];
    return self;
}

- (void) loadDataBase 
{
   
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES);
    NSString *filePath = [paths objectAtIndex:0];
    filePath = [filePath stringByAppendingString:@"/database.plist"];
    
    memory = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath]; 
   // NSLog(@"%@",memory);
    [resultInfo removeAllObjects];
    NSString* infoInData = [NSString new];
    for (infoInData in memory)
    {
        NSString *fixedString1 = [self RemovetheBrackets: infoInData ];
        NSString *fixedString2 = [self AccessStringFormBrackets:infoInData];
        if ([ fixedString1 compareWithWord:search] <= abs([fixedString1 length] - [search length]) || 
            [ fixedString2 compareWithWord:search] <= abs([fixedString2 length] - [search length])) 
            [resultInfo addObject:infoInData];
    }
    //[resultInfo retain];

}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated]; 
    [self loadDataBase];
    [self.tableView reloadData];
    
}

-(void) dealloc 
{
    [ search release];
     [ root_item release];
      [ routes_item release];
       [ stop_item release];
        [ resultInfo release];
         [ waitTime release];
          [ sectionNum release];
           [ routesName release];
            [ waitTimeURL release];
             [ memory release];
    [super dealloc];
}



- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.

    return 1;


}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [resultInfo count];


}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
       cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];

    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = [resultInfo objectAtIndex:indexPath.row];
    // Configure the cell...
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    UIAlertView *loadingAlertView = [[UIAlertView alloc] 
                                     initWithTitle:nil message:@"\n\nDownloading\nPlease wait"
                                     delegate:nil cancelButtonTitle:nil
                                     otherButtonTitles: nil];
    CGRect frame = CGRectMake(120, 10, 40, 40);
    UIActivityIndicatorView* progressInd = [[UIActivityIndicatorView alloc] initWithFrame:frame];
    progressInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [progressInd startAnimating];
    [loadingAlertView addSubview:progressInd];
    [loadingAlertView show];
    [progressInd release];

    SearchStopRouteViewController *searchStopRouteViewController = [SearchStopRouteViewController new];
    searchStopRouteViewController.title =  cell.textLabel.text;
    [searchStopRouteViewController setArray:[memory objectForKey: cell.textLabel.text ] andStop:cell.textLabel.text];
    if (enterFromRoot) {
        [rootdelegate.navigationController pushViewController:searchStopRouteViewController animated:YES];
        }
    else {
        [self.navigationController pushViewController:searchStopRouteViewController animated:YES];
    }
    [loadingAlertView dismissWithClickedButtonIndex:0 animated:NO];
    [loadingAlertView release];
    [searchStopRouteViewController release];
    
}

@end
