//
//  AppDelegate.swift
//  Ocarina Example
//
//  Created by Rens Verhoeven on 14/02/2017.
//  Copyright © 2017 awkward. All rights reserved.
//

import UIKit
import Ocarina

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Override point for customization after application launch.
        
        let urls: [URL] = [URL(string: "http://renssies.nl")!,
                           URL(string: "http://nytimes.com")!,
                           URL(string: "http://bbc.com")!,
                           URL(string: "http://apple.com")!,
                           URL(string: "http://awkward.co")!,
                           URL(string: "http://spotify.com")!
        ]
        _ = OcarinaPrefetcher(urls: urls, manager: OcarinaManager.shared) { (errors) in
            print("Prefetched all urls with errors \(errors)")
        }
        
        _ = URL(string: "https://www.youtube.com/watch?v=Jfg6RfClZJg")?.oca.fetchInformation { (information, error) in
            if let information = information {
                print("Information received \(information) for url \(information.originalURL) type \(information.type.rawValue)")
            } else if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }

        _ = URL(string: "http://simlicious.nl/2017/01/24/de-sims-4-vampieren-nu-verkrijgbaar/")?.oca.fetchInformation { (information, error) in
            if let information = information {
                print("Information received \(information) for url \(information.originalURL) type \(information.type.rawValue)")
            } else if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
        
        _ = URL(string: "http://www.deezer.com/playlist/68020160")?.oca.fetchInformation { (information, error) in
            if let information = information {
                print("Information received \(information) for url \(information.originalURL) type \(information.type.rawValue)")
            } else if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
        
        _ = URL(string: "http://www.deezer.com/playlist/68020160")?.oca.fetchInformation { (information, error) in
            if let information = information {
                print("Information received \(information) for url \(information.originalURL) type \(information.type.rawValue)")
            } else if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
        
        _ = URL(string: "http://reddit.com/r/zelda")?.oca.fetchInformation { (information, error) in
            if let information = information {
                print("Information received \(information) for url \(information.originalURL) type \(information.type.rawValue)")
            } else if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
        
        _ = URL(string: "https://www.nytimes.com/2017/02/16/sports/bighorn-sheep-hunting.html?hp&action=click&pgtype=Homepage&clickSource=story-heading&module=photo-spot-region&region=top-news&WT.nav=top-news&_r=0")?.oca.fetchInformation { (information, error) in
            if let information = information {
                print("Information received \(information) for url \(information.originalURL) type \(information.type.rawValue)")
            } else if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
        
        _ = URL(string: "http://renssies.nl")?.oca.fetchInformation { (information, error) in
            if let information = information {
                print("Information received \(information) for url \(information.originalURL) type \(information.type.rawValue)")
            } else if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
        
        _ = URL(string: "http://awkward.co")?.oca.fetchInformation { (information, error) in
            if let information = information {
                print("Information received \(information) for url \(information.originalURL) type \(information.type.rawValue)")
            } else if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
        
        _ = URL(string: "http://i.imgur.com/XJHt6Wk.jpg")?.oca.fetchInformation { (information, error) in
            if let information = information {
                print("Information received \(information) for url \(information.originalURL) type \(information.type.rawValue)")
            } else if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
        
        _ = URL(string: "https://www.nintendo.com/consumer/downloads/WiiOpMn_setup.pdf")?.oca.fetchInformation { (information, error) in
            if let information = information {
                print("Information received \(information) for url \(information.originalURL) type \(information.type.rawValue)")
            } else if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

