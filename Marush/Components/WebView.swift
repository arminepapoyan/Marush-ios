//
//  WebView.swift
//  Marush
//
//  Created by S2S Company on 30.01.2025.
//

import Foundation
import WebKit
import SwiftUI

struct WebView: UIViewRepresentable {
    
    var url: String
    
    func makeUIView(context: Context) -> WKWebView {
        // Create a WKWebView configuration
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.preferences.javaScriptEnabled = true
        webConfiguration.allowsInlineMediaPlayback = true
        
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        
        // Load the URL if it's valid
        if let url = URL(string: url) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // If needed, you can update the WKWebView here, but for now, we leave it empty.
    }
}

struct HTMLStringView: UIViewRepresentable {
    let htmlContent: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.backgroundColor = .white // Ensure the background color is set
        webView.isOpaque = false // Ensure the background color is visible
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(htmlContent, baseURL: nil) // Load the HTML string
    }
}
//struct HtmlWebView: UIViewRepresentable {
//    var htmlString: String
//
//    func makeUIView(context: Context) -> WKWebView {
//        let webView = WKWebView()
//        webView.backgroundColor = .white // Set a background color
//        webView.isOpaque = false // Make the background visible
//        return webView
//    }
//
//    func updateUIView(_ uiView: WKWebView, context: Context) {
//        // Load the HTML string into the web view
//        uiView.loadHTMLString(htmlString, baseURL: nil)
//    }
//}

//struct HTMLWebView: UIViewRepresentable {
//    let htmlContent: String
//
//    func makeUIView(context: Context) -> WKWebView {
//        let webView = WKWebView()
//        webView.navigationDelegate = context.coordinator
//        webView.backgroundColor = .clear
//        webView.isOpaque = false
//        webView.scrollView.isScrollEnabled = false
//        return webView
//    }
//
//    func updateUIView(_ uiView: WKWebView, context: Context) {
//        uiView.loadHTMLString(htmlContent, baseURL: nil)
//    }
//
//    func makeCoordinator() -> Coordinator {
//        return Coordinator(self)
//    }
//
//    class Coordinator: NSObject, WKNavigationDelegate {
//        var parent: HTMLWebView
//
//        init(_ parent: HTMLWebView) {
//            self.parent = parent
//        }
//
//        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//            webView.evaluateJavaScript("document.body.scrollHeight") { result, error in
//                if let contentHeight = result as? CGFloat {
//                    DispatchQueue.main.async {
//                        // Adjust the height dynamically based on content
//                        webView.frame.size.height = contentHeight
//                    }
//                }
//            }
//        }
//    }
//}


struct HTMLWebView: UIViewRepresentable {
    let htmlContent: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.backgroundColor = .clear
        webView.isOpaque = false
        webView.scrollView.isScrollEnabled = true
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Load the HTML content into the web view
        uiView.loadHTMLString(htmlContent, baseURL: nil)
        
        // Inject custom CSS for design styling after content is loaded
        let customCSS = """
        <style>
            
        </style>
        """
        
        // Inject the CSS after loading the HTML
        let javascript = "var style = document.createElement('style'); style.innerHTML = '\(customCSS)'; document.head.appendChild(style);"
        uiView.evaluateJavaScript(javascript, completionHandler: nil)
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: HTMLWebView

        init(_ parent: HTMLWebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Additional actions after the content is loaded (if needed)
        }
    }
}
struct WebViewText: UIViewRepresentable {
    @Binding var text: String
    @Binding var height: CGFloat  // Binding for height of the WebView
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        // Enabling JavaScript and other configurations
        webView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        webView.navigationDelegate = context.coordinator
        webView.backgroundColor = .clear
        webView.isOpaque = false
        webView.scrollView.isScrollEnabled = false
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Inject meta tag for responsive design if not already included
        let htmlWithMetaTag = """
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
        </head>
        <body style="text-align: center">
            <style>
                @font-face {
                    font-family: "Montserat";
                    src: url("https://www.gotcha.am/style/fonts/Montserrat/Montserrat-Regular.ttf"); /* Replace with your font file URL or system font */
                } 
                p{
                    padding-bottom: 0;
                    margin-bottom: 0;
                    font-family: "Montserat";
                }
                span {
                    color: #F48484;
                    font-size: 1rem !important;
                    font-family: "Montserat";
                }
            </style>
            \(text)
        </body>
        </html>
        """
        // Load the HTML content
        uiView.loadHTMLString(htmlWithMetaTag, baseURL: nil)

        // Evaluate JavaScript to get the content's height
        let script = "document.body.scrollHeight"
        uiView.evaluateJavaScript(script) { (result, error) in
            if let contentHeight = result as? CGFloat {
                // Update the height binding with the content's height
                DispatchQueue.main.async {
                    self.height = contentHeight
                }
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    // WKWebView's navigation handling
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebViewText

        init(_ parent: WebViewText) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Evaluate JavaScript to get the content's height after the page finishes loading
            let script = "document.body.scrollHeight"
            webView.evaluateJavaScript(script) { (result, error) in
                if let contentHeight = result as? CGFloat {
                    DispatchQueue.main.async {
                        self.parent.height = contentHeight
                    }
                }
            }
        }
    }
}
