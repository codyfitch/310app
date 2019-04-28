//
//  ContainerViewController.swift
//  VoiceBox
//
//  Created by Aminda Pereira on 4/18/19.
//  Copyright © 2019 Aminda Pereira. All rights reserved.
//

import UIKit
import QuartzCore
//This is for the slide menu animation


class ContainerViewController: UIViewController {
    
    enum SlideOutState {
    case bothCollapsed
    case leftPanelExpanded
    case rightPanelExpanded
    }
    
    var centerNavigationController: UINavigationController!
    var viewController: ViewController!
    
    var currentState: SlideOutState = .bothCollapsed
    var leftViewController: SidePanelViewController?
    var rightViewController: SidePanelViewController?
    
    //adjusting this will change how much space the menu takes on the main screen? i think so at least
    let centerPanelExpandedOffset: CGFloat = 60
    override func viewDidLoad() {
        super.viewDidLoad()
        viewController = UIStoryboard.viewController()
        viewController.delegate = self
        
        //wrap the centerViewController in a navigation controller so we can push views to it
        //and display bar button item in the navigation bar
        
        centerNavigationController = UINavigationController(rootViewController: viewController)
        view.addSubview(centerNavigationController.view)
        addChild(centerNavigationController)
        
        centerNavigationController.didMove(toParent: self)
        
    }
}
extension ContainerViewController: CenterViewControllerDelegate {
    func toggleLeftPanel() {
        let notAlreadyExpanded = (currentState != .leftPanelExpanded)
        if notAlreadyExpanded {
            addLeftPanelViewController()
        }
        animateLeftPanel(shouldExpand: notAlreadyExpanded)
    }
    func toggleRightPanel() {
        let notAlreadyExpanded = (currentState != .rightPanelExpanded)
        if notAlreadyExpanded {
            addRightPanelViewController()
        }
        animateRightPanel(shouldExpand: notAlreadyExpanded)
    }
    func addLeftPanelViewController() {
        guard leftViewController == nil else {return}
        if let vc = UIStoryboard.leftViewController() {
            vc.menus = Menu.hamMenu()
            addChildSidePanelController(vc)
            leftViewController = vc
            
        }
        
    }
    func addChildSidePanelController(_ sidePanelController: SidePanelViewController) {
        view.insertSubview(sidePanelController.view, at: 0)
        
        addChild(sidePanelController)
        sidePanelController.didMove(toParent: self)
    }
    
    func addRightPanelViewController() {
        guard rightViewController == nil else {return}
        if let vc = UIStoryboard.rightViewController() {
            vc.menus = Menu.faveMenu()
            addChildSidePanelController(vc)
            rightViewController = vc
        }
    }
    func animateRightPanel(shouldExpand: Bool) {
        if shouldExpand {
            currentState = .rightPanelExpanded
            animateCenterPanelXposition(targetPosition: -centerNavigationController.view.frame.width +
            centerPanelExpandedOffset)
        }else {
            animateCenterPanelXposition(targetPosition: 0){ _ in
                self.currentState = .bothCollapsed
                
                self.rightViewController?.view.removeFromSuperview()
                self.rightViewController = nil
            }
        }
    }
    

    func animateLeftPanel(shouldExpand: Bool) {
        if shouldExpand {
            currentState = .leftPanelExpanded
            animateCenterPanelXposition(
                targetPosition: centerNavigationController.view.frame.width - centerPanelExpandedOffset)
        }else{
            animateCenterPanelXposition(targetPosition: 0) {finished in
                self.currentState = .bothCollapsed
                self.leftViewController?.view.removeFromSuperview()
                self.leftViewController = nil
            }
        }
        }
func animateCenterPanelXposition(targetPosition: CGFloat, completion: ((Bool) -> Void)? = nil){
    UIView.animate(withDuration: 0.5,
                   delay: 0,
                   usingSpringWithDamping: 0.8,
                   initialSpringVelocity: 0,
                   options: .curveEaseInOut, animations: {
                    self.centerNavigationController.view.frame.origin.x = targetPosition
    
    }, completion: completion)
}
}
    private extension UIStoryboard {
        static func mainStoryboard() -> UIStoryboard { return UIStoryboard(name:"Main", bundle: Bundle.main) }
        static func leftViewController() -> SidePanelViewController? {
            return mainStoryboard().instantiateViewController(withIdentifier: "LeftViewController") as?
            SidePanelViewController
        }
        static func rightViewController() -> SidePanelViewController? {
            return mainStoryboard().instantiateViewController(withIdentifier: "RightViewController") as? SidePanelViewController
          }
        static func viewController() -> ViewController? {
            return mainStoryboard().instantiateViewController(withIdentifier: "ViewController") as? ViewController
}

}
