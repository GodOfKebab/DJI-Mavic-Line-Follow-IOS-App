
import UIKit
import DJIWidget
import DJISDK
import CoreImage
import DJIUXSDK
//import GPUImage


class FPVViewController: UIViewController, DJICameraDelegate,  VideoFrameProcessor, DJISDKManagerDelegate  {

////////////////////////////////////////VARIABLES//////////////////////////////////////////////////
    var TookOff = true
    var errorX: Int32 = 0
    var errorXPrev: Int32 = 0
    
    var Gimbalpitch = true
    
    var ImageViewType = 0
    
    var showFrame: UIImage? = nil
    
    var previewerAdapter: VideoPreviewerSDKAdapter? = nil

    var instObject: DronControl = DronControl()
    var fc: DJIFlightController = DJIFlightController()
    var compassValueTemp: Double = 0.0
    var cVS: String? = ""
    
    var nearPoint: Int32 = 0
    var nearPointGap: Float = 0.0
    var slope: Float = 0.0
    
    var VirtualStickEnabled = false
    
    /////////////////////////////////////IB OUTLETS/////////////////////////////////////////////////////
    
    
    @IBOutlet weak var fpvView: UIImageView!
    
    @IBOutlet weak var takeoffAndLand: UIButton!
    
    @IBOutlet weak var gimbalSetTo: UIButton!
    
    
    
//
//    @IBOutlet weak var takeoffAndLandState: UIButton!
//
//    @IBOutlet var fpvView: UIImageView!
//
//    @IBOutlet weak var GimbalSetTo: UIButton!
//
//    @IBOutlet weak var GrayScaleView: UIButton!
//
//    @IBOutlet weak var ThresholdView: UIButton!
//
//    @IBOutlet weak var ContouredView: UIButton!
    
    
    ////////////////////////////////////////USEFUL FUNCTIONS//////////////////////////////////////////////////
    
    
    func videoProcessFrame(_ frame: UnsafeMutablePointer<VideoFrameYUV>!) {
        
        print("videoProcessFrame(main) function is called")
        
        if (VirtualStickEnabled){
            mainAlgorithm()
        }
        
        
        
        if (DJIVideoPreviewer.instance().enableHardwareDecode && (frame.pointee.cv_pixelbuffer_fastupload != nil)) {
            
            
            self.showFrame = OpenCVProcessor.init().process(frame, videoShowType: Int32(self.ImageViewType))
            
            
            
            DispatchQueue.main.sync{
                
                print("gets into the main queue")
                
                if(self.showFrame != nil){
                    print("show UIImage typed processed frames")
                    self.fpvView.image = self.showFrame
                } else{
                    print("cannot show UIImage typed processed frames")
                }
                
            }
        } else{
            print("either did not enable the hardware decode nor the CVPixelBuffer is nil")
        }
    }
    
    
    @IBAction func onTouchTakeoffAndLand(_ sender: Any) {
        print("Touched TakeoffAndLand button")
        
        if(self.TookOff){
            print("taking off")
            TakeOffAndLandClass.init().takeOffWithCompletion()
            self.SetGimbalPitch(setAngle: -85)
            self.TookOff = false
        }
        else{
            print("landing")
            TakeOffAndLandClass.init().landWithCompletion()
            self.SetGimbalPitch(setAngle: 0)
            self.TookOff = true
            
        }
    }
    

    @IBAction func OnTouchGimbal(_ sender: Any) {
        print("Touched GimbalSet button")
        
        if(self.Gimbalpitch){
            self.SetGimbalPitch(setAngle: -90)
            print("gimbal angle set to -90")
            self.Gimbalpitch = false
        } else{
            self.SetGimbalPitch(setAngle: 0)
            print("gimbal angle set to 0")
            self.Gimbalpitch = true
        }
    }
    
    
    @IBAction func onTouchGrayScaleView(_ sender: Any) {
        
        print("Will show GrayScale next frame")
        
        self.ImageViewType = 0
    }
    
    
    @IBAction func onTouchThresholdedView(_ sender: Any) {
        
        print("Will show Thresholded next frame")
        
        self.ImageViewType = 1
    }
    
    
    @IBAction func onTouchContouredView(_ sender: Any) {
        
        print("Will show Contoured next frame")
        
        self.ImageViewType = 2
    }
    

    
    ///////////////////////////////////////NO TOUCH FUNCTIONS//////////////////////////////////////////////////
    
    func SetGimbalPitch(setAngle: Int){
        
        let gimbal = DJISDKManager.product()!.gimbal
        
        let rotation = DJIGimbalRotation.init(pitchValue: NSNumber(integerLiteral: setAngle), rollValue: nil, yawValue: nil, time: 2
            , mode: DJIGimbalRotationMode.absoluteAngle)
        
        gimbal?.rotate(with: rotation, completion: nil)
    }
    
    
    func videoProcessorEnabled() -> Bool {
        return true
    }
    
    ///////////////////////////////////////DJI CODE READY FUNCTIONS//////////////////////////////////////////////////
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DJISDKManager.registerApp(with: self)
        self.setupVideoPreviewer()
        instObject.setAircraftOrientation()
        DJIVideoPreviewer.instance().registFrameProcessor(self)
        DJIVideoPreviewer.instance().enableHardwareDecode = true
        //instObject.onEnterVirtualStickControlButtonClicked()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        

        DJIVideoPreviewer.instance()?.unSetView()
        if ((self.previewerAdapter) != nil) {
            self.previewerAdapter?.stop()
            self.previewerAdapter = nil
        }
    }
    
    func setupVideoPreviewer() {
        
        DJIVideoPreviewer.instance().start()
        self.previewerAdapter = VideoPreviewerSDKAdapter.withDefaultSettings()
        self.previewerAdapter?.start()
    }
    
    func productConnected(_ product: DJIBaseProduct?) {
        
        NSLog("Product Connected")
        
        //If this demo is used in China, it's required to login to your DJI account to activate the application. Also you need to use DJI Go app to bind the aircraft to your DJI account. For more details, please check this demo's tutorial.
        DJISDKManager.userAccountManager().logIntoDJIUserAccount(withAuthorizationRequired: false) { (state, error) in
            if(error != nil){
                NSLog("Login failed: %@" + String(describing: error))
            }
        }
        
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
    
    func showAlertViewWithTitle(title: String, withMessage message: String) {
        
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction.init(title:"OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
        
    }

    
    @IBAction func enterVirtualStickMode(_ sender: Any) {
        instObject.onEnterVirtualStickControlButtonClicked()
        
        VirtualStickEnabled = true
    }
    
    @IBAction func exitVirtualStickMode(_ sender: Any) {
        instObject.onExitVirtualStickControlButtonClicked()
        
        VirtualStickEnabled = false
    }
    
    
    func mainAlgorithm(){//kendi çapında çalışıyor
        
        //print(compassValueTemp)
        //compassValue.text = String(compassValueTemp)
        
        //compass compass compass compass compass compass compass compass
        
        // dron dron dron dron dron dron dron dron dron dron dron dron
        /*
         valueX2 = 0.0;
         valueX1 = 0.0;
         valueX0 = 0.0;
         var straightLine: Bool = standardDeviation();//kedisinde dönsün
         
         if(straightLine && self.dronState == 0){
         //go strait for 2 secs
         instObject.setYVelocity(0.4); // for 2 sec burdan çıkmıycak
         self.dronState = 1
         }
         else if(dronState == 1)
         {
         //untill
         }*/
        
        
        errorX = OpenCVProcessor.init().errorXupdated() //as! Int32
        
        if(errorX != errorXPrev){
            nearPoint = errorX;
            nearPointGap = (Float(nearPoint) - 160)/160;//320 240
            if(nearPointGap > 0.2 || nearPointGap < -0.2)
            {
                if(nearPointGap > 0)
                {
                    instObject.setXVelocity(0.05);
                    //instObject.setYVelocity(0.1);
                }
                else
                {
                    instObject.setXVelocity(-0.05);
                    //instObject.setYVelocity(0.1);
                }
                //instObject.setXVelocity(0);

                //instObject.setYaw(nearPointGap/6);
                //instObject.setXVelocity(0);
            }
            
            //instObject.setYVelocity(0.1);
            
            //instObject.setXVelocity(0);

        }
        
        
        
        
        /*
         if(slope < 5.0 || slope < -5.0)
         {
         set.yaw
         }*/
        //instObject.setYaw(0.1);
        //instObject.setXVelocity(0.0);
        errorXPrev = errorX
    }

    
    
}
