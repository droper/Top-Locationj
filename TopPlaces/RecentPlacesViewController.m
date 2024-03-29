//
//  RecentPlacesViewController.m
//  TopPlaces
//
//  Created by Marco Morales on 3/26/12.
//  Copyright (c) 2012 Casa. All rights reserved.
//

#import "RecentPlacesViewController.h"
#import "FlickrFetcher.h"
#import "PhotoViewController.h"

#define RECENT_PHOTOS_KEY @"photosId"


@interface RecentPlacesViewController()
// keys: photographer NSString, values: NSArray of photo NSDictionary
@property (nonatomic, strong) NSDictionary *photosByPhotographer;
@property (nonatomic, strong) NSMutableArray *photosIds;

@end


@implementation RecentPlacesViewController

@synthesize photos = _photos;
@synthesize photosByPhotographer = _photosByPhotographer;
@synthesize photosIds;

//cambio para probar el commit

- (void)updatePhotosByPhotographer
{
    //NSLog(@"%@", self.photos);
    NSMutableDictionary *photosByPhotographer = [NSMutableDictionary dictionary];
    for (NSDictionary *photo in self.photos) {
        NSLog(@"FOTOOOOOOOOOOOOO  %@", photo);
        NSString *photographer = [photo objectForKey:FLICKR_PHOTO_OWNER];
        NSMutableArray *photos = [photosByPhotographer objectForKey:photographer];
        if (!photos) {
            photos = [NSMutableArray array];
            [photosByPhotographer setObject:photos forKey:photographer];
        }
        [photos addObject:photo];
    }
    self.photosByPhotographer = photosByPhotographer;
}

- (void)setPhotos:(NSArray *)photos
{
    if (_photos != photos) {
        _photos = photos;
        // Model changed, so update our View (the table)
        [self updatePhotosByPhotographer];
        [self.tableView reloadData];
    }
}


//Order photos by Id
- (NSArray *)orderPhotosById
{
    
    //Create an user defaults object  
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //Obtain the photo ids array from defaults
    //self.photosIds = [[defaults objectForKey:RECENT_PHOTOS_KEY] mutableCopy];
        
    // If there is any photo id, initialize the array
    //if (!self.photosIds) self.photosIds = [NSMutableArray array];
    
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    
    photos = [[defaults objectForKey:RECENT_PHOTOS_KEY] mutableCopy];
    
    /*for (int i = 0; i < [self.photos count]; i++){
        
        for (int j = 0; j < [self.photosIds count]; j++){

            if ([[[self.photos objectAtIndex:i] objectForKey:FLICKR_PHOTO_ID] isEqual:[self.photosIds objectAtIndex:j]])
            {
                [photos addObject:[self.photos objectAtIndex:i]];
            }
        }
    }*/
    
    //NSLog(@"%@", self.photos);

    //NSLog(@"%@", photos);
    //NSLog(@"%@", self.photosIds);

    //NSLog(@"%@", photos);
    
    return photos;
}


- (IBAction)refresh:(id)sender
{
    // might want to use introspection to be sure sender is UIBarButtonItem
    // (if not, it can skip the spinner)
    // that way this method can be a little more generic
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
    dispatch_async(downloadQueue, ^{
        NSArray *photos = [FlickrFetcher recentGeoreferencedPhotos];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationItem.leftBarButtonItem = sender;
            self.photos = photos;
            //self.photos = [self orderPhotosById];
        });
    });
    dispatch_release(downloadQueue);
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
    return YES;
}


#pragma mark - UITableViewDataSource


- (NSString *)photographerForSection:(NSInteger)section
{
    return [[self.photosByPhotographer allKeys] objectAtIndex:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self photographerForSection:section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.photosByPhotographer count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // return [self.photos count];
    NSString *photographer = [self photographerForSection:section];
    NSArray *photosByPhotographer = [self.photosByPhotographer objectForKey:photographer];
    return [photosByPhotographer count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Flickr Photo";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    // NSDictionary *photo = [self.photos objectAtIndex:indexPath.row];
    NSString *photographer = [self photographerForSection:indexPath.section];
    NSArray *photosByPhotographer = [self.photosByPhotographer objectForKey:photographer];
    NSDictionary *photo = [photosByPhotographer objectAtIndex:indexPath.row];
    cell.textLabel.text = [photo objectForKey:FLICKR_PHOTO_TITLE];
    cell.detailTextLabel.text = [photo objectForKey:FLICKR_PHOTO_OWNER];
    
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

    //Create an user defaults object  
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //Obtain the photo ids array from defaults
   self.photosIds = [[defaults objectForKey:RECENT_PHOTOS_KEY] mutableCopy];
    
    // If there is any photo id, initialize the array
    if (!self.photosIds) self.photosIds = [NSMutableArray array];
    
    //Add the photo id
    id pid = [[self.photos objectAtIndex:path.row] objectForKey:FLICKR_PHOTO_ID];
    
    
    //If not repeated, add the id to the array
    if(![self.photosIds containsObject:pid]) {
        [self.photosIds addObject:pid];
    }
    
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    
    //Move the items of the array to 49 from 50
    if ([self.photos count] >= 50)
    {
        for (int i = 1; i < 49; i++){
            [temp addObject:[self.photos objectAtIndex:i]];
        }
        self.photos = temp;
    }
    
    //The array is copied into the defaults
    [defaults setObject:self.photosIds forKey:RECENT_PHOTOS_KEY];
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
        
        
        NSMutableArray *photos_Ids = [[NSMutableArray array] init];
        
        //Create an user defaults object  
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        //Obtain the photo ids array from defaults
        if ([[defaults objectForKey:RECENT_PHOTOS_KEY] mutableCopy]){
            photos_Ids = [[defaults objectForKey:RECENT_PHOTOS_KEY] mutableCopy];
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
        [defaults setObject:photos_Ids forKey:RECENT_PHOTOS_KEY];
        [defaults synchronize];  
    }
}

@end
