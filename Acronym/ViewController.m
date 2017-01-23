//
//  ViewController.m
//  Acronym
//
//  Created by VinishaKolla on 1/22/17.
//  Copyright © 2017 Macys. All rights reserved.
//

#import "ViewController.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"


#define ServericeURL @"http://www.nactem.ac.uk/software/acromine/dictionary.py"

@interface ViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *tfAcronym;
@property (weak, nonatomic) IBOutlet UILabel *lblResult;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Text Field Delegate Methods 

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Button Actions 

- (IBAction)btnSearchClicked:(id)sender {
    
    [self setTheResult:@""];
    
    if( [self.tfAcronym.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]].length == 0){
        
        [self showAlertWithTitle:@"Error" withMessage:@"Please enter a valid Acronym"];
    }
    else {
        
        [self fetchTheFullForm:self.tfAcronym.text];
    }
    
    
}

#pragma mark - Other Helper Methods 

-(void)showAlertWithTitle:(NSString *)strTilte withMessage:(NSString *)strMessage {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:strTilte
                                                                             message:strMessage
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Ok"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [alertController addAction:actionOk];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)setTheResult:(NSString *)strResult {
    
    self.lblResult.text = strResult;
}


#pragma mark - Service Calls 

-(void)fetchTheFullForm:(NSString *)strAcronym {
    
    [self showLoader];
    
    
    NSDictionary *parameters = @{@"sf": self.tfAcronym.text};
    
   // NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:ServericeURL parameters:parameters error:nil];

    
    NSURL *baseURL = [NSURL URLWithString:@"http://www.nactem.ac.uk/software"];
    NSString *path = @"acromine/dictionary.py";

    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:path parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        // Success
        [self hideLoader];
        NSError *error = nil;
        NSData *responseData = (NSData*)responseObject;
        NSArray *arrJSON = [NSJSONSerialization JSONObjectWithData: responseData options: NSJSONReadingMutableContainers error: &error];
        if (arrJSON.count > 0 ){
            
            NSDictionary *dictResult = arrJSON [0];
            NSArray *arrLongForm = dictResult[@"lfs"];
            NSDictionary *dictDescription = arrLongForm[0];
            [self setTheResult:dictDescription[@"lf"]];
            
            
        }
        else {
            
            [self showAlertWithTitle:@"No results found" withMessage:nil];

        }

        
       
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        // Failure
        [self hideLoader];
        [self showAlertWithTitle:@"Error" withMessage:error.description];

    }];
    
    
    
}

#pragma mark - Loader 

-(void)showLoader {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    });
    
}

-(void)hideLoader {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
    
}





@end
