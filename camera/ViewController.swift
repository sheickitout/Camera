//
//  ViewController.swift
//  camera
//
//  Created by Sheick on 4/13/21.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    //delegation is a desgin pattern -> Text Field: Properties
    //steps to implement a delegate
    //1. create an object, 2. initialize a delegate
    let imagePicker = UIImagePickerController()
    
    var result : [VNClassificationObservation] = []

    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imagePicker.delegate = self //initialized delegate
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //1. select image, 2. convert image from UI image data type to CI image, 3. detect image
        
        if let image = info[.originalImage] as? UIImage{
            
            imageView.image = image
            
            //convert to CIImage
            imagePicker.dismiss(animated: true, completion: nil)
            
            guard let ciImage = CIImage(image: image) else {
                fatalError("Failed to convert UIImage to CIImage")
            }
            detect(image: ciImage)
        }
    }
    
    func detect(image:CIImage){
        //Initialize the model
        if let model = try? VNCoreMLModel(for: Inceptionv3().model){
            
            //Request
            let request =  VNCoreMLRequest(model: model) { (request, error) in
                
                //Results
                guard let results = request.results as? [VNClassificationObservation],
                      let topResult = results.first else{
                    fatalError("Could not get the correct data classification type")
                }
                
                if topResult.identifier.contains("hotdog"){
                    
                    DispatchQueue.main.async {
                        self.navigationItem.title = "Hotdog!"
                    }
                    
                }
                else{
                    DispatchQueue.main.async {
                        self.navigationItem.title = "Not Hotdog!"
                    }
                    
                }
                
            }
            
            let handler = VNImageRequestHandler(ciImage:image)
            do{
                
                try handler.perform([request])
            }
            catch{
                print(error)
            }
        }
        
        
    }
    
    //Handler
    
    
    
    @IBAction func cameraPressed(_ sender: Any) {
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        
        present(imagePicker, animated: true, completion: nil)
    }
    

}

