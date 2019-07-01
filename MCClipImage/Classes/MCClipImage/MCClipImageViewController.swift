//
//  MCClipImageViewController.swift
//  MCAPI
//
//  Created by MC on 2018/9/14.
//  Copyright © 2018年 MC. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore
import Accelerate

/**
 待拓展的功能
 * 1. （完成）旋转图片。
 * 4. 是否添加水印
 * 5. 开放裁切框的颜色和UI。
 * 6. （完成）圆形裁切框
 * 7. 做弹出框旋转相册，拍照功能的处理。
 * 8. 当前页面，手动改变裁切框的尺寸。让用户选择。开发给开发者一个裁切框的数组。可以设置多个尺寸。
 * 9. (完成)抽离底部功能区域。做成一个模块。做一个半透明的底部。
 * 10. 将填充的尺寸，改为填充尺寸比例。 尺寸数组第一个为默认裁切框比例。
 */


@objc public protocol MCClipImageViewControllerDelegate {
    @objc optional func clipImageViewControllerDidCancel(_ viewController: MCClipImageViewController)
    
    func clipImageViewController(_ viewController: MCClipImageViewController, didFinishClipingImage image:UIImage)
}

public class MCClipImageViewController: UIViewController {
    
    
    weak public var delegate : MCClipImageViewControllerDelegate?
    

    // 是否裁切圆形头像
    private var isRound = false
    // 裁剪的目标图片
    private var targetImage : UIImage = UIImage()
    // 裁剪的区域尺寸
    private var cropSize : CGSize = CGSize.zero
    // 裁切框的frame
    private var cropFrame = CGRect.init()
    // 待裁切的图片和裁切框的宽高关系， 用于做裁切处理。
    private var relationType = 0
    
    
    private var configTemp: MCClipImageConfig!
    
    
    
    public func initClipFunctionWithConfig(_ config: MCClipImageConfig) {
        
        configTemp = config
        
        
        if configTemp.clipImage == nil {
            print("\n\nMCClipImage:\n\n\n image 为nil，请检查！！！")
            return
        }
        
        isRound = configTemp.isClipRound
        targetImage = configTemp.clipImage!
        cropSize = CGSize.init(width: selfWidth, height: selfWidth / configTemp.clipScale)
        
        functionView.isShowResetScaleButton = configTemp.clipScaleType.count == 0 ? false : true
        
        
        //如果是圆形的话，对给的cropSize进行容错处理
        if (self.isRound) {
            if (cropSize.width >= cropSize.height) {
                cropSize = CGSize.init(width: cropSize.height, height: cropSize.height)
            }else{
                cropSize = CGSize.init(width: cropSize.width, height: cropSize.width)
            }
            
            
            if cropSize.width < selfWidth {
                cropSize = CGSize.init(width: selfWidth, height: selfWidth)
            }
        }
        
        // 判断裁切框和图片的关系，用于做
        relationType = targetImage.judgeRelationTypeWithCropSize(cropSize)
        
        // 填充图片数据并设置frame
        setImageViewFrameAndImage()
        
        // 根据图片尺寸和裁切框的尺寸设置scrollView的最小缩放比例
        setMinZoomScale()
        
        if isRound {
            // 设置裁切的圆形区域
            transparentCutCircularArea()
        } else {
            // 矩形裁切框
            transparentCutSquareArea()
        }
        
        // 调整imageView的位置
        scrollViewDidZoom(scrollView)
    }
    
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        baseSetting()
        
        initUI()
    }
    
    // 隐藏状态栏
    override public var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    // MARK: - Setter & Getter
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.delegate = self
        view.scrollsToTop = false
        view.maximumZoomScale = 10
        view.frame = CGRect.init(x: 0, y: 0, width: selfWidth, height: selfHeight)
        view.isUserInteractionEnabled = true
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        return view
    }()
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.isUserInteractionEnabled = true
        view.contentMode = UIView.ContentMode.scaleAspectFill
        return view
    }()
    
    lazy var overlayView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.backgroundColor = configTemp.overlayBackgroundColor
        view.alpha = 0.5
        return view
    }()
    
    lazy var functionView: MCClipImageToolBar = {
        let view = MCClipImageToolBar()
        view.cancelButton.addTarget(self, action: #selector(cancelButtonClicked), for: .touchUpInside)
        view.resetButton.addTarget(self, action: #selector(resetButtonClicked), for: .touchUpInside)
        view.sureButton.addTarget(self, action: #selector(sureButtonClicked), for: .touchUpInside)
        view.rotatingButton.addTarget(self, action: #selector(rotatingButtonClicked), for: .touchUpInside)
        return view
    }()
}

//MARK: 通知回调，闭包回调，点击事件
extension MCClipImageViewController {
    
    // 取消
    @objc func cancelButtonClicked() {
        delegate?.clipImageViewControllerDidCancel?(self)
        self.dismiss(animated: true, completion: nil)
    }
    
    // 重设裁切框
    @objc func resetButtonClicked() {
        
        UIAlertController.showActionSheet(on: self, items: configTemp.clipScaleType, confirm:{ [weak self] (index, value) in
            self?.scrollView.minimumZoomScale = 1.0
            self?.scrollView.setZoomScale(1.0, animated: true)
            
            self?.configTemp.clipScale = value
            self?.initClipFunctionWithConfig(self?.configTemp ?? MCClipImageConfig())
        })
    }
    
    // 确定
    @objc func sureButtonClicked() {
        
        var image = getClippingImage()
        if isRound {
            image = image.clipCircularImage()
        }
        
        delegate?.clipImageViewController(self, didFinishClipingImage: image)
        self.dismiss(animated: true, completion: nil)
    }
    
    // 图片旋转
    @objc func rotatingButtonClicked() {
        
        // 清空之前设置的scale。否则会错乱
        scrollView.minimumZoomScale = 1.0
        scrollView.setZoomScale(1.0, animated: true)
        
        let image = targetImage.rotationImage(orientation: .left)
        imageView.image = image
        
        configTemp.clipImage = image
        self.initClipFunctionWithConfig(configTemp)
    }
}


//MARK: UI的处理,通知的接收
extension MCClipImageViewController {
    
    func baseSetting() {
        view.backgroundColor = UIColor.black
        automaticallyAdjustsScrollViewInsets = false
    }
    
    
    func initUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        view.addSubview(overlayView)
        view.addSubview(functionView)
        
        
        let y = selfHeight - 30 - MCClipVC_SafeAreaBottomHeight - 10
        functionView.frame = CGRect.init(x: 0, y: y, width: selfWidth, height: 30)
        
        
        overlayView.frame = view.frame
        scrollView.frame = CGRect.init(x: 0, y: 0, width: selfWidth, height: selfHeight)
    }
    
    func setImageViewFrameAndImage() {
        
        // 1.添加图片
        imageView.image = targetImage
        
        // 2.设置裁剪区域
        let x = (selfWidth - cropSize.width) / 2
        let y = (selfHeight - cropSize.height) / 2
        cropFrame = CGRect.init(x: x, y: ceil(y), width: cropSize.width, height: cropSize.height)
        
        // 3.计算imgeView的frame
        let imageW = targetImage.size.width
        let imageH = targetImage.size.height
        let cropW = cropSize.width
        let cropH = cropSize.height
        var imageViewW,imageViewH,imageViewX,imageViewY : CGFloat
        switch relationType {
        case 0,1:  // 裁切框宽高比 > 0
            imageViewW = cropW
            imageViewH = imageH * imageViewW / imageW
            imageViewX = (selfWidth - imageViewW) / 2
            imageViewY = (selfHeight - imageViewH)/2
        case 2,3:  // 裁切框宽高比 = 0
            imageViewW = cropW
            imageViewH = imageH * imageViewW / imageW
            imageViewX = (selfWidth - imageViewW) / 2
            imageViewY = (selfHeight - imageViewH)/2
        default:
            imageViewH = cropH
            imageViewW = imageW * imageViewH / imageH
            imageViewX = (selfWidth - imageViewW) / 2
            imageViewY = (selfHeight - imageViewH)/2
        }
        
        imageView.frame = CGRect.init(x: imageViewX, y: ceil(imageViewY), width: imageViewW, height: imageViewH)
        
    }
    
    //设置矩形裁剪区域
    func transparentCutSquareArea() {
        let alphaRect = CGRect.init(x: 0, y: 0, width: selfWidth, height: selfHeight)
        let alphaPath = UIBezierPath.init(rect: alphaRect)
        let squarePath = UIBezierPath.init(rect: cropFrame)
        alphaPath.append(squarePath)
        
        let shapeLayer = CAShapeLayer.init()
        shapeLayer.path = alphaPath.cgPath
        shapeLayer.fillRule = CAShapeLayerFillRule.evenOdd
        overlayView.layer.mask = shapeLayer
        
        //裁剪框
        let cropRect_x = cropFrame.origin.x - 1
        let cropRect_y = cropFrame.origin.y - 1
        let cropRect_w = cropFrame.size.width + 2
        let cropRect_h = cropFrame.size.height + 2
        let cropRect = CGRect.init(x: cropRect_x, y: cropRect_y, width: cropRect_w, height: cropRect_h)
        let cropPath = UIBezierPath.init(rect: cropRect)
        
        for layer in overlayView.layer.sublayers ?? [] {
            layer.removeFromSuperlayer()
        }

        let cropLayer = CAShapeLayer.init()
        cropLayer.path = cropPath.cgPath
        cropLayer.lineWidth = configTemp.clipBoxWidth
        cropLayer.fillColor = configTemp.clipBoxColor.cgColor
        cropLayer.strokeColor = configTemp.clipBoxColor.cgColor
        overlayView.layer.addSublayer(cropLayer)
    }
    
    //设置圆形裁剪区域
    func transparentCutCircularArea() {
        let arcX = cropFrame.origin.x + cropFrame.size.width/2
        let arcY = cropFrame.origin.y + cropFrame.size.height/2
        var arcRadius : CGFloat = 0
        if (cropSize.height > cropSize.width) {
            arcRadius = cropSize.width/2
        }else{
            arcRadius  = cropSize.height/2
        }
        
        //圆形透明区域
        let alphaPath = UIBezierPath.init(rect: CGRect.init(x: 0, y: 0, width: selfWidth, height: selfHeight))
        let arcPath = UIBezierPath.init(arcCenter: CGPoint.init(x: arcX, y: arcY), radius: arcRadius, startAngle: 0, endAngle: CGFloat(2*Double.pi), clockwise: false)
        alphaPath.append(arcPath)
        
        let layer = CAShapeLayer.init()
        layer.path = alphaPath.cgPath
        layer.fillRule = CAShapeLayerFillRule.evenOdd
        overlayView.layer.mask = layer
        
        
        //裁剪框
        let cropPath = UIBezierPath.init(arcCenter: CGPoint.init(x: arcX, y: arcY), radius: arcRadius+1, startAngle: 0, endAngle: CGFloat(2*Double.pi), clockwise: false)
        let cropLayer = CAShapeLayer.init()
        cropLayer.path = cropPath.cgPath
        cropLayer.lineWidth = configTemp.clipBoxWidth

        cropLayer.strokeColor = configTemp.clipBoxColor.cgColor
        cropLayer.fillColor = configTemp.clipBoxColor.cgColor
        overlayView.layer.addSublayer(cropLayer)
    }
    
    // 设置最小缩放比例
    func setMinZoomScale() {
        // 设置最小的缩放比例。 自动填满裁剪区域
        var scale : CGFloat = 0
        
        let imageViewW = imageView.frame.size.width
        let imageViewH = imageView.frame.size.height
        
        let cropW = cropSize.width
        let cropH = cropSize.height
        
        
        switch relationType {
        case 0:  // 裁切框宽高比 > 1,并且裁切框宽高比 >= 图片宽高比
            scale = imageViewW  /  cropW
        case 1:  // 裁切框宽高比 > 1,并且裁切框宽高比 < 图片宽高比
            scale = cropH / imageViewH
        case 2:   // 裁切框宽高比 = 1, 并且裁切框宽高比 >= 图片宽高比
            scale = cropW / imageViewW
        case 3:  // 裁切框宽高比 = 1, 并且裁切框宽高比 < 图片宽高比
            scale = cropH / imageViewH
        case 4:  // 裁切框宽高比 < 1,并且裁切框宽高比 >= 图片宽高比
            scale = cropW / imageViewW
        default: // 裁切框宽高比 < 1,并且裁切框宽高比 < 图片框宽高比
            scale = cropW / imageViewW
        }
        
        //自动缩放填满裁剪区域
        self.scrollView.setZoomScale(scale, animated: false)
        //设置刚好填充满裁剪区域的缩放比例，为最小缩放比例
        self.scrollView.minimumZoomScale = scale
    }
    
    // 获取被裁剪的图片
    func getClippingImage() -> UIImage {
        
        /** 步骤
         * 1. 获取图片和imageView的缩放比例。
         * 2. 获取ImageView的缩放比例，即scrollView.zoomScale
         * 3. 获取ImageView的原始坐标
         * 4. 计算缩放后的坐标
         * 5. 计算裁剪区域在原始图片上的位置
         */
        //图片大小和当前imageView的缩放比例
        
        let scaleRatio = targetImage.size.width / imageView.frame.size.width
        //scrollView的缩放比例，即是ImageView的缩放比例
        let scrollScale = self.scrollView.zoomScale
        
        //裁剪框的 左上、右上和左下三个点在初始ImageView上的坐标位置（注意：转换后的坐标为原始ImageView的坐标计算的，而非缩放后的）
        var leftTopPoint = view.convert(cropFrame.origin, to: imageView)
        var rightTopPoint = view.convert(CGPoint.init(x: cropFrame.origin.x + cropSize.width, y: cropFrame.origin.y), to: imageView)
        var leftBottomPoint = view.convert(CGPoint.init(x: cropFrame.origin.x, y: cropFrame.origin.y + cropSize.height), to: imageView)
        
        //计算三个点在缩放后imageView上的坐标
        leftTopPoint = CGPoint.init(x: leftTopPoint.x * scrollScale, y: leftTopPoint.y*scrollScale)
        rightTopPoint = CGPoint.init(x: rightTopPoint.x * scrollScale, y: rightTopPoint.y*scrollScale)
        leftBottomPoint = CGPoint.init(x: leftBottomPoint.x * scrollScale, y: leftBottomPoint.y*scrollScale)
        
        
        //计算裁剪区域在原始图片上的位置
        let width = (rightTopPoint.x - leftTopPoint.x ) * scaleRatio
        let height = (leftBottomPoint.y - leftTopPoint.y) * scaleRatio
        let myImageRect = CGRect.init(x: leftTopPoint.x * scaleRatio, y: leftTopPoint.y*scaleRatio, width: width, height: height)
        return targetImage.crop(rect: myImageRect)
    }
}






extension MCClipImageViewController: UIScrollViewDelegate {
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
        //图片比例改变以后，让改变后的ImageView保持在ScrollView的中央
        let size_W = scrollView.bounds.size.width
        let size_H = scrollView.bounds.size.height
        
        let contentSize_W = scrollView.contentSize.width
        let contentSize_H = scrollView.contentSize.height
        
        
        let offsetX = (size_W > contentSize_W) ? (size_W - contentSize_W) * 0.5 : 0.0
        let offsetY = (size_H > contentSize_H) ? (size_H - contentSize_H) * 0.5 : 0.0
        imageView.center = CGPoint.init(x: contentSize_W * 0.5 + offsetX, y: contentSize_H * 0.5 + offsetY)
        
        
        //设置scrollView的contentSize，最小为self.view.frame.size
        let scrollW = contentSize_W >= selfWidth ? contentSize_W : selfWidth
        let scrollH = contentSize_H >= selfHeight ? contentSize_H : selfHeight
        scrollView.contentSize = CGSize.init(width: scrollW, height: scrollH)
        
        
        //设置scrollView的contentInset
        let imageWidth = imageView.frame.size.width
        let imageHeight = imageView.frame.size.height
        let cropWidth = cropSize.width
        let cropHeight = cropSize.height
        
        var leftRightInset: CGFloat = 0
        var topBottomInset: CGFloat = 0
        
        //imageview的大小和裁剪框大小的三种情况，保证imageview最多能滑动到裁剪框的边缘
        if (imageWidth <= cropWidth) {
            leftRightInset = 0
        } else if (imageWidth >= cropWidth && imageWidth <= selfWidth) {
            leftRightInset = (imageWidth - cropWidth) * 0.5
        }else{
            leftRightInset = (selfWidth - cropSize.width) * 0.5
        }
        
        if (imageHeight <= cropHeight) {
            topBottomInset = 0
        } else if (imageHeight >= cropHeight && imageHeight <= selfHeight) {
            topBottomInset = (imageHeight - cropHeight) * 0.5
        } else {
            topBottomInset = (selfHeight - cropSize.height) * 0.5
        }
        
        scrollView.contentInset = UIEdgeInsets(top: topBottomInset, left: leftRightInset, bottom: topBottomInset, right: leftRightInset)
    }
}





//-底部安全区域
fileprivate let MCClipVC_SafeAreaBottomHeight : CGFloat  = (UIScreen.main.bounds.size.height  >= 812 ? 34 : 0)

// 屏幕的宽高
fileprivate var selfWidth = UIScreen.main.bounds.size.width
fileprivate var selfHeight = UIScreen.main.bounds.size.height



// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToCAShapeLayerFillRule(_ input: String) -> CAShapeLayerFillRule {
	return CAShapeLayerFillRule(rawValue: input)
}


extension UIImage {
    // 截取部分图片
    fileprivate func crop(rect: CGRect) -> UIImage{
        var rect = rect
        rect.origin.x *= self.scale
        rect.origin.y *= self.scale
        rect.size.width *= self.scale
        rect.size.height *= self.scale
        let imageRef = self.cgImage!.cropping(to: rect)
        let image = UIImage(cgImage: imageRef!, scale: self.scale, orientation: self.imageOrientation)
        return image
    }
}
