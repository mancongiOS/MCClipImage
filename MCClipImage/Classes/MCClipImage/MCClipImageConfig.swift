//
//  MCClipImageHelper.swift
//  MCClipImage_Example
//
//  Created by 满聪 on 2019/7/1.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import UIKit



public class MCClipImageConfig: NSObject {
    
    /// 待裁切的图片
    public var clipImage: UIImage?
    /// 想要的裁切比例
    public var clipScale: CGFloat = 2
    /// 是否裁切圆形
    public var isClipRound: Bool = false
    /// 覆盖层的背景颜色
    public var overlayBackgroundColor =  UIColor.black
    /// 裁切框的颜色
    public var clipBoxColor =  UIColor.green
    /// 裁切框的宽度
    public var clipBoxWidth: CGFloat =  1

    /// 重设裁切比例的数组 （数组为空，隐私该按钮）
    public var clipScaleType: [MCClipImageScaleType] = []
}


public enum MCClipImageScaleType: CGFloat {
    case scale1x1 = 1
    
    case scale2x1 = 2
    case scale2x3 = 0.666666
    case scale2x5 = 0.4
    
    case scale3x1 = 3
    case scale3x2 = 1.5
    case scale3x4 = 0.75
    case scale3x5 = 0.6
    
    case scale4x1 = 4
    case scale4x3 = 1.333333
    case scale4x5 = 0.8
    
    case scale5x1 = 5
    case scale5x2 = 2.5
    case scale5x3 = 1.666666
    case scale5x4 = 1.25
    
    
    
    public func describe() -> String {
        
        switch self {
        case .scale1x1:
            return "1:1"
            
        case .scale2x1:
            return "2:1"
        case .scale2x3:
            return "2:3"
        case .scale2x5:
            return "2:5"
            
        case .scale3x1:
            return "3:1"
        case .scale3x2:
            return "3:2"
        case .scale3x4:
            return "3:4"
        case .scale3x5:
            return "3:5"
            
        case .scale4x1:
            return "4:1"
        case .scale4x3:
            return "4:3"
        case .scale4x5:
            return "4:5"
            
        case .scale5x1:
            return "5:1"
        case .scale5x2:
            return "5:2"
        case .scale5x3:
            return "5:3"
        case .scale5x4:
            return "5:4"
        }
    }
}
