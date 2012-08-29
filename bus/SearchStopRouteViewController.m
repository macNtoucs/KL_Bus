//
//  SearchStopRouteViewController.m
//  bus
//
//  Created by mac_hero on 12/7/11.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "SearchStopRouteViewController.h"
#define kRefreshInterval 60
@implementation SearchStopRouteViewController
@synthesize m_routes;
@synthesize m_waitTime;
@synthesize m_waitTimeResult;
@synthesize input;
@synthesize anotherButton;
@synthesize refreshTimer;
@synthesize lastRefresh;
@synthesize thisStop;
@synthesize success;
-(void)setArray : (NSMutableArray *)input_arr andStop: (NSString *)stop{
    input = [input_arr mutableCopy];
    thisStop = [[NSString alloc] initWithString:stop];
}

-(id)init{
    [super init];
    m_waitTime= [NSMutableArray new];
    m_routes = [NSMutableArray new];
    m_waitTimeResult = [NSMutableArray new];
    return self;
}

-(void)setInfo : (NSMutableArray *)input_arr
{
    BOOL isRoutes =YES;
    for (NSString* data in input_arr)
    {
        if (isRoutes) {
            [m_routes addObject:data];
            isRoutes = NO;
        }
        else {
            [m_waitTime addObject:data];
            isRoutes = YES;
        }
    }
    [m_routes retain];
    [m_waitTime retain];
    NSError *error;
    UInt32 big5 = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5);
    for (NSString *m_waitTimeData in m_waitTime){ 
        NSData* data = [[NSString stringWithContentsOfURL: [NSURL URLWithString:m_waitTimeData ] encoding:big5 error:&error] dataUsingEncoding:big5];
        if (!data) 
        {
            UIAlertView *loadingAlertView = [[UIAlertView alloc] 
                                             initWithTitle:nil message:@"當前無網路或連接伺服器失敗"
                                             delegate:nil cancelButtonTitle:@"確定"
                                             otherButtonTitles: nil];
            [loadingAlertView show];
            [loadingAlertView release];
        }
        TFHpple* parser = [[TFHpple alloc] initWithHTMLData:data];   
        NSArray *waittime  = [parser searchWithXPathQuery:@"//body//div//table//tr//td"]; // get the title
        TFHppleElement* T_ptr2 = [waittime objectAtIndex:2];
        NSArray *child2 = [T_ptr2 children];    
        TFHppleElement* buf2 = [child2 objectAtIndex:0];   
        NSString* result2 = [buf2 content];	
        [m_waitTimeResult addObject:result2];
        [parser release];
    }
    [m_waitTimeResult retain];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)stopTimer
{
	if (self.refreshTimer !=nil)
	{
		[self.refreshTimer invalidate];
		self.refreshTimer = nil;
		self.anotherButton.title = @"Refresh";
	}	
}

#pragma mark - View lifecycle

- (void)refreshPropertyList{
    self.lastRefresh = [NSDate date];
    self.navigationItem.rightBarButtonItem.title = @"Refreshing";
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
    [self.tableView reloadData];
    [loadingAlertView dismissWithClickedButtonIndex:0 animated:NO];
    [progressInd release];
    [loadingAlertView release];
}

- (void)startTimer
{
    self.lastRefresh = [NSDate date];
    NSDate *oneSecondFromNow = [NSDate dateWithTimeIntervalSinceNow:0];
    self.refreshTimer = [[[NSTimer alloc] initWithFireDate:oneSecondFromNow interval:1 target:self selector:@selector(countDownAction:) userInfo:nil repeats:YES] autorelease];
    [[NSRunLoop currentRunLoop] addTimer:self.refreshTimer forMode:NSDefaultRunLoopMode];
	
}

-(void) countDownAction:(NSTimer *)timer
{
    
    if (self.refreshTimer !=nil && self.refreshTimer)
	{
		NSTimeInterval sinceRefresh = [self.lastRefresh timeIntervalSinceNow];
        
        // If we detect that the app was backgrounded while this timer
        // was expiring we go around one more time - this is to enable a commuter
        // bookmark time to be processed.
        
        bool updateTimeOnButton = YES;
        
		if (sinceRefresh <= -kRefreshInterval)
		{
            [self refreshPropertyList];
			self.anotherButton.title = @"Refreshing";
            //updateTimeOnButton = NO;
		}
        
        else if (updateTimeOnButton)
        {
            int secs = (1+kRefreshInterval+sinceRefresh);
            if (secs < 0) secs = 0;
            self.anotherButton.title = [NSString stringWithFormat:@"Refresh in %d", secs];
            
        }
	}
    
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
    anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Refresh" style:UIBarButtonItemStylePlain target:self action:@selector(refreshPropertyList)];     
    [self startTimer];
    self.navigationItem.rightBarButtonItem = anotherButton;
   // [anotherButton release];
    
    if (_refreshHeaderView == nil) { 
        EGORefreshTableHeaderView *view1 = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f,5.0f - self.tableView.bounds.size.height,self.tableView.bounds.size.width,self.tableView.bounds.size.height)]; 
        view1.delegate = self; 
        [self.tableView addSubview:view1]; 
        _refreshHeaderView = view1; 
        [view1 release]; 
    } 
    [_refreshHeaderView refreshLastUpdatedDate]; 
     success = [[UIImageView alloc] initWithFrame:CGRectMake(75.0, 250.0, 150.0, 150.0)];
     [success setImage:[UIImage imageNamed:@"ok.png"]];
    
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
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setInfo:input];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self stopTimer];
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

-(void) dealloc 
{
    [ m_routes release];
     [ m_waitTime release];
      [ m_waitTimeResult release];
       [ input release];
        [ anotherButton release];
         [ refreshTimer release];
          [ lastRefresh release];
           [ thisStop release];
            [ success release];
    
    [super dealloc];

}

#pragma mark - Table view data source

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

-(IBAction)favorite:(id)sender{
    
    
    UIButton * button = (UIButton *) sender;
    int Tag = button.tag;
    NSUserDefaults *prefs = [[NSUserDefaults standardUserDefaults]retain];
    NSMutableArray *favoriteData = [[NSMutableArray alloc] initWithObjects:[m_routes objectAtIndex:Tag], [m_waitTime objectAtIndex:Tag],nil];
    NSMutableDictionary *favoriteDictionary = [[prefs objectForKey:@"user"] mutableCopy];
    if (![prefs objectForKey:@"user"]) {
        favoriteDictionary = [ NSMutableDictionary new ];
    }
    NSMutableArray* temp = [[favoriteDictionary objectForKey:thisStop] mutableCopy];
    if ( temp ){
        if (![temp containsObject:[m_routes objectAtIndex:Tag]]) {
            [temp addObjectsFromArray:favoriteData];
            [favoriteDictionary setObject:temp forKey:thisStop];
        }
    }
    else{
        [favoriteDictionary setObject:favoriteData forKey:thisStop];
    }
    [prefs setObject:favoriteDictionary forKey:@"user"];
    [prefs synchronize];
    [self.navigationController.view addSubview:success];  
    success.alpha = 1.0f;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1.0f];
    success.alpha = 0.0f;
    [UIView commitAnimations];
    [button removeFromSuperview];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [m_routes count];
}

-(BOOL) isStopAdded : (NSString*) input
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dic = [[prefs objectForKey:@"user"] mutableCopy];
    NSMutableArray* temp = [[dic objectForKey:thisStop] mutableCopy];
    if ( temp ){
        if (![temp containsObject:input]) {
            return false;
        }
        else return true;
    }
    else return false;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%d%d", [indexPath section], [indexPath row]];
   // NSError* error;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UIButton *button = [UIButton buttonWithType:0];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        
        button.tag = indexPath.row;
        button.frame  = CGRectMake(275, 5, 30, 30);
        UIImage* star = [UIImage imageNamed:@"star-button.png"];
        [button setImage:star forState:UIControlStateNormal];
        [button addTarget:self action:@selector(favorite:) forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor =  [UIColor yellowColor];
        [cell addSubview:button];
    }
    
    // Configure the cell...
     cell.textLabel.adjustsFontSizeToFitWidth = YES;
     cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
     cell.textLabel.text = [m_routes objectAtIndex:indexPath.row];
    NSString *waitTimeResult = [m_waitTimeResult objectAtIndex:indexPath.row];
     cell.detailTextLabel.text = waitTimeResult;
    
    if ([waitTimeResult isEqualToString:@"即將進站..."]) {
        cell.detailTextLabel.textColor = [UIColor redColor];
    }
    else if ([waitTimeResult isEqualToString:@"目前無公車即時資料"]) {
        cell.detailTextLabel.textColor = [UIColor grayColor];
    }
    else{
        cell.detailTextLabel.textColor = [UIColor colorWithRed:35.0/255 green:192.0/255 blue:46/255 alpha:1];        
    }
    cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
    if ( [self isStopAdded:cell.textLabel.text]) [button removeFromSuperview];
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
}

#pragma mark – 
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{  
    _reloading = YES; 
}

- (void)doneLoadingTableViewData{ 
    _reloading = NO; 
    [self.tableView reloadData];
    self.lastRefresh = [NSDate date];
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView]; 
} 
#pragma mark – 
#pragma mark UIScrollViewDelegate Methods 
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{    
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView]; 
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{ 
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView]; 
} 
#pragma mark – 
#pragma mark EGORefreshTableHeaderDelegate Methods 
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    [self reloadTableViewDataSource]; 
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0]; 
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    return _reloading; 
} 
- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    return [NSDate date];     
} 


@end
