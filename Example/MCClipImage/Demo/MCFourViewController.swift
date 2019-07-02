//
//  MCFourViewController.swift
//  MCClipImage_Example
//
//  Created by 满聪 on 2019/7/1.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

import MCClipImage

class MCFourViewController: MCBaseViewController {
    
    
    
    
    override func editEvent() {
        
        // MCPickerImageHelper，如果声明为局部对象的话，走完就被销毁了。但是MCPickerImageHelper对象又作为n内部pickerViewController的代理执行者，执行者没了，所以就不响应pickerViewController的代理方法。 所以一定不能让MCPickerImageHelper对象被销毁，要么懒加载该对象要么成为全局的。
        helper.openPhotoLibrary(self)
    }
    
    
    func cropImage(_ image: UIImage) {
        
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
        self.present(vc, animated: false, completion: nil)
    }
    

    lazy var helper: MCPickerImageHelper = {
        let helper = MCPickerImageHelper()
        return helper
    }()
}

extension MCFourViewController: MCPickerImageHelperDelegate {
    func pickerImageHelper(_ picker: MCPickerImageHelper, didFinishPickImage image: UIImage) {

        /// 一定要确保在主线程中执行
        DispatchQueue.main.async {
            self.cropImage(image)
        }
    }
    
    func pickerImageHelperDidCancel(_ picker: MCPickerImageHelper) {
        print("点击了取消")
    }
}
