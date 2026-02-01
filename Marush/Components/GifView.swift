//
//  GifView.swift
//  Marush
//
//  Created by S2S Company on 30.01.2025.
//


import SwiftUI
import WebKit


struct GifImage: UIViewRepresentable {
    private let name: String

    init(_ name: String) {
        self.name = name
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        let url = Bundle.main.url(forResource: name, withExtension: "gif")!
        let data = try! Data(contentsOf: url)
        webView.load(
            data,
            mimeType: "image/gif",
            characterEncodingName: "UTF-8",
            baseURL: url.deletingLastPathComponent()
        )
        webView.scrollView.isScrollEnabled = false
        webView.isOpaque = false
        webView.backgroundColor = .clear
        let cssString = """
               body { background-color: transparent; margin: 0; display: flex; justify-content: center; align-items: center; width: max-content; }
               """
               let jsString = """
               var style = document.createElement('style');
               style.innerHTML = '\(cssString)';
               document.head.appendChild(style);
               """
               webView.evaluateJavaScript(jsString, completionHandler: nil)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.reload()
    }

}

struct GifUrlImage: UIViewRepresentable {
    private let url: String

    init(_ url: String) {
        self.url = url
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        let gifURL = URL(string: url)!
        let request = URLRequest(url: gifURL)
        webView.load(request)
        
        // Optional: Configure webview appearance
        webView.scrollView.isScrollEnabled = false
        webView.isOpaque = false
        webView.backgroundColor = .clear

        // Optional: CSS styling to ensure the GIF fits properly
        let cssString = """
            body { background-color: transparent; margin: 0; display: flex; justify-content: center; align-items: center; }
            """
        let jsString = """
        var style = document.createElement('style');
        style.innerHTML = '\(cssString)';
        document.head.appendChild(style);
        """
        webView.evaluateJavaScript(jsString, completionHandler: nil)
        
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // No update is needed here, as the GIF will load automatically
    }
}


struct GifUrlImage2: UIViewRepresentable {
    let url: String
    let width: CGFloat
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = false
        webView.isOpaque = false
        webView.backgroundColor = .clear
        
        guard let gifURL = URL(string: url) else {
            print("Invalid GIF URL: \(url)")
            return webView
        }
        
        let htmlString = """
            <html>
                <head>
                    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
                </head>
                <body>
                    <style>
                        body { background-color: transparent; margin: 0; display: flex; justify-content: center; align-items: center; }
                        img {
                            width: \(width)px;
                            height: auto;
                            object-fit: contain;
                        }
                    </style>
                    <img src="\(gifURL)" />
                </body>
            </html>
            """
        webView.loadHTMLString(htmlString, baseURL: nil)
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // No need to update the UI view
    }
}

//
//struct GifUrlImageFit: UIViewRepresentable {
//    private let url: String
//    let height: CGFloat
//    
//    init(_ url: String, _ height: CGFloat) {
//        self.url = url
//        self.height = height
//    }
//
//    func makeUIView(context: Context) -> WKWebView {
//        let webView = WKWebView()
//        webView.scrollView.isScrollEnabled = false
//        webView.isOpaque = false
//        webView.backgroundColor = .clear
//
//        let html = """
//        <html>
//          <head>
//            <meta name="viewport" content="width=device-width, initial-scale=1.0">
//            <style>
//              body {
//                margin: 0;
//                background-color: transparent;
//                display: flex;
//                justify-content: center;
//                align-items: center;
//              }
//              img {
//                max-height: \(height)px;
//                width: auto;
//                object-fit: contain;
//              }
//            </style>
//          </head>
//          <body>
//            <img src="\(url)" />
//          </body>
//        </html>
//        """
//
//        webView.loadHTMLString(html, baseURL: nil)
//        return webView
//    }
//
//    func updateUIView(_ uiView: WKWebView, context: Context) {
//        // No need to update — WKWebView handles rendering the same content
//    }
//}

struct GifUrlImageFit: UIViewRepresentable {
    private let url: String
    let height: CGFloat

    init(_ url: String, _ height: CGFloat) {
        self.url = url
        self.height = height
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = false
        webView.isOpaque = false
        webView.backgroundColor = .clear
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let html = """
        <html>
          <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
              body {
                margin: 0;
                background-color: transparent;
                display: flex;
                justify-content: center;
                align-items: center;
              }
              img {
                max-height: \(height)px;
                width: auto;
                object-fit: contain;
              }
            </style>
          </head>
          <body>
            <img src="\(url)" />
          </body>
        </html>
        """

        webView.loadHTMLString(html, baseURL: nil)
    }
}

struct GifImage_Previews: PreviewProvider {
    static var previews: some View {
//        GifImage("AnimationHomePage")
//            .frame(width: 34, height: 60)
//            .padding(.trailing,40)
//        GifUrlImage("https://www.gotcha.am/images_list/uploaded/image_rWTbVW55Tk_order_process.gif")
//            .frame(maxWidth: .infinity, maxHeight: 190) // Adjust width and height
//            .clipped() // Clip any excess
//            .cornerRadius(8)
//            .padding(.horizontal)
//            .padding(.bottom
        GifUrlImage2(url: "https://www.gotcha.am/images_list/uploaded/image_L51gtYDlH8_animationhomepage_360.gif", width: 100)

    }
}
