import UIKit
import AVKit
import Vision
import AVFoundation
import Firestore

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var db:Firestore!
    
    @IBOutlet weak var objectButton: UIButton!
    var delegate: CenterViewControllerDelegate?
    var thing = String()    //Setting thing as a gloabal var so that it can be accessed through the various funcs, string set in captureOutput()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        
        //var delegate: CenterViewControllerDelegate?
        
        // here is where we start up the camera
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        captureSession.addInput(input)
        
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
        
        self.view.addSubview(objectButton)    //Add overlay button as a subview after camera is initialized so it will display over camera layer
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else { return }
        let request = VNCoreMLRequest(model: model) { (finishedReq, err) in
            
            guard let results = finishedReq.results as? [VNClassificationObservation] else { return }
            
            guard let firstObservation = results.first else { return }
            
            self.thing = firstObservation.identifier    //Set thing variable to the detected object name
            
            //If label is tapped
                        
            if(self.thing == "banana" || self.thing == "strawberry" || self.thing == "orange")
            {
                DispatchQueue.main.async {
                print("This object is: " + firstObservation.identifier, firstObservation.confidence)
                //show label over object
                self.objectButton.isHidden = false    //Show button when object is detected
                self.objectButton.setTitle(self.thing, for: .normal)    //Set button label to whatever detected object is
                }
            } else {   //Hide button if no object is detected
                DispatchQueue.main.async {
                self.objectButton.isHidden = true
                }
            }
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
    
    //When user presses button that overlays the object
    @IBAction func onClick(_ sender: UIButton!) {
        Speak()  //Run text to speech function
        Favorite()  //Runs function that opens popup asking to save the object to favorites
    }
    
    //Function for text to speech
    func Speak() {
        let utter = AVSpeechUtterance(string:thing)
        utter.voice = AVSpeechSynthesisVoice(language: "en-US")
        utter.rate = 0.5//speedSlider.value
        let synth = AVSpeechSynthesizer()
        synth.speak(utter)
    }
    
    //Function that displays the 'Love it' or 'Try it' popup after user taps object
    func Favorite() {
        //---------------------------------------------------------------------
        //Below I am trying to add a new favorite to the database which will then display back to the favorite screen.
        let addPhraseAlert = UIAlertController(title: "New Object", message: "Would you like to add a new favorite?", preferredStyle: .alert)
        
        addPhraseAlert.addTextField {(textField:UITextField) in textField.placeholder = (self.thing)}
        
        addPhraseAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        addPhraseAlert.addAction(UIAlertAction(title: "Add", style: .default, handler: {
            (action:UIAlertAction) in
            
            if let phrase = addPhraseAlert.textFields?.first?.text {
                let newPhrase = Phrases(phrase: phrase, timeStamp: Date())
                
                var ref:DocumentReference? = nil
                // DocumentReference creates a random id
                ref = self.db.collection("phrases").addDocument(data: newPhrase.dictionary){
                    error in
                    if let error = error {
                        print("Error adding document: \(error.localizedDescription)")
                    } else {
                        print("Document added with ID: \(ref!.documentID)")
                    }
                }
            }
        }))
        
        self.present(addPhraseAlert, animated: true, completion: nil)
        ////////////////////////////////////////////////////////
    }
    
}
