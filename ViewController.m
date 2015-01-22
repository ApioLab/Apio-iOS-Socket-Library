//
//  ViewController.m
//  apio-comunication-library
//
//  Created by Matteo Pio Napolitano on 17/01/15.
//  Copyright (c) 2015 OnCreate. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <ApioIOSocketDelegate>

@property (weak, nonatomic) IBOutlet UISwitch *switch_piantana;
@property (weak, nonatomic) IBOutlet UISlider *slider_piantana_rosso;
@property (weak, nonatomic) IBOutlet UISlider *slider_piantana_verde;
@property (weak, nonatomic) IBOutlet UISlider *slider_piantana_blu;

@property (nonatomic, strong) ApioIOSocket *aios;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.switch_piantana setSelected:NO];
    self.slider_piantana_rosso.minimumValue = 0;
    self.slider_piantana_rosso.maximumValue = 255;
    self.slider_piantana_rosso.continuous = NO;
    
    self.slider_piantana_verde.minimumValue = 0;
    self.slider_piantana_verde.maximumValue = 255;
    self.slider_piantana_verde.continuous = NO;
    
    self.slider_piantana_blu.minimumValue = 0;
    self.slider_piantana_blu.maximumValue = 255;
    self.slider_piantana_blu.continuous = NO;
    
    self.aios = [[ApioIOSocket alloc] initWithHost:@"http://debian.local" andPort:@"8083"];
    self.aios.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)onSocketReady:(NSDictionary *)initialConfiguration
{
    NSLog(@"onSocketReady %@", initialConfiguration);
}

- (void)onSocketConnectionFailed
{
    NSLog(@"onSocketConnectionFailed");
}

- (void)onEventReceived:(NSArray*)data
{
    NSLog(@"onEventReceived %@", data);
}

- (void)onSocketError:(NSDictionary*)error
{
    NSLog(@"onSocketError %@", error);
}

- (void)onSocketDisconnected
{
    NSLog(@"onSocketDisconnected");
}

- (void)onSocketReconnect
{
    NSLog(@"onSocketReconnect");
}

- (void)onSocketReconnectionError
{
    NSLog(@"onSocketReconnectionError");
}

- (IBAction)buttonStatoPiantanaPressed:(id)sender
{
    [self getStateInformationForObject:4545];
}

- (IBAction)piantanaChangeStateAction:(id)sender {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
    
    if ([self.switch_piantana isOn]) {
        [properties setObject:[NSNumber numberWithInt:1] forKey:@"onoff"];
    }
    else{
        [properties setObject:[NSNumber numberWithInt:0] forKey:@"onoff"];
    }
    
    [dict setObject:[NSNumber numberWithInt:4545] forKey:@"objectId"];
    [dict setObject:properties forKey:@"properties"];
    [dict setObject:@"true" forKey:@"writeToDatabase"];
    [dict setObject:@"true" forKey:@"writeToSerial"];
    
    NSDictionary *data = [[NSDictionary alloc] initWithDictionary:dict];
    [self.aios emit:@"apio_client_update" data:data];
}

- (IBAction)sliderRossoChangedAction:(id)sender {
    NSUInteger valore = (NSUInteger)(self.slider_piantana_rosso.value);
    NSLog(@"sliderRossoChangedAction");
    [self changeColor:@"rosso" setValue:valore];
}

- (IBAction)sliderVerdeChangedAction:(id)sender {
    NSUInteger valore = (NSUInteger)(self.slider_piantana_rosso.value);
    NSLog(@"sliderVerdeChangedAction");
    [self changeColor:@"verde" setValue:valore];
}

- (IBAction)sliderBluChangedAction:(id)sender {
    NSUInteger valore = (NSUInteger)(self.slider_piantana_rosso.value);
    NSLog(@"sliderBluChangedAction");
    [self changeColor:@"blu" setValue:valore];
}

-(void)changeColor:(NSString*)color setValue:(int)value
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
    
    [properties setObject:[NSNumber numberWithInt:value] forKey:color];
    
    [dict setObject:[NSNumber numberWithInt:4545] forKey:@"objectId"];
    [dict setObject:properties forKey:@"properties"];
    [dict setObject:@"true" forKey:@"writeToDatabase"];
    [dict setObject:@"true" forKey:@"writeToSerial"];
    
    NSDictionary *data = [[NSDictionary alloc] initWithDictionary:dict];
    [self.aios emit:@"apio_client_update" data:data];
}

-(void)getStateInformationForObject:(int)objectId
{
    HTTPClient *client = [[HTTPClient alloc] init];
    NSString *payload = [@"http://debian.local:8083/apio/object/" stringByAppendingString:[NSString stringWithFormat:@"%d", objectId]];
    NSURL *url = [NSURL URLWithString: payload];
    [client connect:url
             method:@"GET"
        beforeStart:^{
            // puoi implementare callback eseguita prima dell'avvio della connessione
        }
   duringConnection:^{
       // puoi implementare callback eseguita durante la connessione
   }
      afterComplete:^{
          NSDictionary *responsedata = [client responsedata];
          if (responsedata != nil) {
              dispatch_async(dispatch_get_main_queue(), ^{
                  NSLog(@"%@",[client responsedata]);
                  UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Stato Oggetto"
                                                                       message:[NSString stringWithFormat:@"%@", [client responsedata]]
                                                                      delegate:nil
                                                             cancelButtonTitle:nil
                                                             otherButtonTitles:@"OK", nil];
                  [alertView show];
              });
          }
          else {
              dispatch_async(dispatch_get_main_queue(), ^{
                  UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Stato Oggetto"
                                                                       message:@"Errore della classe HTTPClient"
                                                                      delegate:nil
                                                             cancelButtonTitle:nil
                                                             otherButtonTitles:@"OK", nil];
                  [alertView show];
              });
          }
      }];
}

@end