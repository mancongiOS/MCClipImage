//
//  MCBaseViewController.swift
//  MCClipImage_Example
//
//  Created by 满聪 on 2019/7/1.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

import MCClipImage


class MCBaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.edit, target: self, action: #selector(editEvent))
        showImageView.frame = view.frame
        view.addSubview(showImageView)
    }
    
    
    @objc func editEvent() {

    }

    
    lazy var showImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = UIColor.green
        iv.contentMode = .scaleAspectFit
        return iv
    }()
}



extension MCBaseViewController: MCClipImageViewControllerDelegate{
    func clipImageViewController(_ viewController: MCClipImageViewController, didFinishClipingImage image: UIImage) {
        showImageView.image = image
    }
}

