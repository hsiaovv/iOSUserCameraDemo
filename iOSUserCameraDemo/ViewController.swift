//
//  ViewController.swift
//  iOSUserCameraDemo
//
//  Created by xiaovv on 2017/9/19.
//  Copyright © 2017年 xiaovv. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // UIImagePickerController
    @IBAction func usePickerController(_ sender: UIButton) {
        
        let controller = UseUIImagePickerController()
        self.navigationController?.pushViewController(controller, animated: true)
    }

    // AVFoundation-拍照
    @IBAction func useAVFoundationPhoto(_ sender: UIButton) {
        
        let controller = UseAVFoundationPhotoController()
        self.present(controller, animated: true, completion: nil)
    }
    
    // AVFoundation-录制视频
    @IBAction func useAVFoundationVideo(_ sender: UIButton) {
        
        let controller = UseAVFoundationVideoController()
        self.present(controller, animated: true, completion: nil)
    }
    
}

