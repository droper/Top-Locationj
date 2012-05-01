//
//  PhotoViewController.m
//  TopPlaces
//
//  Created by Marco Morales on 4/3/12.
//  Copyright (c) 2012 Casa. All rights reserved.
//

#import "PhotoViewController.h"

@interface PhotoViewController() <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) UIImage *photoImage;


@end

@implementation PhotoViewController

@synthesize scrollView;
@synthesize imageView;
@synthesize photoUrl = _photoUrl;
@synthesize photoImage;
@synthesize photoTitle = _photoTitle;


- (void)setPhotoUrl:(NSURL *)photoUrl
{
    if (_photoUrl != photoUrl) {
        _photoUrl = photoUrl;
    }
    [self viewDidLoad];

}


- (void)setPhotoTitle:(NSString *)photoTitle
{
    if (_photoTitle != photoTitle) {
        _photoTitle = photoTitle;
    }

}


- (UIImage *)createPhoto:(NSURL *)photoUrl
{
    //Create an NSData with the photo url and then a image
    //with that data
    NSData *imageData = [NSData dataWithContentsOfURL:photoUrl];
    UIImage *photo = [UIImage imageWithData:imageData];
    
    return photo;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imageView.image = [self createPhoto:self.photoUrl];
    self.title = self.photoTitle;
    self.scrollView.delegate = self;
    self.scrollView.contentSize = self.imageView.image.size;
    self.imageView.frame = CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height);

    
    if (UIUserInterfaceIdiomPad)
    {
        CGRect zoomRect;

        if (self.interfaceOrientation == UIInterfaceOrientationPortrait)
        {
            if (self.imageView.image.size.width >= self.imageView.image.size.height)
            {
                zoomRect.size.height = self.imageView.image.size.height;
            } else {
                zoomRect.size.width = self.imageView.image.size.width;
            }
        } else {
            if (self.imageView.image.size.width >= self.imageView.image.size.height)
            {
                zoomRect.size.width = self.imageView.image.size.width;
            } else {
            zoomRect.size.height = self.imageView.image.size.height;
            }
        }
    

        [self.scrollView zoomToRect:zoomRect animated:YES];
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    CGRect zoomRect;
    //zoomRect.size.height = self.imageView.image.size.height;
    
    NSLog(@"entra a viewWillAppear");
    
    if (self.interfaceOrientation == UIInterfaceOrientationPortrait)
    {
        if (self.imageView.image.size.width >= self.imageView.image.size.height)
        {
            zoomRect.size.height = self.imageView.image.size.height;
        } else {
            zoomRect.size.width = self.imageView.image.size.width;
        }
    } else {
        if (self.imageView.image.size.width >= self.imageView.image.size.height)
        {
            zoomRect.size.width = self.imageView.image.size.width;
        } else {
            zoomRect.size.height = self.imageView.image.size.height;
        }
    }
    
    //zoomRect.origin.x = 0;
    //zoomRect.origin.y = 0; 

    
    [self.scrollView zoomToRect:zoomRect animated:YES];
    
}


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    NSLog(@"SIZE HEIGHT: %f",self.imageView.frame.size.height);
    return self.imageView;

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
   // if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    //    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
   // } else {
        return YES;
    //}
}

- (void)viewDidUnload
{
    [self setImageView:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
}

@end
