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
        
        return true
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        
    }
}
