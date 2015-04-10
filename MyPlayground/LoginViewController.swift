//
//  LoginViewController.swift
//  MyPlayground
//
//  Created by Takayoshi Koshida on 2015/04/09.
//  Copyright (c) 2015年 tkoshida. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        openLogin()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func openLogin() {
        let loginUrlString: String = "https://crowdworks.jp/login"
        let url: NSURL = NSURL(string: loginUrlString)!
        let request: NSURLRequest = NSURLRequest(URL: url)
        self.webView.loadRequest(request)
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        if let urlString: String = request.URL?.absoluteString {
            
            let regexOptions:NSRegularExpressionOptions? = NSRegularExpressionOptions.CaseInsensitive
            
            var matchingError : NSError?
            let regex = NSRegularExpression(pattern: "https://crowdworks.jp/auth/.*?/callback", options: regexOptions!, error: &matchingError)
            
            let results = regex!.matchesInString(urlString, options: nil, range: NSMakeRange(0, count(urlString))) as! Array<NSTextCheckingResult>

            if results.count > 0 {
                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                    
                })
                return false
            }
        }
        
        return true
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        
    }
}
