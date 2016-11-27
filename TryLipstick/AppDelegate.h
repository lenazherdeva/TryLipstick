//
//  AppDelegate.h
//  TryLipstick
//
//  Created by Евгения Тверитинова on 27.11.16.
//  Copyright © 2016 Евгения Тверитинова. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

