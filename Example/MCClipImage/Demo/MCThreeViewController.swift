//
//  MCThreeViewController.swift
//  MCClipImage_Example
//
//  Created by 满聪 on 2019/7/1.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import MCClipImage

class MCThreeViewController: MCBaseViewController {

    
    
    override func editEvent() {
        helper.openCamera(self)
    }

    
    // 一定要让控制器持久化持有
    lazy var helper: MCPickerImageHelper = {
        let helper = MCPickerImageHelper()
        return helper
    }()
}
