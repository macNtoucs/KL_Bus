//
//  RootViewController.m
//  bus
//
//  Created by mac_hero on 12/5/18.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "AllRoutesViewController.h"
#define kPlainId				@"Plain"
#define kTextFieldId			@"TextField"

@implementation RootViewController

@synthesize editCell			= _editCell;
@synthesize editWindow			= _editWindow;

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
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismisskeyboard)];
    tap.cancelsTouchesInView=NO;
    [self.tableView addGestureRecognizer:tap];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textDidChange) name:UITextFieldTextDidChangeNotification object:self.editCell.view];
    instant_search = [SearchTableViewController new];
    [instant_search setEnterFromRoot:self];
    instant_search.view.frame = CGRectMake(50, 87, 220, 0);
    instant_search.tableView.layer.borderWidth = 2.0f;
    instant_search.tableView.layer.borderColor = [UIColor lightGrayColor].CGColor;
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows; //section 裡面rows的數量
    if (section==0) rows=4;
    if (section==1) rows=1;
    return rows;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section)
	{
		case 0:
			return @"公車資訊:";
        case 1:
            return @"其他資訊:";
	}
	return nil;
}

- (UITextField *)createTextField_Rounded
{
	CGRect frame = CGRectMake(30.0, 0.0, 50.0, [CellTextField editHeight]);
	UITextField *returnTextField = [[[UITextField alloc] initWithFrame:frame] autorelease];
    
	returnTextField.borderStyle = UITextBorderStyleRoundedRect;
    returnTextField.textColor = [UIColor blackColor];
	returnTextField.font = [CellTextField editFont];
    returnTextField.placeholder = @"請輸入站牌";
    returnTextField.backgroundColor = [UIColor whiteColor];
	returnTextField.autocorrectionType = UITextAutocorrectionTypeNo;	// no auto correction support
	
	returnTextField.keyboardType =UIKeyboardTypeDefault;
	returnTextField.returnKeyType = UIReturnKeyGo;
	
	returnTextField.clearButtonMode = UITextFieldViewModeWhileEditing;	// has a clear 'x' button to the right
	self.editWindow = returnTextField;
    
	return returnTextField;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    if ( indexPath.section==0){
    switch (indexPath.row)
    {
        case 0:
        {    
            
                self.editCell =  [[[CellTextField alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kTextFieldId] autorelease];	
                self.editCell.view = [self createTextField_Rounded];
                self.editCell.delegate = self;
                self.editCell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
                self.editCell.imageView.image = [UIImage imageNamed:@"Find.png"]; 
                self.editCell.cellLeftOffset = 40.0;
            
            // printf("kTableFindRowId %p\n", sourceCell);
                return self.editCell;	
        }

      case 1:
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kPlainId];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kPlainId] autorelease];
            }
            
            // Set up the cell
            cell.textLabel.text = @"瀏覽所有公車路線";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            //[self maybeAddSectionToAccessibility:cell indexPath:indexPath alwaysSaySection:YES];
           // cell.imageView.image = [self getActionIcon:kIconBrowse]; 
           // cell.textLabel.font = [self getBasicFont];
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            return cell;
        }
    
        case 2:
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kPlainId];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kPlainId] autorelease];
            }
            
            // Set up the cell
            cell.textLabel.text = @"現在位置";	
           // cell.textLabel.font = [self getBasicFont];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            //[self maybeAddSectionToAccessibility:cell indexPath:indexPath alwaysSaySection:YES];
            //cell.imageView.image = [self getActionIcon:kIconLocate]; 
            return cell;
        }
        case 3:
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kPlainId];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kPlainId] autorelease];
            }
            
            // Set up the cell
            cell.textLabel.text = @"常用站牌";
            // cell.textLabel.font = [self getBasicFont];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            //[self maybeAddSectionToAccessibility:cell indexPath:indexPath alwaysSaySection:YES];
            //cell.imageView.image = [self getActionIcon:kIconArrivals]; 
            return cell;
        }
    }
    }
    if (indexPath.section==1){
    switch (indexPath.row) {
        {
        case 0:{
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kPlainId];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kPlainId] autorelease];
            }
            
            cell.textLabel.text = @"關於我";	
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
        }
       
            }
    }
    return nil;
}

-(void)dealloc
{
    [ _editCell	release];
    [ _editWindow release];
    [super dealloc];
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

-(void) resign{
    [instant_search.view removeFromSuperview];
}

-(void) dismisskeyboard{
    [_editWindow resignFirstResponder];
    [NSTimer scheduledTimerWithTimeInterval: 0.2
                                             target: self
                                           selector: @selector(resign)
                                           userInfo: nil
                                            repeats: NO];
}

-(void)textDidChange{
    if([self.editCell.view.text length]==0)
        [instant_search.view removeFromSuperview];
    else{
        [instant_search setInfo:self.editCell.view.text];
        int height = [[instant_search getSearchResult]count];
        if (height>3) {
            height = 3;
        }
        instant_search.view.frame = CGRectMake(50, 87, 220, height*44);
        [instant_search.tableView reloadData];
        [self.view addSubview: instant_search.view];
    }
        
    
}

- (NSString *)justNumbers:(NSString *)text
{
	NSMutableString *res = [[[NSMutableString alloc] init] autorelease];
	
	int i=0;
	unichar c;
	
	for (i=0; i< [text length]; i++)
	{
		c = [text characterAtIndex:i];
		
        [res appendFormat:@"%C", c];
	
	}
	
	return res;
	
}

-(void)postEditingAction:(UITextView *)textView;
{
	NSString *editText = [self justNumbers:textView.text];
	
	if (editText.length !=0)
	{
        SearchTableViewController *table = [[SearchTableViewController alloc] init];
        [table setInfo:editText];
        table.title = editText;
       
        [self.navigationController pushViewController:table animated:YES];
      
        [table release];
	}
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	switch(indexPath.section)
	{
		case 0:
		{
			
			UITextView *textView = (UITextView*)[self.editCell view];
			
			NSString *editText = [self justNumbers:textView.text];
			
			if ([editText length] == 0)
			{
				return;
			}
			
            // UITextView *textView = (UITextView*)[self.editCell view];
            [self postEditingAction:textView];
			break;
		}
	}


}


-(void)UpdateGPS{
	locationManager = [[CLLocationManager alloc] init]; 
	[locationManager setDelegate:self]; 
	[locationManager setDesiredAccuracy:kCLLocationAccuracyBest];	
	[locationManager startUpdatingLocation];
    isLocateFinished = NO;
}

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
    if (! isLocateFinished){   
        [locationManager stopUpdatingLocation];
        MapViewController *map = [[MapViewController alloc] init];
        map.title = @"現在位置";
        [map setlocation:[newLocation coordinate]latitudeDelta:0.001 longitudeDelta:0.001];
        [self.navigationController pushViewController:map animated:YES];
        isLocateFinished = YES;
    }
    
}

- (void)locationManager:(CLLocationManager *)manadger
	   didFailWithError:(NSError *)error
{
    [locationManager stopUpdatingLocation];
    switch (error.code)
    {
            /*default:
             case kCLErrorLocationUnknown:
             break;
             case kCLErrorDenied:
             [self failedToLocate];
             waitingForLocation = NO;
             failed = YES;
             [self stopAnimating:YES];
             [self reinit];
             [self reloadData];
             break;*/
    }
}
    
#pragma mark - Table view delegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    
    //執行取消發送電子郵件畫面的動畫
    [self dismissModalViewControllerAnimated:YES];
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
    if(indexPath.section==0){
    switch (indexPath.row) {
        case 1:{
            AlertViewDelegate *alert = [[AlertViewDelegate alloc]init];
            [alert AlertViewStart];
            AllRoutesViewController *router = [AllRoutesViewController new];
            router.title = @"公車路線";
            [self.navigationController pushViewController:router animated:YES];
            [router release];
            [alert AlertViewEnd];
            break;
        }
        case 2:{
            AlertViewDelegate *alert = [[AlertViewDelegate alloc]init];
            [alert AlertViewStart];
            [self UpdateGPS];
            [alert AlertViewEnd];
            break;
        }
        case 3:{
            AlertViewDelegate *alert = [[AlertViewDelegate alloc]init];
            [alert AlertViewStart];
            FavoriteViewController *favorite = [[FavoriteViewController alloc] initWithStyle:UITableViewStylePlain];
            favorite.title = @"常用路線";
            [self.navigationController pushViewController:favorite animated:YES];
            [favorite release];
            [alert AlertViewEnd];
            break;
        }
        default:
            break;
        }
    }
    if (indexPath.section==1){
        switch (indexPath.row){
            case 0:{
                AboutMeTableViewController *controller = [[AboutMeTableViewController alloc]initWithStyle:UITableViewStyleGrouped];
                controller.title = @"關於我";
                [self.navigationController pushViewController:controller animated:YES];
                [controller release];
                break;   
            }
                     
        }
    }
}

@end
