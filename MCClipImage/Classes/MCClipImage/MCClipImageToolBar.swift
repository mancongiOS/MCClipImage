//
//  MCClipImageFunctionView.swift
//  MCAPI
//
//  Created by MC on 2018/9/27.
//  Copyright © 2018年 MC. All rights reserved.
//

import UIKit

/**
 * 底部功能区域，包括:
 * 1. 取消按钮
 * 2. 旋转图片按钮
 * 3. 重新选择尺寸比例按钮
 * 4. 确定选择按钮
 */


public class MCClipImageToolBar: UIView {

    /// 是否显示重设选择尺寸按钮
    public var isShowResetScaleButton: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(cancelButton)
        self.addSubview(resetButton)
        self.addSubview(sureButton)
        self.addSubview(rotatingButton)
    }
    
    
    public override func layoutSubviews() {
        super.layoutSubviews()

        let selfWidth = self.frame.size.width
        let selfHeight = self.frame.size.height
        
        let iconWH : CGFloat = 25
        
        
        let buttonCount: CGFloat = isShowResetScaleButton ? 4 : 3
        
        
        let leftMargin : CGFloat = 30

        let margin = (selfWidth - leftMargin*2 - iconWH * buttonCount) / (buttonCount - 1)
        
        
        let rotatingButton_X = leftMargin + (iconWH + margin) * 1
        let sureButton_X = selfWidth - leftMargin - iconWH
        
        
        let y = (selfHeight - iconWH) / 2
        cancelButton.frame = CGRect.init(x: leftMargin, y: y, width: iconWH, height: iconWH)
        
        sureButton.frame = CGRect.init(x: sureButton_X, y: y, width: iconWH, height: iconWH)
        
        
        rotatingButton.frame = CGRect.init(x: rotatingButton_X, y: y, width: iconWH, height: iconWH)

        if isShowResetScaleButton {
            let resetButton_X = leftMargin + (iconWH + margin) * 2
            resetButton.frame = CGRect.init(x: resetButton_X, y: y, width: iconWH, height: iconWH)
        }
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    lazy var cancelButton: UIButton = {
        let button = UIButton.init(type: .custom)
        let image = Bundle.MCLoadImageFromBundleName("MCClipImageBundle", podName: "MCClipImage", imageName: "ClipImage_cancel")
        button.setImage(image, for: .normal)
        return button
    }()
    
    lazy var resetButton: UIButton = {
        let button = UIButton.init(type: .custom)
        let image = Bundle.MCLoadImageFromBundleName("MCClipImageBundle", podName: "MCClipImage", imageName: "ClipImage_setting")
        button.setImage(image, for: .normal)
        return button
    }()

    
    lazy var rotatingButton: UIButton = {
        let button = UIButton.init(type: .custom)
        let image = Bundle.MCLoadImageFromBundleName("MCClipImageBundle", podName: "MCClipImage", imageName: "ClipImage_rotating")
        button.setImage(image, for: .normal)
        return button
    }()
    
    
    lazy var sureButton: UIButton = {
        let button = UIButton.init(type: .custom)
        let image = Bundle.MCLoadImageFromBundleName("MCClipImageBundle", podName: "MCClipImage", imageName: "ClipImage_sure")
        button.setImage(image, for: .normal)
        return button
    }()
    
}
