//
//  AboutMeTableViewController.m
//  bus
//
//  Created by mac_hero on 12/7/19.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "AboutMeTableViewController.h"
#import "CellLabel.h"


@implementation AboutMeTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"Tips & About & Links";
		aboutText = [[NSString stringWithFormat:@"Version %@\n\n"
                      "開發人員 : 托雷·哈特涅特、我的搭擋是宅男\n"
                      "現有功能: [0] 即時搜尋\n"
                      "                [1] 檢索所有公車路線\n"
                      "                [2] 加入常用站牌功能\n"
                      "                [3] 目前位置定位\n\n", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]] retain];

    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
       [self dismissModalViewControllerAnimated:YES];
}

-(IBAction)mail:(id)sender
{
    //建立物件與指定代理
    MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    //設定收件人與主旨等資訊
    [controller setToRecipients:[NSArray arrayWithObjects:@"mac.ntoucs@gmail.com",nil]];
    [controller setSubject:@"基隆公車意見回饋"];
    //設定內文並且不使用HTML語法
    //[controller setMessageBody:@"test" isHTML:NO];
    //顯示電子郵件畫面
    [self presentModalViewController:controller animated:YES];
    
    [controller release];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem =  [[UIBarButtonItem alloc] initWithTitle:@"意見回饋" style:UIBarButtonItemStylePlain target:self action:@selector(mail:)];
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
    return 1;
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

- (UIFont*)getParagraphFont
{
	if (_paragraphFont == nil)
	{
		if (SMALL_SCREEN(self.screenWidth))
		{
			_paragraphFont =[[UIFont systemFontOfSize:14.0] retain];
		}
		else {
			_paragraphFont = [[UIFont systemFontOfSize:22.0] retain];
		}		
	}
	return _paragraphFont;
}

- (UILabel *)create_UITextView:(UIColor *)backgroundColor font:(UIFont *)font;
{
	CGRect frame = CGRectMake(0.0, 0.0, 100.0, 200.0);
	
	
	UILabel *textView = [[[UILabel alloc] initWithFrame:frame] autorelease];
    textView.textColor = [UIColor blackColor];
    textView.font = font; // ;
	//    textView.delegate = self;
	//	textView.editable = NO;
	if (backgroundColor ==nil)
	{
		textView.backgroundColor = [UIColor clearColor];
	}
	else
	{
		textView.backgroundColor = backgroundColor;
		
	}
	textView.lineBreakMode =   UILineBreakModeWordWrap;
	textView.adjustsFontSizeToFitWidth = YES;
	textView.numberOfLines = 0;
	
	// note: for UITextView, if you don't like autocompletion while typing use:
	// myTextView.autocorrectionType = UITextAutocorrectionTypeNo;
	
	return textView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"about";
    
    CellLabel *cell = (CellLabel *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[CellLabel alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.view = [self create_UITextView:nil font:[self getParagraphFont]];
    }
    
    if (indexPath.section==0) {
        cell.view.font =  [self getParagraphFont];
        cell.view.text = aboutText;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessibilityLabel = aboutText;
    }
        // Configure the cell...
    
    return cell;
}

- (CGFloat)getTextHeight:(NSString *)text font:(UIFont *)font;
{
	CGFloat width = 0.0;

    switch ([self screenWidth])
		{
            case WidthiPadNarrow:
                width = 700.0 - font.pointSize;
                break;
            case WidthiPadWide:
                width = 1000.0 - font.pointSize;
                break;
            case WidthiPhoneNarrow:
                width = 300.0 - font.pointSize;
                break;
            default:
                //case WidthiPhoneWide:
                //	width = 460.0 - font.pointSize;
                break;
		}
	CGSize rect = CGSizeMake(width, MAXFLOAT);
	CGSize sz = [text sizeWithFont:font constrainedToSize:rect lineBreakMode:UILineBreakModeWordWrap];
	return sz.height + font.pointSize;
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
	switch (indexPath.section) {

		case 0:
			if (indexPath.row == 0)
			{
				return [self getTextHeight:aboutText font:[self getParagraphFont]];
			}
			break;

		default:
			break;
	}
	return [self basicRowHeight];
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

@end
