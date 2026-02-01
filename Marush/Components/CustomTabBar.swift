//
//  CustomTabBar.swift
//  Marush
//
//  Created by S2S Company on 30.01.2025.
//
import UIKit
import SwiftUI
import UIKit
import Combine


struct CustomTabBarWrapper: UIViewControllerRepresentable {
    @EnvironmentObject var settings: UserSettings
    @EnvironmentObject var userData: UserViewModel
    @EnvironmentObject var appData: AppDataViewModel

    func makeUIViewController(context: Context) -> CustomTabBarController {
        let tabBarController = CustomTabBarController(settings: settings, userData: userData, appData: appData)
        return tabBarController
    }

    func updateUIViewController(_ uiViewController: CustomTabBarController, context: Context) {
        // Respond to changes if needed
    }
}


class CustomTabBarController: UITabBarController, UITabBarControllerDelegate {
    var settings: UserSettings!
    var userData: UserViewModel!
    var appData: AppDataViewModel!
    
    private var middleButtonHostingView: UIView?

    init(settings: UserSettings, userData: UserViewModel, appData: AppDataViewModel) {
        self.settings = settings
        self.userData = userData
        self.appData = appData
        super.init(nibName: nil, bundle: nil)
    }
    

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setupTabBarAppearance()
        
        if let middleView = middleButtonHostingView {
            view.bringSubviewToFront(middleView)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        setupTabBar()
       
        observeTabSelection()
        
        updateCartShadow()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateCartShadow),
            name: .cartCountChange,
            object: nil
        )
//        setupMiddleButton()
    }

    private func setupTabBar() {
        let homeVC = UIHostingController(
            rootView: HomeView()
                .environmentObject(settings)
                .environmentObject(userData)
                .environmentObject(appData)
//                .id(settings.resetNavigationID) // Bind the id to settings.resetNavigationID
//                .onChange(of: settings.resetNavigationID) { newID in
//                    // The view will re-render automatically when resetNavigationID changes
//                    print("HomeView re-render triggered by resetNavigationID change: \(newID)")
//                }
        )
        homeVC.tabBarItem = UITabBarItem(
            title: getLocalString(string: "home"),
            image: UIImage(named: "ic-home")?.withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named: "ic-home-fill")?.withRenderingMode(.alwaysOriginal)
        )
        homeVC.tabBarItem.tag = 0

        let locationVC = UIHostingController(
            rootView: HomeView()
                .environmentObject(settings)
        )
        locationVC.tabBarItem = UITabBarItem(
            title: getLocalString(string: "location"),
            image: UIImage(named: "ic-orders")?.withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named: "ic-orders-fill")?.withRenderingMode(.alwaysOriginal)
        )
        locationVC.tabBarItem.tag = 1

        let shopVC = UIHostingController(
            rootView: HomeView()
                .environmentObject(settings)
                .environmentObject(userData)
                .environmentObject(appData)
        )
        shopVC.tabBarItem.tag = 2
        

        let reorderVC = UIHostingController(
            rootView: HomeView()
                .environmentObject(settings)
        )
        reorderVC.tabBarItem = UITabBarItem(
            title: getLocalString(string: "reorder"),
            image: UIImage(named: "ic-cart")?.withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named: "ic-cart-fill")?.withRenderingMode(.alwaysOriginal)
        )
        reorderVC.tabBarItem.tag = 3

        let rewardsVC = UIHostingController(
            rootView: HomeView()
                .environmentObject(settings)
        )
        rewardsVC.tabBarItem = UITabBarItem(
            title:getLocalString(string: "pay"),
            image: UIImage(named: "ic-profile")?.withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named: "ic-profile")?.withRenderingMode(.alwaysOriginal)
        )
        rewardsVC.tabBarItem.tag = 4

        viewControllers = [homeVC, locationVC, shopVC, reorderVC, rewardsVC]
    }
    
//    private func setupTabBar() {
//        let homeVC = UIHostingController(
//            rootView: HomeView()
//                .environmentObject(settings)
//                .environmentObject(userData)
//                .environmentObject(appData)
////                .id(settings.resetNavigationID) // Bind the id to settings.resetNavigationID
////                .onChange(of: settings.resetNavigationID) { newID in
////                    // The view will re-render automatically when resetNavigationID changes
////                    print("HomeView re-render triggered by resetNavigationID change: \(newID)")
////                }
//        )
//        homeVC.tabBarItem = UITabBarItem(
//            title: getLocalString(string: "home"),
//            image: UIImage(named: "ic-home-gray")?.withRenderingMode(.alwaysOriginal),
//            selectedImage: UIImage(named: "ic-home-fill")?.withRenderingMode(.alwaysOriginal)
//        )
//        homeVC.tabBarItem.tag = 0
//
//        let locationVC = UIHostingController(
//            rootView: LocationsView()
//                .environmentObject(settings)
//        )
//        locationVC.tabBarItem = UITabBarItem(
//            title: getLocalString(string: "location"),
//            image: UIImage(named: "ic-location")?.withRenderingMode(.alwaysOriginal),
//            selectedImage: UIImage(named: "ic-location-fill")?.withRenderingMode(.alwaysOriginal)
//        )
//        locationVC.tabBarItem.tag = 1
//
//        let shopVC = UIHostingController(
//            rootView: ShopView()
//                .environmentObject(settings)
//                .environmentObject(userData)
//                .environmentObject(appData)
//        )
//        shopVC.tabBarItem.tag = 2
//        
//
//        let reorderVC = UIHostingController(
//            rootView: OrdersHistoryView()
//                .environmentObject(settings)
//        )
//        reorderVC.tabBarItem = UITabBarItem(
//            title: getLocalString(string: "reorder"),
//            image: UIImage(named: "ic-reorder-gray")?.withRenderingMode(.alwaysOriginal),
//            selectedImage: UIImage(named: "ic-reorder-fill")?.withRenderingMode(.alwaysOriginal)
//        )
//        reorderVC.tabBarItem.tag = 3
//
//        let rewardsVC = UIHostingController(
//            rootView: RewardsView()
//                .environmentObject(settings)
//        )
//        rewardsVC.tabBarItem = UITabBarItem(
//            title:getLocalString(string: "pay"),
//            image: UIImage(named: "ic-pay")?.withRenderingMode(.alwaysOriginal),
//            selectedImage: UIImage(named: "ic-pay")?.withRenderingMode(.alwaysOriginal)
//        )
//        rewardsVC.tabBarItem.tag = 4
//
//        viewControllers = [homeVC, locationVC, shopVC, reorderVC, rewardsVC]
//    }


//    private func setupMiddleButton() {
//        let middleSwiftUIView = MiddleButtonView()
//        .environmentObject(settings)
//
//        let hostingController = UIHostingController(rootView: middleSwiftUIView)
//        hostingController.view.backgroundColor = .clear
//        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
//
//        middleButtonHostingView = hostingController.view // Store reference
//
//        addChild(hostingController)
//        view.addSubview(hostingController.view)
//        hostingController.didMove(toParent: self)
//
//        NSLayoutConstraint.activate([
//            hostingController.view.centerXAnchor.constraint(equalTo: tabBar.centerXAnchor),
//            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        ])
//    }
    
    private func setupMiddleButton() {
//        let middleSwiftUIView = MiddleButtonView()
//            .environmentObject(settings)
//
//        let hostingController = UIHostingController(rootView: middleSwiftUIView)
//        hostingController.view.backgroundColor = .clear
//        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
//
//        middleButtonHostingView = hostingController.view // Store reference
//
//        addChild(hostingController)
//        view.addSubview(hostingController.view)
//        hostingController.didMove(toParent: self)
//
//        NSLayoutConstraint.activate([
//            hostingController.view.centerXAnchor.constraint(equalTo: tabBar.centerXAnchor),
//            hostingController.view.bottomAnchor.constraint(equalTo: tabBar.bottomAnchor)
//        ])
//
////        // Add observers for keyboard notifications
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(keyboardWillShow(_:)),
//                                               name: UIResponder.keyboardWillShowNotification,
//                                               object: nil)
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(keyboardWillHide(_:)),
//                                               name: UIResponder.keyboardWillHideNotification,
//                                               object: nil)
    }

    
    @objc private func keyboardWillShow(_ notification: Notification) {
        // Hide the middle button when the keyboard appears
        middleButtonHostingView?.isHidden = true
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        // Show the middle button when the keyboard disappears
        middleButtonHostingView?.isHidden = false
    }


    private func observeTabSelection() {
        settings.$selection
            .sink { [weak self] newIndex in
                if self?.selectedIndex != newIndex {
                    self?.selectedIndex = newIndex
                }
            }
            .store(in: &cancellables)
    }

    private var cancellables = Set<AnyCancellable>()
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarItemAppearance()
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Poppins-Medium", size: 10)!,
            .foregroundColor: UIColor.lightGray
        ]
        let attributesBold: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Poppins-Bold", size: 10)!,
            .foregroundColor: UIColor.black
        ]
        appearance.normal.titleTextAttributes = attributes
        appearance.selected.titleTextAttributes = attributesBold
      
        
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.backgroundColor = UIColor.white
        tabBarAppearance.stackedLayoutAppearance = appearance
        tabBarAppearance.inlineLayoutAppearance = appearance
        tabBarAppearance.compactInlineLayoutAppearance = appearance
        
        
        
        tabBar.standardAppearance = tabBarAppearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = tabBarAppearance
        }
//        tabBar.tintColor = .clear
        tabBar.layer.masksToBounds = true
        tabBar.layer.cornerRadius = 15
        tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        updateCartShadow()
    }
    

    @objc private func updateCartShadow() {
        let cartCount = settings.cart_count
        
        if cartCount > 0 {
            if let shadowView2 = view.subviews.first(where: { $0.accessibilityIdentifier == "TabBarShadow2" }) {
                shadowView2.frame = tabBar.frame
            } else {
                let shadowView2 = UIView(frame: .zero)
                shadowView2.frame = tabBar.frame
                shadowView2.accessibilityIdentifier = "TabBarShadow2"
                shadowView2.backgroundColor = UIColor.white
                shadowView2.layer.cornerRadius = 15
                shadowView2.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                shadowView2.layer.masksToBounds = false
                // Use the custom color "ColorPrimary" for shadowColor
                if let colorPrimary = UIColor(named: "ColorPrimary") {
                    shadowView2.layer.shadowColor = colorPrimary.cgColor // Custom shadow color
                } else {
                    // Fallback if the color is not found
                    shadowView2.layer.shadowColor = UIColor.black.cgColor // Default shadow color
                }
                
                shadowView2.layer.shadowOffset = CGSize(width: 0.0, height: UIDevice.current.localizedModel == "iPad" ? -40 : -45)
                shadowView2.layer.shadowOpacity = 1
                shadowView2.layer.shadowRadius = 0
                view.addSubview(shadowView2)
                view.bringSubviewToFront(tabBar)
            }
        } else {
            // Remove shadow if cart_count is 0
            if let shadowView2 = view.subviews.first(where: { $0.accessibilityIdentifier == "TabBarShadow2" }) {
                shadowView2.removeFromSuperview()
            }
        }
        
        if let shadowView = view.subviews.first(where: { $0.accessibilityIdentifier == "TabBarShadow1" }) {
            shadowView.frame = tabBar.frame
        } else {
            let shadowView = UIView(frame: .zero)
            shadowView.frame = tabBar.frame
            shadowView.accessibilityIdentifier = "TabBarShadow1"
            shadowView.backgroundColor = UIColor.white
            shadowView.layer.cornerRadius = 15
            shadowView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            shadowView.layer.masksToBounds = false
            shadowView.layer.shadowColor = Color.gray.cgColor
            shadowView.layer.shadowOffset = CGSize(width: 0.0, height: -1)
            shadowView.layer.shadowOpacity = 0.2
            shadowView.layer.shadowRadius = 0
//            shadowView.layer.zPosition = tabBar.layer.zPosition - 1
           view.insertSubview(shadowView, belowSubview: tabBar)
           self.view.insertSubview(self.tabBar, aboveSubview: shadowView)
        }
        
        if let middleView = middleButtonHostingView {
            view.bringSubviewToFront(middleView)
        }
    }
    
//    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
//        // Update the selection state
//        settings.selection = viewController.tabBarItem.tag
//
//        // Check if the home tab is selected (tag == 0)
//        print("viewController.tabBarItem.tag \(viewController.tabBarItem.tag)")
//        if viewController.tabBarItem.tag == 0 {
//            // Reset the navigation ID
//            settings.resetNavigationID = UUID()
//        }
//    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        // Detect re-selection of the Home tab
        settings.selection = viewController.tabBarItem.tag
        
        if tabBarController.selectedIndex == 0 {

            // Force HomeView to re-render with a new ID
            settings.resetNavigationID = UUID()
            print("tabBarController.selectedIndex is \(settings.resetNavigationID)")
        }

        print("tabBarController.selectedIndex is \(tabBarController.selectedIndex)")
        settings.selection = tabBarController.selectedIndex
    }
}
