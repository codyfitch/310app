//
//  ViewControllerDelegate.swift
//  VoiceBox
//
//  Created by Aminda Pereira on 4/18/19.
//  Copyright © 2019 Aminda Pereira. All rights reserved.
//

import UIKit

@objc
protocol CenterViewControllerDelegate {
    @objc optional func toggleLeftPanel()
    @objc optional func toggleRightPanel()
    @objc optional func collapseSidePanels()
    
}
