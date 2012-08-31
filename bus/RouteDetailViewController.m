//
//  RouteDetailViewController.m
//  bus
//
//  Created by mac_hero on 12/5/18.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "RouteDetailViewController.h"
#define kPlainId				@"Plain"



@implementation RouteDetailViewController
@synthesize item;
@synthesize url;

- (void) getURL:(NSString* ) inputURL
{
    NSString* string = @"http://ebus.klcba.gov.tw/KLBusWeb/pda/";
    string = [string stringByAppendingString:inputURL];
    url = [NSURL URLWithString:string];
    [url retain];   
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

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    NSError* error;
    
    NSData* data = [[NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error] dataUsingEncoding:NSUTF8StringEncoding];
    
    // 取出title標籤中的值
    TFHpple* parser = [[TFHpple alloc] initWithHTMLData:data];
    if (!data) 
    {
        UIAlertView *loadingAlertView = [[UIAlertView alloc] 
                                         initWithTitle:nil message:@"當前無網路或連接伺服器失敗"
                                         delegate:nil cancelButtonTitle:@"確定"
                                         otherButtonTitles: nil];
        [loadingAlertView show];
        [loadingAlertView release];
    }

    item  = [parser searchWithXPathQuery:@"//body//div//table//tr//td//a"]; // get the title
    [item retain];
    [parser release];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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

- (void)dealloc {
    [item release];
    [url release];
    [super dealloc];
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
    return [item count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kPlainId];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kPlainId] autorelease];
    }
    
    // Set up the cell
    
    TFHppleElement* T_ptr = [item objectAtIndex:indexPath.row];
    NSArray *child = [T_ptr children];
    TFHppleElement* buf = [child objectAtIndex:0];   
    NSString* result = [buf content];
    cell.textLabel.text =result;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
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
    DepatureViewController *detail = [DepatureViewController new];
    detail.title = @"站牌資訊";
    TFHppleElement* T_ptr = [item objectAtIndex:indexPath.row];
    [detail getURL:[T_ptr.attributes valueForKey:@"href"] andRoute:cell.textLabel.text andCorrect:YES];
    [self.navigationController pushViewController:detail animated:YES];
    [loadingAlertView dismissWithClickedButtonIndex:0 animated:NO];
    [loadingAlertView release];
    [detail release];
}

@end
