//
//  GpsTableViewController.m
//  bus
//
//  Created by mac_hero on 12/7/19.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "GpsTableViewController.h"
#import "RootViewController.h"
#define kLocatingSection	0
#define kDistanceSection	1
#define kShowSection        2
#define kGoSection			3

#define kLocatingAccuracy	0
#define kLocatingStop		1

#define kShowArrivals		0
#define kShowMap			1
#define kShowRoute			2

#define kDistanceNextToMe	0
#define kDistanceHalfMile   1
#define kDistanceMile		2
#define kDistance3Miles		3

#define kSegRowWidth		320
#define kSegRowHeight		40
#define kUISegHeight		40
#define kUISegWidth			320

#define kLocatingRowHeight		60.0
#define MAX_AGE					-30.0
#define TEXT_TAG 1


#define kDistNextToMe (kDistMile / 10)
#define kDistHalfMile 804.67200
#define kDistMile	  1609.344
#define kMaxStops	  12
#define kAccNextToMe  0.0010
#define kAccHalfMile  0.0015
#define kAccClosest	  250
#define kAccMile	  0.0030
#define kAcc3Miles	  0.0080
#define kDistMax	  16093.44  // 10 miles in meters
#define GoogleAPIKey @"AIzaSyDfy2pHWVzEjNcGIc9gYVBHfHFHrkPU8gI"


@implementation GpsTableViewController
@synthesize progressInd			= _progressInd;
@synthesize progressCell		= _progressCell;
@synthesize lastLocation		= _lastLocation;
@synthesize locationManager;
@synthesize timeStamp;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) reinit
{
	if (waitingForLocation )
	{
		sections		= 1;
	}
	else 
	{
		sections		= 3;
	}
}

- (id) init
{
	if ((self = [super initWithStyle:UITableViewStyleGrouped]))
	{
        self.locationManager = [[[CLLocationManager alloc] init] autorelease];
		self.locationManager.delegate = self; // Tells the location manager to send updates to this object
		self.title = @"Locate Stops";
		waitingForLocation = NO;
		
		[self reinit];
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

- (int)sectionType:(int)section
{
	if (waitingForLocation )
	{
		return kLocatingSection;
	}
	
	return section + 1;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	switch ([self sectionType:section])
	{
        case kLocatingSection:
			return @"Acquiring location. Accuracy will improve momentarily; search will start when accuracy is sufficient or whenever you choose.";
		case kDistanceSection:
			return @"Search radius:";
		case kShowSection:
			return @"Show:";
		case kGoSection:
			return [NSString stringWithFormat:@"Choosing 'Arrivals' will show a maximum of 12 stops."];
	}
	return nil;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
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
    return sections;
}




- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if ([self sectionType:section] == kLocatingSection)
	{
		return 2;
	}
	return 1;
}

- (void)distSegmentChanged:(id)sender
{
	UISegmentedControl *seg = (UISegmentedControl *)sender;
	dist = seg.selectedSegmentIndex;
}

- (void)showSegmentChanged:(id)sender
{
	UISegmentedControl *seg = (UISegmentedControl *)sender;
	show = seg.selectedSegmentIndex;
}


- (UISegmentedControl *)getSeg:(UITableViewCell *)cell
{
	for (UIView *v in cell.contentView.subviews)
	{
		if ([v isKindOfClass:[UISegmentedControl class]])
		{
			return (UISegmentedControl *)v;
		}
	}
	
	return nil;
}


- (UITableViewCell *)accuracyCellWithReuseIdentifier:(NSString *)identifier {
	
	/*
	 Create an instance of UITableViewCell and add tagged subviews for the name, local time, and quarter image of the time zone.
	 */
	CGRect rect;
	
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
	
#define LEFT_COLUMN_OFFSET 20.0
#define LEFT_COLUMN_WIDTH 30.0
#define LEFT_COLUMN_HEIGHT 35.0
	
#define MAIN_FONT_SIZE 16.0
#define LABEL_HEIGHT (kLocatingRowHeight - 10.0)
#define LABEL_COLUMN_OFFSET (LEFT_COLUMN_OFFSET + LEFT_COLUMN_WIDTH + 5.0)
#define LABEL_COLUMN_WIDTH  (260.0 - LEFT_COLUMN_WIDTH)
	
	CGRect frame = CGRectMake(LEFT_COLUMN_OFFSET, (kLocatingRowHeight - LEFT_COLUMN_HEIGHT) / 2.0, LEFT_COLUMN_WIDTH, LEFT_COLUMN_HEIGHT);
	self.progressInd = [[[UIActivityIndicatorView alloc] initWithFrame:frame] autorelease];
	self.progressInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
	self.progressInd.hidesWhenStopped = YES;
	[self.progressInd sizeToFit];
	self.progressInd.autoresizingMask =  (UIViewAutoresizingFlexibleTopMargin |
                                          UIViewAutoresizingFlexibleBottomMargin);
	[cell.contentView addSubview:self.progressInd];
	
	
	/*
	 Create labels for the text fields; set the highlight color so that when the cell is selected it changes appropriately.
	 */
	UILabel *label;
	
	rect = CGRectMake(LABEL_COLUMN_OFFSET, (kLocatingRowHeight - LABEL_HEIGHT) / 2.0, LABEL_COLUMN_WIDTH, LABEL_HEIGHT);
	label = [[UILabel alloc] initWithFrame:rect];
	label.tag = TEXT_TAG;
	label.font = [UIFont boldSystemFontOfSize:MAIN_FONT_SIZE];
	label.adjustsFontSizeToFitWidth = NO;
	label.numberOfLines = 0;
	label.lineBreakMode = UILineBreakModeWordWrap;
	[cell.contentView addSubview:label];
	label.highlightedTextColor = [UIColor whiteColor];
	label.textColor  = [UIColor blackColor];
	label.autoresizingMask =  (UIViewAutoresizingFlexibleWidth);
	label.backgroundColor = [UIColor clearColor];
	[label release];
	
	[cell.contentView layoutSubviews];
	
	self.progressCell = cell;
	
	return cell;
}


- (ScreenType)screenWidth
{
	CGRect bounds = [[UIScreen mainScreen] bounds];
	
	switch (self.interfaceOrientation)
	{
		case UIInterfaceOrientationPortraitUpsideDown:	
		case UIInterfaceOrientationPortrait:
			if (bounds.size.width <= kSmallestSmallScreenDimension)
			{
				return WidthiPhoneNarrow;
			}
			return WidthiPadNarrow;
		case	UIInterfaceOrientationLandscapeLeft:
		case	UIInterfaceOrientationLandscapeRight:
			return WidthiPadWide;
	}
    
	return WidthiPadWide;
}

- (UIFont*)getBasicFont
{
    UIFont * _basicFont = [[UIFont alloc] init];
	if (_basicFont == nil)
	{
		if (SMALL_SCREEN(self.screenWidth))
		{
			_basicFont =[[UIFont boldSystemFontOfSize:18.0] retain];
		}
		else 
		{
			_basicFont = [[UIFont boldSystemFontOfSize:22.0] retain];
		}		
	}
	return _basicFont;
}

- (UIView *)clearView
{
	UIView *backView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
	backView.backgroundColor = [UIColor clearColor];
	return backView;
}

- (UITableViewCell *)segCell:(NSString*)cellId items:(NSArray*)items 
		   accessibilityText:(NSString *)str action:(SEL)action
{
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId] autorelease];
	
	UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:items];
	CGRect frame = CGRectMake((kSegRowWidth-kUISegWidth)/2, (kSegRowHeight - kUISegHeight)/2 , kUISegWidth, kUISegHeight);
	segmentedControl.frame = frame;
	[segmentedControl addTarget:self action:action forControlEvents:UIControlEventValueChanged];
	segmentedControl.segmentedControlStyle = UISegmentedControlStylePlain;
	segmentedControl.autoresizingMask =   UIViewAutoresizingFlexibleWidth;
	[cell.contentView addSubview:segmentedControl];
	[segmentedControl autorelease];
	
	
	[cell layoutSubviews];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	[cell setAccessibilityLabel:str];
	cell.isAccessibilityElement = YES;
	cell.backgroundView = [self clearView];
	
	return cell;
	
}



-(NSString *)formatDistance:(double)distance
{
	NSString *str = nil;
	if (distance < 500)
	{
		str = [NSString stringWithFormat:@"Distance: %d ft (%d meters)", (int)(distance * 3.2808398950131235),
			   (int)(distance) ];
	}
	else
	{
		str = [NSString stringWithFormat:@"Distance: %.2f miles (%.2f km)", (float)(distance / 1609.344),
			   (float)(distance / 1000) ];
	}	
	return str;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    switch ([self sectionType:indexPath.section])
	{
		case kDistanceSection:
		{
			static NSString *segmentId = @"dist";
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:segmentId];
			if (cell == nil) {
				cell = [self segCell:segmentId 
							   items:[NSArray arrayWithObjects:@"Closest", @"½ mile", @"1 mile", @"3 miles", nil]
				   accessibilityText:@"search radius"
							  action:@selector(distSegmentChanged:)];
			}	
			
			[self getSeg:cell].selectedSegmentIndex = dist;
			return cell;	
		}
        case kShowSection:
		{
			static NSString *segmentId = @"show";
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:segmentId];
			if (cell == nil) {
				cell = [self segCell:segmentId 
							   items:[NSArray arrayWithObjects:@"Arrivals", @"Map", nil]
				   accessibilityText:@"show"
							  action:@selector(showSegmentChanged:)];
			}	
			
			[self getSeg:cell].selectedSegmentIndex = show;
			return cell;	
		}
        case kGoSection:
		{
            static NSString *kGoCellId = @"go";
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kGoCellId];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kGoCellId] autorelease];
			}
			cell.textLabel.text = @"Start locating";
			cell.textLabel.textAlignment = UITextAlignmentCenter;
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.textLabel.font = [self getBasicFont];
			
			cell.accessibilityLabel = cell.textLabel.text;
			return cell;
		}
        case kLocatingSection:
		{
			switch (indexPath.row)
			{
				case kLocatingAccuracy:
				{
					static NSString *locSecid = @"LocatingSection";
					UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:locSecid];
					if (cell == nil) {
						cell = [self accuracyCellWithReuseIdentifier:locSecid];
						
                        
					}
					
					UILabel* text = (UILabel *)[cell.contentView viewWithTag:TEXT_TAG];
					
					[self.progressInd startAnimating];
					
					if (self.lastLocation != nil)
					{
						text.text = [NSString stringWithFormat:@"Accuracy acquired:\n+/- %@", 
									 [self formatDistance:self.lastLocation.horizontalAccuracy]];
						cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
						[cell setAccessibilityHint:@"Double-tap for arrivals"];
					}
					else
					{
						text.text = @"Locating...";
						cell.accessoryType = UITableViewCellAccessoryNone;
						[cell setAccessibilityHint:nil];
					}
					cell.accessibilityLabel = text.text;
					return cell;
				}
				case kLocatingStop:
				{
					UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"Location"];
					if (cell == nil) {
						cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: @"Location"] autorelease];
					}
					cell.textLabel.text = @"Cancel";
					cell.accessoryType = UITableViewCellAccessoryNone;
					cell.imageView.image = [UIImage imageNamed:@"cancel.png"];
					cell.textLabel.font = [self getBasicFont];
                    cell.accessibilityLabel = cell.textLabel.text;
					return cell;
				}	
			}
		}
    }
    // Configure the cell...

    return nil;
}

- (CGFloat)basicRowHeight
{
	if (SMALL_SCREEN(self.screenWidth))
	{
		return 40.0;
	}
	return 45.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CGFloat result = 0.0;
    
	switch ([self sectionType:indexPath.section])
	{
		case kLocatingSection:
			result = kLocatingRowHeight;
			break;
		case kDistanceSection:
		case kShowSection:
			result = kSegRowHeight;
			break;
		case kGoSection:
			result = [self basicRowHeight];
			break;
	}
	return result;
}

-(void)UpdateGPS{
	locationManager = [[CLLocationManager alloc] init]; 
	[locationManager setDelegate:self]; 
	[locationManager setDesiredAccuracy:kCLLocationAccuracyBest];	
	[locationManager startUpdatingLocation];
}


- (void)startLocating
{
    switch (dist)
    {
        case kDistanceNextToMe:
            accuracy = kAccNextToMe;
            minDistance = kDistNextToMe;
            maxToFind = kMaxStops;
            break;	
        case kDistanceHalfMile:
            accuracy = kAccHalfMile;
            minDistance = kDistHalfMile;
            maxToFind = kMaxStops;
            break;
        case kDistanceMile:
            accuracy = kAccMile;
            minDistance = kDistMile;
            maxToFind = kMaxStops;
            break;
        case kDistance3Miles:
            accuracy = kAcc3Miles;
            minDistance = kDistMile * 3;
            maxToFind = kMaxStops;
            break;
    }
    waitingForLocation = YES;
    sections = 1;
    [self UpdateGPS];
    [[(RootViewController *)[self.navigationController topViewController] tableView] reloadData];
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
	switch ([self sectionType:indexPath.section])
	{
		case kGoSection:
            [self startLocating];
			break;
		case kLocatingSection:
		{
			if (indexPath.row == kLocatingAccuracy && self.lastLocation!=nil)
			{
				
			}
			else if(indexPath.row == kLocatingStop)
			{
				waitingForLocation = NO;
				[self reinit];
				[tableView deselectRowAtIndexPath:indexPath animated:NO];
				[[(RootViewController *)[self.navigationController topViewController] tableView] reloadData];
			}
			break;
		}
	}
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    cell.backgroundColor = [UIColor whiteColor];
    
    if ([cell.reuseIdentifier isEqualToString:@"go"])
	{
		cell.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
	}
	
	
}

//反查失敗
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error{
    
}

//反查成功
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark{
    

}

#pragma mark Location Manager callbacks


- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
	//CLLocationCoordinate2D loc = [[[CLLocation alloc] initWithLatitude:25.151024 longitude:121.773275] coordinate];
    
    if (show == 1)
	{
        MapViewController *map = [[MapViewController alloc] init];
        [map setlocation:[[[CLLocation alloc] initWithLatitude:25.151024 longitude:121.773275] coordinate]latitudeDelta:accuracy longitudeDelta:accuracy];
        //初始化
        MKReverseGeocoder *myReverse = [[MKReverseGeocoder alloc] initWithCoordinate:[[[CLLocation alloc] initWithLatitude:25.151024 longitude:121.773275] coordinate]];
        
        myReverse.delegate = self;
        
        //開始反查
        [myReverse start];

       // NSString *mapUrl = [NSString stringWithFormat: @"http://maps.google.com.tw/maps?q=%f,%f&hq=公車站&hnear=0x345d4f0685bf3e35:0x4feeb94a7d8dc7f,%%2B%.0f°+%.0f'+%3.2f\",+%%2B%.0f°+%.0f'+%3.2f\"", loc.latitude, loc.longitude,loc.latitude/1,fmod(loc.latitude, 1.0)/(1.0/60),(fmod(fmod(loc.latitude, 1.0),(1.0/60)))/(1.0/3600),loc.longitude/1,fmod(loc.longitude, 1.0)/(1.0/60),(fmod(fmod(loc.longitude, 1.0),(1.0/60)))/(1.0/3600)]; 
        /*NSString *mapUrl = [NSString stringWithFormat: @"http://maps.google.com.tw/maps?q=%f,%f&hq=公車站&ll=%f,%f",loc.latitude, loc.longitude,loc.latitude, loc.longitude];
		NSURL *url = [NSURL URLWithString:[mapUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]; 
		[[UIApplication sharedApplication] openURL:url]; */
        show = 0;
        waitingForLocation = false;
        [self reinit];
        UITableView *temp = [(RootViewController *)[self.navigationController topViewController] tableView];
        [self.navigationController pushViewController:map animated:YES];
        [locationManager stopUpdatingLocation];
        [temp reloadData];
	}
}

- (void)locationManager:(CLLocationManager *)manadger
	   didFailWithError:(NSError *)error
{
    
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

- (void) failedToLocate
{
	UIAlertView *alert = [[[ UIAlertView alloc ] initWithTitle:@"Locate stops"
													   message:@"Unable to find location"
													  delegate:nil
											 cancelButtonTitle:@"OK"
											 otherButtonTitles:nil] autorelease];
	[alert show];
	
	[[self navigationController] popViewControllerAnimated:YES];
	
}



@end
