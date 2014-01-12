//
//  BGSViewController.m
//  BGS Client
//
//  Created by Peter Todd on 12/01/2014.
//  Copyright (c) 2014 Bright Green Star. All rights reserved.
//

#import "BGSViewController.h"
#import "BGSCreateAccount.h"
#import "BGSCreateTrip.h"
#import "BGSTrip.h"



#define SERVER_DEVELOPMENT @"http://127.0.0.1:3000/"



@interface BGSViewController ()

@property (weak, nonatomic) IBOutlet UITextField *txtAppServerURL;
@property (weak, nonatomic) IBOutlet UITextField *txtUserEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtUserPassword;

@property (weak, nonatomic) IBOutlet UITextField *txtTripName;
@property (weak, nonatomic) IBOutlet UITextField *txtTripType;
@property (weak, nonatomic) IBOutlet UITextView *tvTripDesc;

- (IBAction)butCreateAccountAction:(id)sender;
- (IBAction)butCreateTripAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;


@end

@implementation BGSViewController
{
    NSOperationQueue *_ftfQueue;
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.txtAppServerURL setText:SERVER_DEVELOPMENT];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.scrollView.contentSize = CGSizeMake(420, 1400);

     NSLog(@"Debug scrollview contentsize %f",self.scrollView.contentSize.height);
 
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)butCreateAccountAction:(id)sender {
    // Init the NSOperationQueue
    _ftfQueue = [NSOperationQueue new];
    // 1. Does this user already have an account?
    // We will add the create process as an NSOperation.
    BGSCreateAccount *createAccount = [[BGSCreateAccount alloc]init];
    [createAccount setUserEmail:[self.txtUserEmail text]];
    [createAccount setUserPassword:[self.txtUserPassword text]];
    [createAccount setAppServerURLAddress:[self.txtAppServerURL text]];
    [_ftfQueue addOperation:createAccount];

}

- (IBAction)butCreateTripAction:(id)sender {
   // Init the NSOperationQueue
    _ftfQueue = [NSOperationQueue new];
    // 1. Does this user have a FTF account?
    // We will add the create process as an NSOperation.  If it succeeds we will move on posting the data.
    BGSCreateAccount *createAccount = [[BGSCreateAccount alloc]init];
    [createAccount setUserEmail:[self.txtUserEmail text]];
    [createAccount setUserPassword:[self.txtUserPassword text]];
    [createAccount setAppServerURLAddress:[self.txtAppServerURL text]];
    [_ftfQueue addOperation:createAccount];
    
    BGSTrip *selectedTrip = [[BGSTrip alloc]initWithName:[self.txtTripName text] tripType:[self.txtTripType text] tripDesc:[self.tvTripDesc text]];

    BGSCreateTrip *postFTFRoute = [[BGSCreateTrip alloc]init];
    [postFTFRoute setSelectedTrip:selectedTrip];
    [postFTFRoute setAppServerURLAddress:[self.txtAppServerURL text]];
    [postFTFRoute addDependency:createAccount];
    
    [_ftfQueue addOperation:postFTFRoute];
    
    // If the Route is already shared then SYNC from server (to confirm not updated on server via another device)
    // Add any UI prompts and then update on server
    /*
     Not yet implementeded in the DEMO
     
     */
    
    NSLog(@"DEBUG Queue running!!");
    
}
@end
