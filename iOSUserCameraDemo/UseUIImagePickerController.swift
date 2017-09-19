//
//  UseUIImagePickerController.swift
//  iOSUserCameraDemo
//
//  Created by xiaovv on 2017/9/19.
//  Copyright © 2017年 xiaovv. All rights reserved.
//

import UIKit
import MobileCoreServices
import Photos
import PhotosUI

class UseUIImagePickerController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    
    var pickerController: UIImagePickerController?
    var livePhotoView:PHLivePhotoView?
    
    var takePicButton: UIButton?
    var startButton: UIButton?
    var stopButton: UIButton?
    var switchButton: UIButton?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        self.title = "UseUIImagePickerController"
        
        self.setupButtons()
    }
    
    func setupButtons() {
        
        let photoLibButton = UIButton(type: .system)
        photoLibButton.frame = CGRect(x: 0, y: 130, width: UIScreen.main.bounds.width, height: 44)
        photoLibButton.setTitle("打开照片图库", for: .normal)
        photoLibButton.addTarget(self, action: #selector(showPhotoLibPickerController), for: .touchUpInside)
        
        self.view.addSubview(photoLibButton)
        
        let commonButton = UIButton(type: .system)
        commonButton.frame = CGRect(x: 0, y: photoLibButton.frame.maxY + 20, width: UIScreen.main.bounds.width, height: 44)
        commonButton.setTitle("标准相机", for: .normal)
        commonButton.addTarget(self, action: #selector(showCommonPickerController), for: .touchUpInside)
        
        self.view.addSubview(commonButton)
        
        let customButton = UIButton(type: .system)
        customButton.frame = CGRect(x: 0, y: commonButton.frame.maxY + 20, width: UIScreen.main.bounds.width, height: 44)
        customButton.setTitle("自定义相机", for: .normal)
        customButton.addTarget(self, action: #selector(showCustomPickerController), for: .touchUpInside)
        
        self.view.addSubview(customButton)
        
        let livePhoto = PHLivePhotoView()
        livePhoto.bounds = CGRect(x: 0, y: 0, width: 200, height: 200)
        livePhoto.center = CGPoint(x: UIScreen.main.bounds.size.width * 0.5, y: customButton.frame.maxY + 120)
        
        self.livePhotoView = livePhoto
        
        self.view.addSubview(livePhoto)
        
    }
    
    func pickerSourceTypeAvailable(_ sourceType: UIImagePickerControllerSourceType) -> Bool {
        
        return UIImagePickerController.isSourceTypeAvailable(sourceType)
    }
    
    func showPhotoLibPickerController() {
        
        //判断设备是否支持数据来源
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            
            // 实例化 UIImagePickerController 对象
            let picker = UIImagePickerController()
            
            // 设置数据来源类型
            picker.sourceType = .photoLibrary // 数据来源类型设置为图库，则视频以及camera相关属性不可用，否则会 crash
            
            //设置可用的媒体类型,需要导入 MobileCoreServices
            picker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String, kUTTypeLivePhoto as String];
            
            picker.allowsEditing = true
            
            picker.delegate = self
            
            self.present(picker, animated: true, completion: nil)
            
        }else {
            
            let  alertVc = UIAlertController(title: "提示", message: "相机不可用", preferredStyle: .alert)
            
            let sureAction = UIAlertAction(title: "确定", style: .default, handler: nil)
            
            alertVc.addAction(sureAction)
            
            self.present(alertVc, animated: true, completion: nil)
            
        }
    }
    
    func showCommonPickerController() {
        
        //记得添加隐私权限
        
        //判断设备是否支持数据来源
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            
            // 实例化 UIImagePickerController 对象
            let picker = UIImagePickerController()
            
            // 设置数据来源类型
            picker.sourceType = .camera //相机
            
            //设置可用的媒体类型,需要导入 MobileCoreServices
            picker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String, kUTTypeLivePhoto as String];
            
            //            picker.allowsEditing = true
            
            //视频相关设置
            
            //设置拍摄视频的最长时间 20s
            picker.videoMaximumDuration = 20.0
            
            //设置拍摄视频的质量
            picker.videoQuality = .typeLow
            
            // sourceType 必须为相机才可用的设置
            // mediaTypes 包含 kUTTypeMovie
            picker.cameraCaptureMode = .video
            
            //设置为前置或者后置摄像头
            picker.cameraDevice = .rear
            
            //摄像头闪光灯设置
            picker.cameraFlashMode = .off
            
            picker.delegate = self
            
            self.present(picker, animated: true, completion: nil)
            
        }else {
            
            let  alertVc = UIAlertController(title: "提示", message: "相机不可用", preferredStyle: .alert)
            
            let sureAction = UIAlertAction(title: "确定", style: .default, handler: nil)
            
            alertVc.addAction(sureAction)
            
            self.present(alertVc, animated: true, completion: nil)
            
        }
        
        
    }
    
    func showCustomPickerController() {
        
        //判断设备是否支持数据来源
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            
            let picker = UIImagePickerController()
            
            picker.sourceType = .camera
            
            picker.mediaTypes = [kUTTypeMovie as String, kUTTypeImage as String];
            
            picker.videoMaximumDuration = 20.0
            
            picker.videoQuality = .typeHigh
            
            picker.cameraCaptureMode = .photo
            
            picker.cameraDevice = .rear
            
            picker.cameraFlashMode = .off
            
            // 自定义拍照界面
            let customCameraView = UIView(frame: UIScreen.main.bounds)
            
            //拍照按钮
            let takePicButton  = UIButton(type: .custom)
            takePicButton.frame = CGRect(x: (UIScreen.main.bounds.size.width - 80) * 0.5, y: UIScreen.main.bounds.size.height - 100, width: 80, height: 80)
            
            takePicButton.setImage(UIImage(named: "tap"), for: .normal)
            takePicButton.addTarget(self, action: #selector(takePic), for: .touchUpInside)
            self.takePicButton = takePicButton
            
            customCameraView.addSubview(takePicButton)
            
            let margin = (UIScreen.main.bounds.size.width - 2 * 100) / 3
            
            // 开始摄像按钮（如果是拍照，则不需要此按钮）
            let startButton  = UIButton(type: .custom)
            startButton.frame = CGRect(x: margin, y: 600, width: 100, height: 44)
            startButton.setTitle("开始视频",for: .normal)
            startButton.addTarget(self, action: #selector(startCapture), for: .touchUpInside)
            self.startButton = startButton
            
            customCameraView.addSubview(startButton)
            
            // 停止摄像按钮（如果是拍照，则不需要此按钮）
            let stopButton  = UIButton(type: .custom)
            stopButton.frame = CGRect(x: 2 * margin + 100, y: 600, width: 100, height: 44)
            stopButton.setTitle("停止视频",for: .normal)
            stopButton.addTarget(self, action: #selector(stopCapture), for: .touchUpInside)
            self.stopButton = stopButton
            
            customCameraView.addSubview(stopButton)
            
            // 切换拍照和视频的按钮
            let switchButton = UIButton(type: .custom)
            
            switchButton.frame = CGRect(x: UIScreen.main.bounds.size.width - 100 - 20, y: 20, width: 100, height: 44)
            switchButton.setTitle("拍照／视频", for: .normal)
            switchButton.addTarget(self, action: #selector(swithCaptureMode), for: .touchUpInside)
            self.switchButton = switchButton
            
            customCameraView.addSubview(switchButton)
            
            self.startButton?.isHidden = true
            self.stopButton?.isHidden = true
            
            //取消
            let cancelButton = UIButton(type: .custom)
            cancelButton.frame = CGRect(x: 20, y: 20, width: 50, height: 44)
            cancelButton.setTitle("取消", for: .normal)
            cancelButton.addTarget(self, action: #selector(dissmisController), for: .touchUpInside)
            
            customCameraView.addSubview(cancelButton)
            
            
            //sourceType 必须是 camera
            picker.cameraOverlayView = customCameraView
            
            // 是否显示 UIImagePickerController 底部控制部分的UI，默认true，需要定制底部UI的时候设置为false 隐藏默认UI
            picker.showsCameraControls = false
            
            // 当 showsCameraControls 为 NO 的时候，照片或者视频不可编辑 allowsEditing 设置无效
            picker.allowsEditing = true
            
            //设置拍照时 预览界面大小
            picker.cameraViewTransform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            
            picker.delegate = self
            
            self.pickerController = picker
            
            self.present(picker, animated: true, completion: nil)
            
        }else {
            
            let  alertVc = UIAlertController(title: "提示", message: "相机不可用", preferredStyle: .alert)
            
            let sureAction = UIAlertAction(title: "确定", style: .default, handler: nil)
            
            alertVc.addAction(sureAction)
            
            self.present(alertVc, animated: true, completion: nil)
        }
    }
    
    // 开始录制视频
    func startCapture() {
        
        self.pickerController?.stopVideoCapture()
        self.pickerController?.startVideoCapture()
    }
    
    // 停止录制视频
    func stopCapture() {
        
        self.pickerController?.stopVideoCapture()
    }
    
    func swithCaptureMode() {
        
        if self.pickerController?.cameraCaptureMode == UIImagePickerControllerCameraCaptureMode.video {
            
            self.pickerController?.cameraCaptureMode = .photo
            
            self.startButton?.isHidden = true
            self.stopButton?.isHidden = true
            self.takePicButton?.isHidden = false
            
        }else {
            self.pickerController?.cameraCaptureMode = .video
            
            self.startButton?.isHidden = false
            self.stopButton?.isHidden = false
            self.takePicButton?.isHidden = true
        }
    }
    
    func takePic() {
        
        self.pickerController?.takePicture()
    }
    
    
    func dissmisController() {
        
        self.pickerController?.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - UINavigationControllerDelegate, UIImagePickerControllerDelegate
    
    // 选择完图片或者视频后调用此代理方法（此方法不管是 sourceType 如何都会调用）
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        
        //info 里面是选中的图片或者视频的信息的字典，根据不同情况可能包含以下key
        
        // UIImagePickerControllerMediaType 用户选择的媒体类型
        // UIImagePickerControllerOriginalImage 用户选中的图像的原始 UIImage
        // UIImagePickerControllerEditedImage 用户选中的图像(编辑剪裁之后的 UIImage)
        // UIImagePickerControllerCropRect 编辑裁剪区域的Frame
        // UIImagePickerControllerMediaURL 用户选中的媒体文件的临时 URL地址
        // UIImagePickerControllerReferenceURL 用户选中的媒体文件的AssetsLibrary 地址
        // UIImagePickerControllerMediaMetadata 用户选中的图片的元数据
        // UIImagePickerControllerLivePhoto 用户选中的LivePhoto
        
        //获取媒体的类型
        let mediaType = info[UIImagePickerControllerMediaType] as! CFString
        
        if mediaType == kUTTypeImage {//选择的是照片
            
            // 如果过 allowsEditing 为 NO，UIImagePickerControllerEditedImage不存在，只有UIImagePickerControllerOriginalImage
            if let img = info[UIImagePickerControllerEditedImage] {
                
                UIImageWriteToSavedPhotosAlbum(img as! UIImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)),nil)
            }else {
                
                if let img = info[UIImagePickerControllerOriginalImage] {
                    
                    UIImageWriteToSavedPhotosAlbum(img as! UIImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)),nil)
                }
            }
            
        }
        
        if mediaType == kUTTypeMovie {//选择的是视频
            
            //获取到视频的临时路径
            if let urlStr = info[UIImagePickerControllerMediaURL] as? URL {
                
                if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(urlStr.path) {//判断视频路径是否可以被保存的相册
                    
                    //保存视频到图库中
                    DispatchQueue.global().async {
                        
                        UISaveVideoAtPathToSavedPhotosAlbum(urlStr.path, self, #selector(self.video(_ :didFinishSavingWithError:contextInfo:)), nil)
                        
                    }
                }
            }
        }
        
        if mediaType == kUTTypeLivePhoto {
            
            if let livePhoto = info[UIImagePickerControllerLivePhoto] as? PHLivePhoto {
                
                // 把选中的livephoto显示出来
                // livephoto 需要在 PHLivePhotoView 上才能显示，需要导入Photos 和 PhotosUI 两个库
                self.livePhotoView?.livePhoto = livePhoto
            }
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    // 用户点击取消后的代理方法，默认点击取消会 dissmiss PickerController
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    // 保存照片之后的回调，判断照片是否保存成功，方法名必须这样写
    func image(_ image: UIImage,
               didFinishSavingWithError error: NSError?,
               contextInfo: UnsafeRawPointer) {
        
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "警告", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "确定", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "提示", message: "照片成功保存到相册", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "确定", style: .default))
            present(ac, animated: true)
        }
    }
    
    // 保存视频之后的回调，判断视频是否保存成功，方法名必须这样写
    func video(_ videoPath: String,
               didFinishSavingWithError error: NSError?,
               contextInfo: UnsafeRawPointer) {
        
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "警告", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "确定", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "提示", message: "视频成功保存到相册", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "确定", style: .default))
            present(ac, animated: true)
        }
    }
}
