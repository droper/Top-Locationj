//
//  LastPhotosPlacesViewController.h
//  TopPlaces
//
//  Created by Marco Morales on 4/2/12.
//  Copyright (c) 2012 Casa. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LastPhotosPlacesViewController : UITableViewController

@property (nonatomic, strong) NSArray *photos; // of Flickr photo dictionaries

@property (nonatomic, strong) NSDictionary *place;




@end
