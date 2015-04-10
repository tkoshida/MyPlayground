//
//  Utils.swift
//  MyPlayground
//
//  Created by Takayoshi Koshida on 2015/04/10.
//  Copyright (c) 2015年 tkoshida. All rights reserved.
//

import Foundation

class Utils: NSObject {
    
    func saveCookie() {
        let cookieJar: NSHTTPCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        let data: NSData = NSKeyedArchiver.archivedDataWithRootObject(cookieJar)
        let ud: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        ud.setObject(data, forKey: "cookie")
    }
    
    func loadCookie() {
        let ud: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let data: NSData? = ud.objectForKey("cookie") as? NSData
        if let cookie = data {
            let datas: NSArray? = NSKeyedUnarchiver.unarchiveObjectWithData(cookie) as? NSArray
            if let cookies = datas {
                for c in cookies as! [NSHTTPCookie] {
                    NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookie(c)
                }
            }
        }
    }
    
    func wipeCookies() {
        let ud: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let cookieStorage: NSHTTPCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        let cookies: [NSHTTPCookie] = cookieStorage.cookies as! [NSHTTPCookie]
        for cookie in cookies {
            cookieStorage.deleteCookie(cookie)
        }
    }
    
    func cwSessionIdInCookie() -> String? {
        var cookie: NSHTTPCookie
        var cookieJar: NSHTTPCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in cookieJar.cookies as! [NSHTTPCookie] {
            NSLog("%@", cookie)
            
            if let value: String = cookie.value {
                if count(value) > 0 &&
                    cookie.domain == ".crowdworks.jp" &&
                    cookie.name == "_cw_session_id" {
                    return value
                }
            }
        }
        return nil
    }
}