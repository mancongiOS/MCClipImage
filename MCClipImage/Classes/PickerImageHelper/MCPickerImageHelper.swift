//
//  MCPickerImageHelper.swift
//  Alamofire
//
//  Created by MC on 2018/12/10.
//

import Foundation
import UIKit
import MobileCoreServices



@objc public protocol MCPickerImageHelperDelegate {
    @objc optional func pickerImageHelperDidCancel(_ picker: MCPickerImageHelper)
    
    func pickerImageHelper(_ picker: MCPickerImageHelper, didFinishPickImage image:UIImage)
}


public class MCPickerImageHelper: NSObject {
    
    weak private var delegate : MCPickerImageHelperDelegate?

    private var allowsEditing : Bool = false
    
    /**
     * 打开相机拍照
     * allowsEditing 是否允许编辑
     */
    public func openCamera(_ target: UIViewController ,allowsEditing : Bool = false) {
        
        delegate = target as? MCPickerImageHelperDelegate
        self.allowsEditing = allowsEditing
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.allowsEditing = allowsEditing
            target.present(picker, animated: true, completion: nil)
        } else {
            print("模拟其中无法打开照相机,请在真机中使用");
        }
    }
    
    /**
     * 打开相册，选照片
     * allowsEditing 是否允许编辑
     */
    public func openPhotoLibrary(_ target:UIViewController, allowsEditing : Bool = false) {
        
        delegate = target as? MCPickerImageHelperDelegate

        self.allowsEditing = allowsEditing
        
        // 是否支持相册
        if UIImagePickerController.isValidImagePickerType(type: UIImagePickerType.UIImagePickerTypePhotoLibrary){
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = allowsEditing
//            picker.setImagePickerStyle(bgroundColor: UIColor.white, titleColor: UIColor.black, buttonTitleColor: UIColor.black) // 修改导航栏
            target.present(picker, animated: true, completion: nil)
        } else {
            print("读取相册失败")
        }
    }
    
}


extension MCPickerImageHelper: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
 
    /*
     指定用户选择的媒体类型 UIImagePickerControllerMediaType
     原始图片 UIImagePickerControllerOriginalImage
     修改后的图片 UIImagePickerControllerEditedImage
     裁剪尺寸 UIImagePickerControllerCropRect
     媒体的URL UIImagePickerControllerMediaURL
     原件的URL UIImagePickerControllerReferenceURL
     当来数据来源是照相机的时候这个值才有效 UIImagePickerControllerMediaMetadata
     */
    
    
    
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        let mediaType = info[UIImagePickerController.InfoKey.mediaType] as! String
        
        if mediaType == String(kUTTypeImage) {
            
            let originalImage : UIImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            
            let rect = info[UIImagePickerController.InfoKey.cropRect] as? CGRect ?? CGRect.init()
            
            let pickedImage = self.allowsEditing ? originalImage.crop(toRect: rect) : originalImage
            
            
            // 保存
            if picker.sourceType == .camera {
                UIImageWriteToSavedPhotosAlbum(pickedImage, self, #selector(saveImage(image:didFinishSavingWithError:contextInfo:)), nil)
            }
                        
            
            delegate?.pickerImageHelper(self, didFinishPickImage: pickedImage)
            
            picker.dismiss(animated: true) { }
            
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        delegate?.pickerImageHelperDidCancel?(self)
        picker.dismiss(animated: true, completion: nil)
    }
    
    @objc private func saveImage(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
      
        
        if error != nil {
            print("保存图片失败")
        }
    }
    
}

