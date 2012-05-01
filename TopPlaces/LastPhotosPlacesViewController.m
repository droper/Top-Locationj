//
//  LastPhotosPlacesViewController.m
//  TopPlaces
//
//  Created by Marco Morales on 4/2/12.
//  Copyright (c) 2012 Casa. All rights reserved.
//

#import "LastPhotosPlacesViewController.h"
#import "FlickrFetcher.h"
#import "PhotoViewController.h"


#define RECENT_PHOTOS_KEY @"photosId"


@interface LastPhotosPlacesViewController ()


@end

@implementation LastPhotosPlacesViewController

@synthesize photos = _photos;
@synthesize place = _place;

//cambio para probar el commit



- (void)setPhotos:(NSArray *)photos
{
    if (_photos != photos) {
        _photos = photos;
        // Model changed, so update our View (the table)
        [self.tableView reloadData];
    }
}

- (void)setPlace:(NSDictionary *)place
{
    if (_place != place) {
        _place = place;
            // Model changed, so update our View (the table)
        [self.tableView reloadData];
    }
}


- (IBAction)refresh:(id)sender
{
    // might want to use introspection to be sure sender is UIBarButtonItem
    // (if not, it can skip the spinner)
    // that way this method can be a little more generic
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    //NSDictionary *place = [FlickrFetcher topPlaces].lastObject;
                          
    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
    dispatch_async(downloadQueue, ^{
        NSArray *photos = [FlickrFetcher photosInPlace:self.place maxResults:50];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationItem.rightBarButtonItem = sender;
            self.photos = photos;
        });
    });
    dispatch_release(downloadQueue);
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
    return YES;
}


#pragma mark - UITableViewDataSource

/*
- (NSString *)photographerForSection:(NSInteger)section
{
    return [[self.photosByPhotographer allKeys] objectAtIndex:section];
}*/

/*- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self photographerForSection:section];
}*/

/*- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.photosByPhotographer count];
}*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // return [self.photos count];
    return [self.photos count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Flickr Place Photo";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    NSDictionary *photo = [self.photos objectAtIndex:indexPath.row];
    
    if (![[photo objectForKey:FLICKR_PHOTO_TITLE] isEqualToString:@""]) {
        cell.textLabel.text = [photo objectForKey:FLICKR_PHOTO_TITLE];
    } else if (![[photo objectForKey:FLICKR_PHOTO_DESCRIPTION] isEqualToString:@""]) {
        cell.textLabel.text = [photo objectForKey:FLICKR_PHOTO_DESCRIPTION];
    } else {
        cell.textLabel.text = @"Unknown";
    }
    
    
    cell.detailTextLabel.text = [photo objectForKey:FLICKR_PHOTO_DESCRIPTION];
    
    return cell;
}

- (PhotoViewController *)splitViewPhotoviewcontroller
{
    id gvc = [self.splitViewController.viewControllers lastObject];
    if (![gvc isKindOfClass:[PhotoViewController class]])
    {
        gvc = nil;
    }
    return gvc;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    [segue.destinationViewController setPhotoUrl:[FlickrFetcher urlForPhoto:[self.photos objectAtIndex:path.row] format:FlickrPhotoFormatLarge]];
    [segue.destinationViewController setPhotoTitle:[[self.photos objectAtIndex:path.row] objectForKey:FLICKR_PHOTO_TITLE]];

    if([self splitViewPhotoviewcontroller])
    {
        [self splitViewPhotoviewcontroller].photoUrl =  [FlickrFetcher urlForPhoto:[self.photos objectAtIndex:path.row] format:FlickrPhotoFormatLarge];
        [self splitViewPhotoviewcontroller].photoTitle = [[self.photos objectAtIndex:path.row] objectForKey:FLICKR_PHOTO_TITLE];
    }
    
    NSMutableArray *photosIds = [[NSMutableArray array] init];
    
    //Create an user defaults object  
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //Obtain the photo ids array from defaults
    if ([[defaults objectForKey:RECENT_PHOTOS_KEY] mutableCopy]){
        photosIds = [[defaults objectForKey:RECENT_PHOTOS_KEY] mutableCopy];
    }
    
    
    
    NSLog(@"IDS: %@", photosIds);
    
    //Add the photo id
    //id pid = [[self.photos objectAtIndex:path.row] objectForKey:FLICKR_PHOTO_ID];
    
    
    //If not repeated, add the id to the array
    /*if(![photosIds containsObject:pid]) {
        [photosIds addObject:pid];
    }*/
    
    //If not repeated, add the id to the array
    //if(![photosIds containsObject:[self.photos objectAtIndex:path.row]]) {
    [photosIds addObject:[self.photos objectAtIndex:path.row]];
    // }
    
    NSLog(@"photo %@", [self.photos objectAtIndex:path.row]);

    
    NSLog(@"photosids %@", photosIds);
    
    //The array is copied into the defaults
    [defaults setObject:photosIds forKey:RECENT_PHOTOS_KEY];
    [defaults synchronize];  
    
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"ENTRE AL VOID");
    
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    if([self splitViewPhotoviewcontroller])
    {
        NSLog(@"ENTRO AL IF");
        
        [self splitViewPhotoviewcontroller].photoUrl =  [FlickrFetcher urlForPhoto:[self.photos objectAtIndex:path.row] format:FlickrPhotoFormatLarge];
        [self splitViewPhotoviewcontroller].photoTitle = [[self.photos objectAtIndex:path.row] objectForKey:FLICKR_PHOTO_TITLE];
      
        NSLog(@"%@", [self splitViewPhotoviewcontroller].photoUrl);

        
        NSMutableArray *photosIds = [[NSMutableArray array] init];
        
        //Create an user defaults object  
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        //Obtain the photo ids array from defaults
        if ([[defaults objectForKey:RECENT_PHOTOS_KEY] mutableCopy]){
            photosIds = [[defaults objectForKey:RECENT_PHOTOS_KEY] mutableCopy];
        }
        
        
        
        //NSLog(@"IDS: %@", photosIds);
        
        //Add the photo id
        //id pid = [[self.photos objectAtIndex:path.row] objectForKey:FLICKR_PHOTO_ID];
        
        
        //If not repeated, add the id to the array
        /*if(![photosIds containsObject:pid]) {
         [photosIds addObject:pid];
         }*/
        
        //If not repeated, add the id to the array
        //if(![photosIds containsObject:[self.photos objectAtIndex:path.row]]) {
        [photosIds addObject:[self.photos objectAtIndex:path.row]];
        // }
        
        //NSLog(@"photo %@", [self.photos objectAtIndex:path.row]);
        
        
        //NSLog(@"photosids %@", photosIds);
        
        //The array is copied into the defaults
        [defaults setObject:photosIds forKey:RECENT_PHOTOS_KEY];
        [defaults synchronize];  
    }
}

@end
