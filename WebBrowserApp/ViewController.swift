//
//  ViewController.swift
//  WebBrowserApp
//
//  Created by özge kurnaz on 9.12.2024.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate {
    //webkit kullanarak bir web syfasını göstermek icin
    
    var webView: WKWebView!
    var progressView: UIProgressView!
    var websites = ["apple.com","hackingwithswift.com"]
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Open", style: .plain, target: self, action: #selector(openTapped))
        
        progressView = UIProgressView(progressViewStyle: .default)// creates a new UIProgressView instance, giving it the default style
        progressView.sizeToFit() // set its layout size so that it fits its contents fully.
        let progressButton = UIBarButtonItem(customView: progressView)
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))
        
        // making to new toolbar items Back and Forward
        let goBack = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(goBack))
        
        let goForward = UIBarButtonItem(title: "Forward", style: .plain, target: self, action: #selector(goForward))
        
        
        toolbarItems = [goBack, progressButton, spacer, refresh, goForward]
        navigationController?.isToolbarHidden = false
        
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        
        let url = URL(string: "https://" + websites[0])!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
        
    }

    // sayfa acma secenegi sunumak icin olusturuldu.
    @objc func openTapped(){
        let ac = UIAlertController(title: "Open page...", message: nil, preferredStyle: .actionSheet)
        
        for website in websites{
            ac.addAction(UIAlertAction(title: website, style: .default, handler: openPage))

        }
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        
        present(ac,animated: true)
    }
    
    @objc func goBack(){
        webView.goBack()
    }
    
    @objc func goForward(){
        webView.goForward()
        
    }
    
    func openPage(action: UIAlertAction){
        guard let actionTitle = action.title else{return}
        guard let url = URL(string: "https://" + actionTitle) else {return}
        webView.load(URLRequest(url:url))
        
    }
    
    // sayfa yüklenmesi tamamlandıgında cagrılır.
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
    }
    
    // progressbar: yükleme çubugu
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress"{
            progressView.progress = Float(webView.estimatedProgress)
        }
    }
    
    // tarayıcıyı belli bir siteyi sınırlamak veya belli bir url^yi engellemek durumlarında kullanılır
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) ->Void) {
        let url = navigationAction.request.url
        
        if let host = url?.host{
            for website in websites {
                if host.contains(website){
                    decisionHandler(.allow)
                    return
                }
                else{
                    showAlertBlockedSite()
                }
               
            }
        }
        decisionHandler(.cancel)
    }
    
    func showAlertBlockedSite(){
        let ac = UIAlertController(title: "Blocked", message: "The site is not allowed.", preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}

