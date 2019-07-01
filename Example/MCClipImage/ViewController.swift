//
//  ViewController.swift
//  MCClipImage
//
//  Created by 562863544@qq.com on 02/25/2019.
//  Copyright (c) 2019 562863544@qq.com. All rights reserved.
//

import UIKit

import MCClipImage


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "示例"
        view.addSubview(talbeView)
    }

    
    
    lazy var talbeView: UITableView = {
        let tableView = UITableView.init(frame: view.frame, style: UITableView.Style.plain)
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    lazy var dataArray = ["裁切图片","裁切圆形图片","裁切拍照图片","裁切相册图片"]
}



extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "cell")
        }
        
        cell?.textLabel?.text = dataArray[indexPath.row]
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var vc: UIViewController!
        switch dataArray[indexPath.row] {
        case "裁切图片":
            vc = MCOneViewController()
        case "裁切圆形图片":
            vc = MCTwoViewController()
        case "裁切拍照图片":
            vc = MCThreeViewController()
        case "裁切相册图片":
            vc = MCFourViewController()
        default:
            break
        }
        vc?.title = dataArray[indexPath.row]

        navigationController?.pushViewController(vc, animated: true)

    }
}


