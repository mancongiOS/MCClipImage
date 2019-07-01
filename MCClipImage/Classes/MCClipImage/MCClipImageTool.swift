//
//  MCClipImageTool.swift
//  MCAPI
//
//  Created by MC on 2018/9/18.
//  Copyright © 2018年 MC. All rights reserved.
//

import UIKit
import Foundation
import UIKit











extension UIAlertController {
    
    public static func showActionSheet(on vc : UIViewController, items:[MCClipImageScaleType],confirm : ((Int,CGFloat) -> Void)?, cancel: ((UIAlertAction)->Void)? = nil) {
        
        let alter = UIAlertController.init(title: "重设裁切框的比例", message: nil, preferredStyle: .actionSheet)
        
        let cancle = UIAlertAction.init(title: "取消", style: .cancel, handler: cancel)
        
        var index = 0
        for item in items {
            let i = index
            let confirm = UIAlertAction.init(title: item.describe(), style: UIAlertAction.Style.default) { (b) in
                confirm?(i,item.rawValue)
            }
            alter.addAction(confirm)
            index += 1
        }
        alter.addAction(cancle)
        vc.present(alter, animated: true, completion: nil)
    }
}




extension UIImage {
    
    /**
     * 翻转图片
     */
    func rotationImage(orientation:UIImage.Orientation) -> UIImage {
        
        var rotate : Double = 0.0;
        var rect = CGRect.init()
        var translateX : CGFloat = 0.0;
        var translateY : CGFloat = 0.0;
        var scaleX : CGFloat = 1.0;
        var scaleY : CGFloat = 1.0;
        
        let imageWidth = self.size.width
        let imageHeight = self.size.height

        
        // 根据方向旋转
        switch (orientation) {
        case .left:
            rotate = Double.pi / 2;
            rect = CGRect.init(x: 0, y: 0, width: imageHeight, height: imageWidth)
            translateX = 0
            translateY = -rect.size.width;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case .right:
            rotate = 33 * Double.pi / 2;
            rect = CGRect.init(x: 0, y: 0, width: imageHeight, height: imageWidth)
            translateX = -rect.size.height;
            translateY = 0;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case .down:
            rotate = Double.pi
            rect = CGRect.init(x: 0, y: 0, width: imageWidth, height: imageHeight)
            translateX = -rect.size.width;
            translateY = -rect.size.height;
            break;
        default:
            rotate = 0.0;
            rect = CGRect.init(x: 0, y: 0, width: imageWidth, height: imageHeight)
            translateX = 0;
            translateY = 0;
            break;
        }
        
        
        //做CTM变换,并绘制图片
        UIGraphicsBeginImageContext(rect.size);
        let context = UIGraphicsGetCurrentContext();
        context?.translateBy(x: 0, y: rect.size.height)
        context?.scaleBy(x: 1, y: -1)
        context?.rotate(by: CGFloat(rotate))
        context?.translateBy(x: translateX, y: translateY)
        context?.scaleBy(x: scaleX, y: scaleY)
        context?.draw(self.cgImage!, in: CGRect.init(x: 0, y: 0, width: rect.size.width, height: rect.size.height))
        let newPic = UIGraphicsGetImageFromCurrentImageContext();
        return newPic ?? UIImage.init()
    }
    
    
    /**
     * 判断图片和裁剪框的关系类型
     */
    func judgeRelationTypeWithCropSize(_ cropSize: CGSize) -> Int {
        
        var relationType = 0
        
        
        let crop_W = cropSize.width
        let crop_H = cropSize.height
        
        let image_W = self.size.width
        let image_H = self.size.height
        
        let imageRadio = image_W / image_H
        let cropRadio = crop_W / crop_H
        
        
        /** 裁切框宽高比 > 1
         0. 裁切框宽高比 >= 图片宽高比    imageView宽固定，高适配
         1. 裁切框宽高比 <  图片宽高比    imageView高固定，宽适配
         */
        
        /** 裁切框宽高比 = 1
         2. 裁切框宽高比 >= 图片宽高比    imageView宽固定，高适配
         3. 裁切框宽高比 <  图片宽高比    imageView高固定，宽适配
         */
        
        
        /** 裁切框宽高比 < 1
         4. 裁切框宽高比 >= 图片宽高比    imageView宽固定，高适配
         5. 裁切框宽高比 <  图片宽高比    imageView高固定，宽适配
         */
        
        if cropRadio > 1 {
            if cropRadio >= imageRadio {
                relationType = 0
            } else {
                relationType = 1
            }
        } else if cropRadio == 1 {
            if cropRadio >= imageRadio {
                relationType = 2
            } else {
                relationType = 3
            }
        } else {
            if cropRadio >= imageRadio {
                relationType = 4
            } else {
                relationType = 5
            }
        }
        
        return relationType
    }

    // 将图片裁剪为圆形
    public func clipCircularImage() -> UIImage {
        
        let imageWidth = self.size.width
        let imageHeight = self.size.height

        
        let arcCenterX = imageWidth / 2
        let arcCenterY = imageHeight / 2
        
        let radius = arcCenterX > arcCenterY ? arcCenterY : arcCenterX

        
        UIGraphicsBeginImageContext(self.size)
        let context = UIGraphicsGetCurrentContext()
        context!.beginPath()
        context?.addArc(center: CGPoint.init(x: arcCenterX, y: arcCenterY), radius: radius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: false)
        context?.clip()
        self.draw(in: CGRect.init(x: 0, y: 0, width: imageWidth, height: imageHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        
        
        return  newImage!
    }
}


@objc extension Bundle {
    
    /**
     * 加载指定bundle下的图片资源
     * bundleName bundle的名字
     * podName    pod的名字
     * imageName  图片的名字
     
     * @return UIImage
     */
    public static func MCLoadImageFromBundleName(_ bundleName:String, podName:String, imageName: String) -> UIImage? {
        
        
        var associateBundleURL = Bundle.main.url(forResource: "Frameworks", withExtension: nil)
        associateBundleURL = associateBundleURL?.appendingPathComponent(podName)
        associateBundleURL = associateBundleURL?.appendingPathExtension("framework")
        
        
        if associateBundleURL == nil {
            print("获取bundle失败")
            return nil
        }
        
        
        let associateBunle = Bundle.init(url: associateBundleURL!)
        associateBundleURL = associateBunle?.url(forResource: bundleName, withExtension: "bundle")
        
        if let bundleURL = associateBundleURL {
            let bundle = Bundle.init(url: bundleURL)
            let scale = Int(UIScreen.main.scale)
            
            // 适配2x还是3x图片
            let name = imageName + "@" + String(scale) + "x"
            let path = bundle?.path(forResource: name, ofType: "png")
            
            if path == nil {
                print("获取bundle失败")
                return nil
            }
            
            let image1 = UIImage.init(contentsOfFile: path!)
            return image1
        }
        
        return nil

    }
}

