	//
//  DepatureViewController.m
//  bus
//
//  Created by mac_hero on 12/5/25.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "DepatureViewController.h"
#define kPlainId				@"Plain"
#define kRefreshInterval 60

@implementation DepatureViewController
@synthesize item;
@synthesize url;
@synthesize Route;
@synthesize anotherButton;
@synthesize refreshTimer;
@synthesize lastRefresh;
@synthesize  m_waitTimeResult,m_waitTime;
@synthesize  m_RouteResult;
@synthesize success;
@synthesize toolbar;
- (void) getURL:(NSString* ) inputURL andRoute:(NSString *) route andCorrect:(BOOL) Correct
{
    if (Correct) {
        NSString* string = @"http://ebus.klcba.gov.tw/KLBusWeb/pda/";
        string = [string stringByAppendingString:inputURL];
        url= [[NSURL alloc] initWithString:string];
    }
    else{
        url= [[NSURL alloc] initWithString:inputURL];
    }
    Route = [[NSString alloc] initWithString:route];
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

-(void)CatchData{
    NSError* error;
    //NSStringEncoding encoding;
    UInt32 big5 = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5);
    NSData* data = [[NSString stringWithContentsOfURL:url encoding:big5 error:&error] dataUsingEncoding:big5];
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
    for (int i = 0 ; i < [item count]/2 ; ++i){
        TFHppleElement* T_ptr = [item objectAtIndex:i*2];
        NSArray *child = [T_ptr children];
        
        NSString *nextpage = [T_ptr.attributes valueForKey:@"href"];
        NSString* string = @"http://ebus.klcba.gov.tw/KLBusWeb/pda/";
        NSURL *nexturl = [NSURL URLWithString:[string stringByAppendingString:nextpage]];
        [m_waitTime addObject:[string stringByAppendingString:nextpage]];
        NSError* error;
        //NSStringEncoding encoding;
        UInt32 big5 = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5);
        NSData* data = [[NSString stringWithContentsOfURL:nexturl encoding:big5 error:&error] dataUsingEncoding:big5];
        TFHpple* parser = [[TFHpple alloc] initWithHTMLData:data];
        NSArray *waittime  = [parser searchWithXPathQuery:@"//body//div//table//tr//td"]; // get the title
        TFHppleElement* T_ptr2 = [waittime objectAtIndex:2];
        NSArray *child2 = [T_ptr2 children];
        TFHppleElement* buf2 = [child2 objectAtIndex:0];
        [m_waitTimeResult  addObject: [buf2 content] ];
        [parser release];
        TFHppleElement* buf = [child objectAtIndex:0];
        [m_RouteResult addObject: [buf content] ];
    }
    [self.tableView reloadData];
}

-(void)AlertStart:(UIAlertView *) loadingAlertView{
    CGRect frame = CGRectMake(120, 10, 40, 40);
    UIActivityIndicatorView* progressInd = [[UIActivityIndicatorView alloc] initWithFrame:frame];
    progressInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [progressInd startAnimating];
    [loadingAlertView addSubview:progressInd];
    [loadingAlertView show];
    [progressInd release];
}

- (void)refreshPropertyList{
    self.lastRefresh = [NSDate date];
    self.navigationItem.rightBarButtonItem.title = @"Refreshing";
    UIAlertView *  loadingAlertView = [[UIAlertView alloc]
                                          initWithTitle:nil message:@"\n\nDownloading\nPlease wait"
                                          delegate:nil cancelButtonTitle:nil
                                          otherButtonTitles: nil];
    NSThread*thread = [[NSThread alloc]initWithTarget:self selector:@selector(AlertStart:) object:loadingAlertView];
    [thread start];
    while (true) {
        if ([thread isFinished]) {
            break;
        }
    }
    [self CatchData];
    [loadingAlertView dismissWithClickedButtonIndex:0 animated:NO];
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

   
- (void)viewDidLoad
{
    [super viewDidLoad];
    m_waitTimeResult = [NSMutableArray new];
    m_waitTime = [NSMutableArray new];
    m_RouteResult = [NSMutableArray new];
    toolbar = [[ToolBarController alloc]init];
    [self.navigationController.view addSubview:[toolbar CreatTabBarWithNoFavorite:NO delegate:self] ];
    anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Refresh" style:UIBarButtonItemStylePlain target:self action:@selector(refreshPropertyList)];
    self.navigationItem.rightBarButtonItem = anotherButton;
    //[anotherButton release];
    
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
    [self.navigationController.view addSubview:toolbar.toolbarcontroller];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (!item) {
        [self CatchData];
    }
    [self startTimer];
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [toolbar.toolbarcontroller removeFromSuperview];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [item count]/2+1;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%d%d", [indexPath section], [indexPath row]];
    // NSError* error;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    if (indexPath.row==[item count]/2) {
        return cell;
    }  
    cell.textLabel.text = [m_RouteResult objectAtIndex:indexPath.row];
        
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    NSString* result2 = [m_waitTimeResult objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = result2;
    
    [[cell.contentView viewWithTag:indexPath.row+1]removeFromSuperview];
    [cell.contentView addSubview:[toolbar CreateButton:indexPath]];
    [toolbar isStopAdded:Route andStop:cell.textLabel.text];
    
    if ([result2 isEqualToString:@"即將進站..."]) {
        cell.detailTextLabel.textColor = [UIColor redColor];
    }
    else if ([result2 isEqualToString:@"目前無公車即時資料"]) {
        cell.detailTextLabel.textColor = [UIColor grayColor];
    }
    else{
        cell.detailTextLabel.textColor = [UIColor colorWithRed:35.0/255 green:192.0/255 blue:46/255 alpha:1];        
    }
    cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
    
    return cell;

}
    

- (void)dealloc {

    [item release];
    [m_waitTime release];
    [Route release];
    [anotherButton release];
    [lastRefresh release];
    [url release];
    [super dealloc];
}



#pragma mark - Table view delegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

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
    [self CatchData];
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
