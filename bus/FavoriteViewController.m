//
//  FavoriteViewController.m
//  bus
//
//  Created by mac_hero on 12/7/12.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "FavoriteViewController.h"

@implementation FavoriteViewController
@synthesize favoriteDic,m_waitTimeResult,m_routesResult;
@synthesize lastRefresh;
int rowNumberInSection [300] ={0};

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

-(IBAction)ToggleEdit:(id)sender
{
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    if (self.tableView.editing)
        [self.navigationItem.rightBarButtonItem setTitle:@"Done"];
    else [self.navigationItem.rightBarButtonItem setTitle:@"Delete"];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    m_waitTimeResult = [NSMutableArray new];
    m_routesResult = [NSMutableArray new];
    favoriteDic =[NSMutableDictionary new];
    UIBarButtonItem *editButton = [ [UIBarButtonItem alloc] initWithTitle:@"Delete" style:UIBarButtonItemStyleBordered target:self action:@selector(ToggleEdit:)];
    self.navigationItem.rightBarButtonItem = editButton;
    [editButton release];
    
    if (_refreshHeaderView == nil) { 
        EGORefreshTableHeaderView *view1 = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f,10.0f - self.tableView.bounds.size.height,self.tableView.bounds.size.width,self.tableView.bounds.size.height)]; 
        view1.delegate = self; 
        [self.tableView addSubview:view1]; 
        _refreshHeaderView = view1; 
        [view1 release]; 
    } 
    [_refreshHeaderView refreshLastUpdatedDate]; 
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)dealloc
{
    [favoriteDic release];
     [m_waitTimeResult release];
  [m_routesResult release];
    [lastRefresh release];
    [super dealloc];
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

-(void)fetchDatafromPlist
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [m_waitTimeResult removeAllObjects];
    [m_routesResult removeAllObjects];
    favoriteDic = [[prefs objectForKey:@"user"] mutableCopy];
    NSError* error;
    for(NSArray *allWaitTimeURL in [favoriteDic allValues]){
        //NSStringEncoding encoding;
        BOOL is_waitTime = NO;
        for (NSString * arr_data in allWaitTimeURL ){
            if (is_waitTime){
                UInt32 big5 = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5);
                NSData* data = [[NSString stringWithContentsOfURL:[NSURL URLWithString: arr_data] encoding:big5 error:&error] dataUsingEncoding:big5];
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
                [m_waitTimeResult  addObject: [buf2 content] ];	
                [parser release];
                is_waitTime = NO;
            }
            else{
                //[m_waitTimeResult  addObject: arr_data ];	
                is_waitTime = YES;
                
            }
        }
    }
    [self.tableView reloadData];
    

    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self fetchDatafromPlist];
  /*  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    favoriteDic = [[prefs objectForKey:@"user"] mutableCopy];
    NSError* error;
    for(NSArray *allWaitTimeURL in [favoriteDic allValues]){
    //NSStringEncoding encoding;
    BOOL is_waitTime = NO;
    for (NSString * arr_data in allWaitTimeURL ){
        if (is_waitTime){
            UInt32 big5 = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5);
            NSData* data = [[NSString stringWithContentsOfURL:[NSURL URLWithString: arr_data] encoding:big5 error:&error] dataUsingEncoding:big5];
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
            [m_waitTimeResult  addObject: [buf2 content] ];	
            [parser release];
            is_waitTime = NO;
        }
        else{
            [m_waitTimeResult  addObject: arr_data ];	
            is_waitTime = YES;
           
        }
    }
    }
    [self.tableView reloadData];
    */
    
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

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

-(NSString* )tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    return [[favoriteDic allKeys] objectAtIndex:section];
}


-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
   // [self constructTableGroups];
    
    NSString *removeArrKey = [NSString stringWithString: [ [favoriteDic allKeys] objectAtIndex:indexPath.section ] ];
    NSMutableDictionary* temp_favoriteDic = [favoriteDic mutableCopy];
    NSMutableArray * removeArr= [[temp_favoriteDic objectForKey: [[temp_favoriteDic allKeys] objectAtIndex:indexPath.section ]]mutableCopy] ;
    [removeArr removeObjectAtIndex:indexPath.row];
    [removeArr removeObjectAtIndex:indexPath.row];
    //[temp_favoriteDic removeObjectForKey: removeArrKey ] ; //should use a tmp and you can void a dealloc
    [temp_favoriteDic setObject:removeArr forKey:removeArrKey];
   
     NSLog(@"%u",indexPath.section);
      [tableView beginUpdates];
    if ( [removeArr count] ){
      [tableView deleteRowsAtIndexPaths:[[NSArray arrayWithObject:indexPath] retain] withRowAnimation:UITableViewRowAnimationFade];
        favoriteDic = [temp_favoriteDic mutableCopy]; 
        [tableView endUpdates];
    }
   else {
       [temp_favoriteDic removeObjectForKey: removeArrKey ];
        favoriteDic = [temp_favoriteDic mutableCopy]; 
       [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:YES];
       [tableView endUpdates];
       
   }
     
     NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
     [prefs setObject:favoriteDic forKey:@"user"];
     [prefs synchronize];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
   // printf("%lu\n",sizeof(*rowNumberInSection));
    
    return [[ favoriteDic  allKeys] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSArray *keys = [favoriteDic allKeys];
    int rowsNumber = [[favoriteDic objectForKey: [keys objectAtIndex:section ]] count]/2;
    rowNumberInSection[ section ] = rowsNumber;
    return rowsNumber; 
}

-(int) accumlationOfRowNumberToSection : (int)nowSection
{
    int acc=0;
    for (int i=0 ; i<nowSection ; ++i)
        acc+=rowNumberInSection[i];
    //printf("enter\n");
    
    return acc;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    //[m_routesResult addObject: [[favoriteDic objectForKey: [[favoriteDic allKeys] objectAtIndex:indexPath.section ]] objectAtIndex: indexPath.row*2]  ];
    cell.textLabel.text = [[favoriteDic objectForKey: [[favoriteDic allKeys] objectAtIndex:indexPath.section ]] objectAtIndex: indexPath.row*2];
   cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
    cell.detailTextLabel.text = [m_waitTimeResult objectAtIndex: [self accumlationOfRowNumberToSection:indexPath.section] + indexPath.row] ;
    /*NSString* temp;
     int num = 0,i=0;
    for (NSString *waitTimeResult in m_waitTimeResult) {
        if ([waitTimeResult isEqualToString:cell.textLabel.text]&&num<=indexPath.section) {
            temp = [[[NSString alloc] initWithString:[m_waitTimeResult objectAtIndex:i+1]] autorelease];
            num++;
        }
        i++;
    }
    cell.detailTextLabel.text = temp;*/
    if ([cell.detailTextLabel.text isEqualToString:@"即將進站..."]) {
        cell.detailTextLabel.textColor = [UIColor redColor];
    }
    else if ([cell.detailTextLabel.text isEqualToString:@"目前無公車即時資料"]) {
        cell.detailTextLabel.textColor = [UIColor grayColor];
    }
    else{
        cell.detailTextLabel.textColor = [UIColor colorWithRed:35.0/255 green:192.0/255 blue:46/255 alpha:1];        
    }
    cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
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
    self.lastRefresh = [NSDate date];
    [self fetchDatafromPlist];
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView]; 
    //[self fetchDatafromPlist];
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
