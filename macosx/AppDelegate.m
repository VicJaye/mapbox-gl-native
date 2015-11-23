//
//  AppDelegate.m
//  osxapp
//
//  Created by Minh Nguyen on 2015-11-21.
//  Copyright © 2015 Mapbox. All rights reserved.
//

#import "AppDelegate.h"

#import <mbgl/osx/MGLAccountManager.h>
#import <mbgl/osx/MGLMapView.h>
#import <mbgl/osx/MGLStyle.h>

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (strong) IBOutlet MGLMapView *mapView;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Set access token, unless MGLAccountManager already read it in from Info.plist.
    if (![MGLAccountManager accessToken]) {
        NSString *accessToken = [[NSProcessInfo processInfo] environment][@"MAPBOX_ACCESS_TOKEN"];
        if (accessToken) {
            // Store to preferences so that we can launch the app later on without having to specify
            // token.
            [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:@"access_token"];
        } else {
            // Try to retrieve from preferences, maybe we've stored them there previously and can reuse
            // the token.
            accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"];
        }
        if (!accessToken) {
            NSAlert *alert = [[NSAlert alloc] init];
            alert.messageText = @"Access token required";
            alert.informativeText = @"To load Mapbox-hosted tiles and styles, set the MAPBOX_ACCESS_TOKEN environment variable.";
            [alert addButtonWithTitle:@"OK"];
            [alert addButtonWithTitle:@"Open Studio"];
            if ([alert runModal] == NSAlertSecondButtonReturn) {
                [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://www.mapbox.com/studio/account/tokens/"]];
            }
        }
        
        [MGLAccountManager setAccessToken:accessToken];
    }
    
    self.mapView = [[MGLMapView alloc] initWithFrame:self.window.contentView.bounds];
    self.mapView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [self.window.contentView addSubview:self.mapView];
    [self.window makeFirstResponder:self.mapView];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
}

- (IBAction)setStyle:(id)sender {
    NSMenuItem *menuItem = sender;
    NSURL *styleURL;
    switch (menuItem.tag) {
        case 1:
            styleURL = [MGLStyle streetsStyleURL];
            break;
        case 2:
            styleURL = [MGLStyle emeraldStyleURL];
            break;
        case 3:
            styleURL = [MGLStyle lightStyleURL];
            break;
        case 4:
            styleURL = [MGLStyle darkStyleURL];
            break;
        case 5:
            styleURL = [MGLStyle satelliteStyleURL];
            break;
        case 6:
            styleURL = [MGLStyle hybridStyleURL];
            break;
        default:
            NSAssert(NO, @"Cannot set style from control with tag %li", (long)menuItem.tag);
            break;
    }
    self.mapView.styleURL = styleURL;
}

- (IBAction)zoomIn:(id)sender {
    [self.mapView setZoomLevel:self.mapView.zoomLevel + 1 animated:YES];
}

- (IBAction)zoomOut:(id)sender {
    [self.mapView setZoomLevel:self.mapView.zoomLevel - 1 animated:YES];
}

- (IBAction)snapToNorth:(id)sender {
    [self.mapView setDirection:0 animated:YES];
}

- (IBAction)toggleTileEdges:(id)sender {
    self.mapView.showsTileEdges = !self.mapView.showsTileEdges;
}

- (IBAction)toggleCollisionBoxes:(id)sender {
    self.mapView.showsCollisionBoxes = !self.mapView.showsCollisionBoxes;
}

- (IBAction)showShortcuts:(id)sender {
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = @"Mapbox GL Help";
    alert.informativeText = @"\
• To scroll, swipe with two fingers, drag the cursor, or press the arrow keys.\n\
• To zoom, pinch with two fingers, or hold down Shift while dragging the cursor up and down.\n\
• To rotate, move two fingers opposite each other in a circle, or hold down Option while dragging the cursor left and right.\n\
• To tilt, hold down Option while dragging the cursor up and down.\
";
    [alert runModal];
}

- (IBAction)giveFeedback:(id)sender {
    CLLocationCoordinate2D centerCoordinate = self.mapView.centerCoordinate;
    NSURL *feedbackURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.mapbox.com/map-feedback/#/%.5f/%.5f/%.0f",
                                               centerCoordinate.longitude, centerCoordinate.latitude, round(self.mapView.zoomLevel)]];
    [[NSWorkspace sharedWorkspace] openURL:feedbackURL];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    if (menuItem.action == @selector(setStyle:)) {
        NSURL *styleURL = self.mapView.styleURL;
        NSCellStateValue state;
        switch (menuItem.tag) {
            case 1:
                state = [styleURL isEqual:[MGLStyle streetsStyleURL]];
                break;
            case 2:
                state = [styleURL isEqual:[MGLStyle emeraldStyleURL]];
                break;
            case 3:
                state = [styleURL isEqual:[MGLStyle lightStyleURL]];
                break;
            case 4:
                state = [styleURL isEqual:[MGLStyle darkStyleURL]];
                break;
            case 5:
                state = [styleURL isEqual:[MGLStyle satelliteStyleURL]];
                break;
            case 6:
                state = [styleURL isEqual:[MGLStyle hybridStyleURL]];
                break;
            default:
                return NO;
        }
        menuItem.state = state;
        return YES;
    }
    if (menuItem.action == @selector(zoomIn:)) {
        return self.mapView.zoomLevel < self.mapView.maximumZoomLevel;
    }
    if (menuItem.action == @selector(zoomOut:)) {
        return self.mapView.zoomLevel > self.mapView.minimumZoomLevel;
    }
    if (menuItem.action == @selector(snapToNorth:)) {
        return self.mapView.direction != 0;
    }
    if (menuItem.action == @selector(toggleTileEdges:)) {
        menuItem.title = self.mapView.showsTileEdges ? @"Hide Tile Edges" : @"Show Tile Edges";
        return YES;
    }
    if (menuItem.action == @selector(toggleCollisionBoxes:)) {
        menuItem.title = self.mapView.showsCollisionBoxes ? @"Hide Collision Boxes" : @"Show Collision Boxes";
        return YES;
    }
    if (menuItem.action == @selector(showShortcuts:)) {
        return YES;
    }
    if (menuItem.action == @selector(giveFeedback:)) {
        return YES;
    }
    return NO;
}

@end
