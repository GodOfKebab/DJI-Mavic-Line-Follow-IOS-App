//
//  FPVViewController.swift
//  iOS-FPVDemo-Swift
//

import UIKit
import DJISDK
import DJIWidget

class VViewController: UIViewController,  DJIVideoFeedListener, DJISDKManagerDelegate, DJICameraDelegate, VideoFrameProcessor {
    func videoProcessorEnabled() -> Bool {
        
    }
    
    func videoProcessFrame(_ frame: UnsafeMutablePointer<VideoFrameYUV>!) {
        
    }
    

    
    var isRecording : Bool!
    
    @IBOutlet var recordTimeLabel: UILabel!
    
    @IBOutlet var captureButton: UIButton!
    
    @IBOutlet var recordButton: UIButton!
    
    @IBOutlet var workModeSegmentControl: UISegmentedControl!
    
    @IBOutlet var fpvView: UIView!
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let camera = self.fetchCamera()
        if((camera != nil) && (camera?.delegate?.isEqual(self))!){
            camera?.delegate = nil
        }
        self.resetVideoPreview()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DJIVideoPreviewer.instance().registFrameProcessor(self)
        DJIVideoPreviewer.instance()?.enableHardwareDecode = true
        print("         \(DJIVideoPreviewer.instance().enableHardwareDecode)")
        DJISDKManager.registerApp(with: self)
        recordTimeLabel.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupVideoPreviewer() {
        
        DJIVideoPreviewer.instance().setView(self.fpvView)
        let product = DJISDKManager.product();
        
        //Use "SecondaryVideoFeed" if the DJI Product is A3, N3, Matrice 600, or Matrice 600 Pro, otherwise, use "primaryVideoFeed".
        if ((product?.model == DJIAircraftModelNameA3)
            || (product?.model == DJIAircraftModelNameN3)
            || (product?.model == DJIAircraftModelNameMatrice600)
            || (product?.model == DJIAircraftModelNameMatrice600Pro)){
            DJISDKManager.videoFeeder()?.secondaryVideoFeed.add(self, with: nil)
        }else{
            DJISDKManager.videoFeeder()?.primaryVideoFeed.add(self, with: nil)
        }
        DJIVideoPreviewer.instance().start()
    }
    
    func resetVideoPreview() {
        DJIVideoPreviewer.instance().unSetView()
        let product = DJISDKManager.product();
        
        //Use "SecondaryVideoFeed" if the DJI Product is A3, N3, Matrice 600, or Matrice 600 Pro, otherwise, use "primaryVideoFeed".
        if ((product?.model == DJIAircraftModelNameA3)
            || (product?.model == DJIAircraftModelNameN3)
            || (product?.model == DJIAircraftModelNameMatrice600)
            || (product?.model == DJIAircraftModelNameMatrice600Pro)){
            DJISDKManager.videoFeeder()?.secondaryVideoFeed.remove(self)
        }else{
            DJISDKManager.videoFeeder()?.primaryVideoFeed.remove(self)
        }
    }
    
    func fetchCamera() -> DJICamera? {
        let product = DJISDKManager.product()
        
        if (product == nil) {
            return nil
        }
        
        if (product!.isKind(of: DJIAircraft.self)) {
            return (product as! DJIAircraft).camera
        } else if (product!.isKind(of: DJIHandheld.self)) {
            return (product as! DJIHandheld).camera
        }
        return nil
    }
    
    func formatSeconds(seconds: UInt) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(seconds))
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "mm:ss"
        return(dateFormatter.string(from: date))
    }
    
    func showAlertViewWithTitle(title: String, withMessage message: String) {
        
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction.init(title:"OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    // DJISDKManagerDelegate Methods
    func productConnected(_ product: DJIBaseProduct?) {
        
        NSLog("Product Connected")
        
        if (product != nil) {
            let camera = self.fetchCamera()
            if (camera != nil) {
                camera!.delegate = self
            }
            self.setupVideoPreviewer()
        }
        
        //If this demo is used in China, it's required to login to your DJI account to activate the application. Also you need to use DJI Go app to bind the aircraft to your DJI account. For more details, please check this demo's tutorial.
        DJISDKManager.userAccountManager().logIntoDJIUserAccount(withAuthorizationRequired: false) { (state, error) in
            if(error != nil){
                NSLog("Login failed: %@" + String(describing: error))
            }
        }
        
    }
    
    func productDisconnected() {
        
        NSLog("Product Disconnected")
        
        let camera = self.fetchCamera()
        if((camera != nil) && (camera?.delegate?.isEqual(self))!){
            camera?.delegate = nil
        }
        self.resetVideoPreview()
    }
    
    func appRegisteredWithError(_ error: Error?) {
        
        var message = "Register App Successed!"
        if (error != nil) {
            message = "Register app failed! Please enter your app key and check the network."
        } else {
            DJISDKManager.startConnectionToProduct()
        }
        
        self.showAlertViewWithTitle(title:"Register App", withMessage: message)
    }
    
    // DJICameraDelegate Method
    func camera(_ camera: DJICamera, didUpdate cameraState: DJICameraSystemState) {
        self.isRecording = cameraState.isRecording
        self.recordTimeLabel.isHidden = !self.isRecording
        
        self.recordTimeLabel.text = formatSeconds(seconds: cameraState.currentVideoRecordingTimeInSeconds)
        
        if (self.isRecording == true) {
            self.recordButton.setTitle("Stop Record", for: UIControl.State.normal)
        } else {
            self.recordButton.setTitle("Start Record", for: UIControl.State.normal)
        }
        
        //Update UISegmented Control's State
        if (cameraState.mode == DJICameraMode.shootPhoto) {
            self.workModeSegmentControl.selectedSegmentIndex = 0
        } else {
            self.workModeSegmentControl.selectedSegmentIndex = 1
        }
        
    }
    
    // DJIVideoFeedListener Method
    func videoFeed(_ videoFeed: DJIVideoFeed, didUpdateVideoData rawData: Data) {
        
        let videoData = rawData as NSData
        let videoBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: videoData.length)
        videoData.getBytes(videoBuffer, length: videoData.length)
        DJIVideoPreviewer.instance().push(videoBuffer, length: Int32(videoData.length))
    }
    
    // IBAction Methods
    @IBAction func captureAction(_ sender: UIButton) {
        
        let camera = self.fetchCamera()
        if (camera != nil) {
            camera?.setMode(DJICameraMode.shootPhoto, withCompletion: {(error) in
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1){
                    camera?.startShootPhoto(completion: { (error) in
                        if (error != nil) {
                            NSLog("Shoot Photo Error: " + String(describing: error))
                        }
                    })
                }
            })
        }
    }
    
    @IBAction func recordAction(_ sender: UIButton) {
        
        let camera = self.fetchCamera()
        if (camera != nil) {
            if (self.isRecording) {
                camera?.stopRecordVideo(completion: { (error) in
                    if (error != nil) {
                        NSLog("Stop Record Video Error: " + String(describing: error))
                    }
                })
            } else {
                camera?.startRecordVideo(completion: { (error) in
                    if (error != nil) {
                        NSLog("Start Record Video Error: " + String(describing: error))
                    }
                })
            }
        }
    }
    
    @IBAction func workModeSegmentChange(_ sender: UISegmentedControl) {
        
        let camera = self.fetchCamera()
        if (camera != nil) {
            if (sender.selectedSegmentIndex == 0) {
                camera?.setMode(DJICameraMode.shootPhoto,  withCompletion: { (error) in
                    if (error != nil) {
                        NSLog("Set ShootPhoto Mode Error: " + String(describing: error))
                    }
                })
                
            } else if (sender.selectedSegmentIndex == 1) {
                camera?.setMode(DJICameraMode.recordVideo,  withCompletion: { (error) in
                    if (error != nil) {
                        NSLog("Set RecordVideo Mode Error: " + String(describing: error))
                    }
                })
                
            }
        }
    }
    
}
