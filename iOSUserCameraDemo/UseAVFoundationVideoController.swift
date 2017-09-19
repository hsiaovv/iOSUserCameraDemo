//
//  UseAVFoundationVideoController.swift
//  iOSUserCameraDemo
//
//  Created by xiaovv on 2017/9/19.
//  Copyright © 2017年 xiaovv. All rights reserved.
//


import UIKit
import AVFoundation
import Photos

class UseAVFoundationVideoController: UIViewController,UIGestureRecognizerDelegate,AVCaptureFileOutputRecordingDelegate,AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate {
    
    var captureSession: AVCaptureSession?
    
    var captureDevice: AVCaptureDevice?
    
    var captureInput: AVCaptureDeviceInput?
    
    var captureMovieFileOutput: AVCaptureMovieFileOutput?
    
    var captureVideoDataOutput: AVCaptureVideoDataOutput?
    
    var captureAudioDataOutput: AVCaptureAudioDataOutput?
    
    var preview: UIView?
    
    var tapButton: UIButton?
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    lazy var sessionQueue: DispatchQueue = {
        
        let queue = DispatchQueue(label: "com.xiaovv.iOSUseCamera")
        
        return queue
        
    }()
    
    var assetWriter: AVAssetWriter?
    
    var assetWriterVideoInput: AVAssetWriterInput?
    
    var assetWriterAudioInput: AVAssetWriterInput?
    
    var videoUrl: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1)
        
        initUI()
        
        checkAuthorization()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        if (captureSession?.isRunning)! {
            
            captureSession?.stopRunning()
        }
    }
    
    // 初始化自定义相机UI
    fileprivate func initUI() {
        
        let preview = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height * 0.7))
        preview.backgroundColor = UIColor.black
        
        self.view.addSubview(preview)
        self.preview = preview
        
        let closeButton = UIButton(type: .custom)
        closeButton.frame = CGRect(x: 20, y: 20, width: 44, height: 44)
        closeButton.setTitle("关闭", for: .normal)
        closeButton.setTitleColor(UIColor.white, for: .normal)
        closeButton.addTarget(self, action: #selector(closeClick), for: .touchUpInside)
        self.preview?.addSubview(closeButton)
        
        let toggleButton = UIButton(type: .custom)
        toggleButton.frame = CGRect(x: UIScreen.main.bounds.size.width - 20 - 44, y: 20, width: 44, height: 44)
        toggleButton.setTitle("切换", for: .normal)
        toggleButton.setTitleColor(UIColor.white, for: .normal)
        toggleButton.addTarget(self, action: #selector(toggleCamera), for: .touchUpInside)
        self.preview?.addSubview(toggleButton)
        
        let torchButton = UIButton(type: .custom)
        torchButton.frame = CGRect(x: (UIScreen.main.bounds.size.width - 100) * 0.5, y: 20, width: 100, height: 44)
        torchButton.setTitle("打开手电筒", for: .normal)
        torchButton.setTitle("关闭手电筒", for: .selected)
        torchButton.setTitleColor(UIColor.white, for: .normal)
        torchButton.addTarget(self, action: #selector(changeTorch), for: .touchUpInside)
        self.preview?.addSubview(torchButton)
        
        let tapButton = UIButton(type: .custom)
        tapButton.bounds = CGRect(x: 0, y: 0, width: 80, height: 80)
        tapButton.center = CGPoint(x: UIScreen.main.bounds.size.width * 0.5, y: UIScreen.main.bounds.size.height * 0.85)
        tapButton.setImage(UIImage(named: "videoRecord"), for: .normal)
        tapButton.setImage(UIImage(named: "videoPause"), for: .selected)
        
        tapButton.addTarget(self, action: #selector(recordVideo), for: .touchUpInside)
        
        self.view.addSubview(tapButton)
        self.tapButton = tapButton
    }
    
    // 检查授权
    fileprivate func checkAuthorization()  {
        
        /**
         AVAuthorizationStatusNotDetermined // 未进行授权选择
         AVAuthorizationStatusRestricted // 未授权，且用户无法更新，如家长控制情况下
         AVAuthorizationStatusDenied // 用户拒绝App使用
         AVAuthorizationStatusAuthorized // 已授权，可使用
         */
        
        switch AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) {
            
        case .authorized: // 已授权，可使用
            
            self.configureCaptureSession()
            
        case .notDetermined://进行授权选择
            
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted) in
                
                if granted {
                    
                    self.configureCaptureSession()
                    
                }else {
                    
                    let alert = UIAlertController(title: "提示", message: "用户拒绝授权使用相机", preferredStyle: .alert)
                    
                    let alertAction = UIAlertAction(title: "确定", style: .default, handler: nil)
                    
                    alert.addAction(alertAction)
                    
                    self.present(alert, animated: true, completion: nil)
                }
            })
            
            
        default: //用户拒绝和未授权
            
            let alert = UIAlertController(title: "提示", message: "用户拒绝授权使用相机", preferredStyle: .alert)
            
            let alertAction = UIAlertAction(title: "确定", style: .default, handler: nil)
            
            alert.addAction(alertAction)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // 配置会话对象
    fileprivate func configureCaptureSession() {
        
        captureSession = AVCaptureSession()
        
        captureSession?.beginConfiguration()
        
        // CaptureSession 的会话预设,这个地方设置的模式/分辨率大小将影响你后面拍摄照片/视频的大小
        captureSession?.sessionPreset = AVCaptureSessionPresetHigh
        
        // 添加输入
        do {
            
            let cameraDeviceInput = try AVCaptureDeviceInput(device: self.cameraWithPosition(.back))
            
            if (captureSession?.canAddInput(cameraDeviceInput))! {
                
                captureSession?.addInput(cameraDeviceInput)
                
                captureInput = cameraDeviceInput
            }
            
            
            let audioDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
            
            let audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice)
            
            if (captureSession?.canAddInput(audioDeviceInput))! {
                
                captureSession?.addInput(audioDeviceInput)
            }
            
        } catch let error as NSError {
            
            print(error.localizedDescription)
        }
        
        // 添加输出
        // 本文 iOS 10 以后 相机的照片输出和视频输出使用 AVCaptureVideoDataOutput
        if #available(iOS 10.0, *) {
            
            // 添加 AVCaptureVideoDataOutput 用于输出视频
            let captureVideoDataOutput = AVCaptureVideoDataOutput()
            
            if (captureSession?.canAddOutput(captureVideoDataOutput))! {
                
                captureSession?.addOutput(captureVideoDataOutput)
            }
            
            self.captureVideoDataOutput = captureVideoDataOutput
            
            // 添加 AVCaptureAudioDataOutput 用于输出音频
            let captureAudioDataOutput = AVCaptureAudioDataOutput()
            
            if (captureSession?.canAddOutput(captureAudioDataOutput))! {
                
                captureSession?.addOutput(captureAudioDataOutput)
            }
            
            self.captureAudioDataOutput = captureAudioDataOutput
            
            captureVideoDataOutput.setSampleBufferDelegate(self, queue: sessionQueue)
            
            captureAudioDataOutput.setSampleBufferDelegate(self, queue: sessionQueue)
            
        } else {
            
            // iOS 10 以后 相机视频输出使用 AVCaptureMovieFileOutput
            captureMovieFileOutput = AVCaptureMovieFileOutput()
            
            if (captureSession?.canAddOutput(captureMovieFileOutput))! {
                
                captureSession?.addOutput(captureMovieFileOutput)
            }
            
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        previewLayer?.frame = (self.preview?.bounds)!
        previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        //预览图层和视频方向保持一致
        if #available(iOS 10.0, *) {
            
            captureVideoDataOutput?.connection(withMediaType: AVMediaTypeVideo).videoOrientation = (previewLayer?.connection.videoOrientation)!
            
        } else {
            
            captureMovieFileOutput?.connection(withMediaType: AVMediaTypeVideo).videoOrientation = (previewLayer?.connection.videoOrientation)!
        }
        
        preview?.layer.insertSublayer(self.previewLayer!, at: 0)
        
        captureSession?.commitConfiguration()
        
        self.sessionQueue.async {
            
            self.captureSession?.startRunning()
        }
        
    }
    
    fileprivate func configureAssetWriter() {
        
        // 设置 AVAssetWriter 的视频输入设置
        let videoSettings = [AVVideoCodecKey: AVVideoCodecH264,
                             AVVideoWidthKey: 720,
                             AVVideoHeightKey: 1280] as [String : Any];
        
        let assetWriterVideoInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: videoSettings)
        
        assetWriterVideoInput.expectsMediaDataInRealTime = true
        
        self.assetWriterVideoInput = assetWriterVideoInput
        
        // 设置 AVAssetWriter 的音频输入设置
        let audioSettings = [AVFormatIDKey: kAudioFormatMPEG4AAC,
                             AVSampleRateKey: NSNumber(value: 44100.0),
                             AVNumberOfChannelsKey: NSNumber(value: 2)] as [String : Any]
        
        let assetWriterAudioInput = AVAssetWriterInput(mediaType: AVMediaTypeAudio, outputSettings: audioSettings)
        assetWriterAudioInput.expectsMediaDataInRealTime = true
        
        self.assetWriterAudioInput = assetWriterAudioInput
        
        let videoUrlStr = NSTemporaryDirectory() + "tempVideo.mp4"
        
        let videoUrl = URL(fileURLWithPath: videoUrlStr)
        
        self.videoUrl = videoUrl
        
        do {
            try FileManager.default.removeItem(at: videoUrl)
            
        } catch {
            
            print(error)
        }
        
        do {
            
            let assetWriter = try AVAssetWriter(url: videoUrl, fileType: AVFileTypeMPEG4)
            
            if assetWriter.canAdd(assetWriterVideoInput) {
                
                assetWriter.add(assetWriterVideoInput)
            }
            
            if assetWriter.canAdd(assetWriterAudioInput) {
                
                assetWriter.add(assetWriterAudioInput)
            }
            
            self.assetWriter = assetWriter
            
        } catch {
            
            print(error)
        }
    }
    
    func recordVideo(button: UIButton) {
        
        button.isSelected = !button.isSelected
        
        if #available(iOS 10.0, *) { // iOS 10 这里 使用 AVAssetWriter 保存视频
            
            print("assetWriter.status+++\(String(describing: self.assetWriter?.status.rawValue))")
            
            if let assetWriter = self.assetWriter,assetWriter.status == .writing {// 正在录制，保存
                
                if let videoWriterInput = self.assetWriterVideoInput {
                    
                    videoWriterInput.markAsFinished()
                }
                
                if let audioWriterInput = self.assetWriterAudioInput {
                    
                    audioWriterInput.markAsFinished()
                }
                
                assetWriter.finishWriting(completionHandler: {
                    
                    // 视频已经完成写入到指定的路径
                    // 可以把视频保存到相册或者保存到APP的沙盒
                    if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(assetWriter.outputURL.path) {
                        
                        DispatchQueue.global().async {
                            
                            UISaveVideoAtPathToSavedPhotosAlbum(assetWriter.outputURL.path, self, #selector(self.video(_ :didFinishSavingWithError:contextInfo:)), nil)
                        }
                    }
                    
                })
                
            }else {// 开始录制视频
                
                configureAssetWriter()
                
                captureVideoDataOutput?.setSampleBufferDelegate(self, queue: sessionQueue)
                
                captureAudioDataOutput?.setSampleBufferDelegate(self, queue: sessionQueue)
                
            }
            
        } else { // iOS 10 之前 这里 使用 AVCaptureMovieFileOutput 输出视频
            
            if (captureMovieFileOutput?.isRecording)! {//判断当前是否已经在录制视频
                
                captureMovieFileOutput?.stopRecording()
                
            }else {
                
                let url = URL(fileURLWithPath: NSTemporaryDirectory() + "outPut.mov")
                
                captureMovieFileOutput?.startRecording(toOutputFileURL: url, recordingDelegate: self)
            }
        }
    }
    
    
    func toggleCamera() {
        
        var newPostion: AVCaptureDevicePosition
        
        if self.captureInput?.device.position == AVCaptureDevicePosition.back {
            
            newPostion = .front
        }else {
            
            newPostion = .back
        }
        
        
        do {
            
            let cameraDeviceInput = try AVCaptureDeviceInput(device: self.cameraWithPosition(newPostion))
            
            self.sessionQueue.async {
                
                self.captureSession?.beginConfiguration()
                
                self.captureSession?.removeInput(self.captureInput)
                
                if (self.captureSession?.canAddInput(cameraDeviceInput))! {
                    
                    self.captureSession?.addInput(cameraDeviceInput)
                    
                    self.captureInput = cameraDeviceInput
                }
                
                self.captureSession?.commitConfiguration()
            }
            
        } catch let error as NSError {
            
            print(error.localizedDescription)
        }
    }
    
    func changeTorch(button: UIButton) {
        
        button.isSelected = !button.isSelected
        
        if (self.captureInput?.device.hasTorch)! {//打开手电筒
            
            do {
                
                try self.captureInput?.device.lockForConfiguration()
                
                if button.isSelected {
                    self.captureInput?.device.torchMode = AVCaptureTorchMode.on
                }else {
                    self.captureInput?.device.torchMode = AVCaptureTorchMode.off
                }
                
            } catch let error as NSError {
                
                print(error.localizedDescription)
            }
            
            self.captureInput?.device.unlockForConfiguration()
        }
        
    }
    
    func closeClick() {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func cameraWithPosition(_ position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        
        if #available(iOS 10.0, *) {
            
            let devices = AVCaptureDeviceDiscoverySession(deviceTypes: [AVCaptureDeviceType.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: position).devices!
            
            for device in devices {
                
                if device.position == position {
                    
                    return device
                }
            }
            
        } else {
            
            let devices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) as! [AVCaptureDevice]
            
            for device in devices {
                
                if device.position == position {
                    
                    print(device.formats)
                    
                    return device
                }
            }
        }
        
        return nil
        
    }
    
    
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        
        print("#function--\(#function)")
        
        objc_sync_enter(self)
        
        if let assetWriter = self.assetWriter {
            
            if assetWriter.status != .writing && assetWriter.status != .unknown {
                return
            }
        }
        
        if let assetWriter = self.assetWriter, assetWriter.status == AVAssetWriterStatus.unknown {
            
            assetWriter.startWriting()
            assetWriter.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(sampleBuffer))
        }
        
        // 视频数据
        if connection == captureVideoDataOutput?.connection(withMediaType: AVMediaTypeVideo) {
            
            let videoDataOutputQueue = DispatchQueue(label: "com.xiaovv.videoDataOutputQueue")
            
            videoDataOutputQueue.async {
                
                if let videoWriterInput = self.assetWriterVideoInput, videoWriterInput.isReadyForMoreMediaData {
                    
                    videoWriterInput.append(sampleBuffer)
                }
            }
            
        }
        
        // 音频数据
        if connection == captureAudioDataOutput?.connection(withMediaType: AVMediaTypeAudio) {
            
            let audioDataOutputQueue = DispatchQueue(label: "com.xiaovv.audioDataOutputQueue")
            
            audioDataOutputQueue.async {
                
                if let audioWriterInput = self.assetWriterAudioInput, audioWriterInput.isReadyForMoreMediaData {
                    
                    audioWriterInput.append(sampleBuffer)
                }
            }
        }
        
        objc_sync_exit(self)
        
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didDrop sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        
        
    }
    
    // MARK: - AVCaptureFileOutputRecordingDelegate
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        
        print("开始录制")
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        
        print("停止录制")
        
        if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(outputFileURL.path) {//判断视频路径是否可以被保存的相册
            
            //保存视频到图库中
            DispatchQueue.global().async {
                
                UISaveVideoAtPathToSavedPhotosAlbum(outputFileURL.path, self, #selector(self.video(_ :didFinishSavingWithError:contextInfo:)), nil)
            }
        }
        print(outputFileURL)
    }
    
    // MARK: - UISaveVideoAtPathToSavedPhotosAlbum
    
    //UISaveVideoAtPathToSavedPhotosAlbum 保存视频之后的回调，判断视频是否保存成功，方法名必须这样写
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
            let sureAction = UIAlertAction(title: "确定", style: .default, handler: { (action) in
                
                self.dismiss(animated: true, completion: nil)
            })
            
            ac.addAction(sureAction)
            present(ac, animated: true)
        }
    }
}
