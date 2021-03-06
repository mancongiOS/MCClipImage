//
//  MCOneViewController.swift
//  MCClipImage_Example
//
//  Created by 满聪 on 2019/7/1.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import MCClipImage


class MCOneViewController: MCBaseViewController {
    

    
    override func editEvent() {

        let image = UIImage.init(named: "keyboard")
        
        
        let config = MCClipImageConfig()
        config.clipImage = image
        config.clipScaleType = [.scale1x1,.scale2x1]
        //        config.clipBoxColor = UIColor.purple
        //        config.overlayBackgroundColor = UIColor.yellow
        
        config.clipBoxWidth = 1
        config.isClipRound = false
        config.clipBoxColor = UIColor.red
        
        
        let vc = MCClipImageViewController()
        vc.delegate = self
        vc.initClipFunctionWithConfig(config)
        self.present(vc, animated: true, completion: nil)
    }
    
}
