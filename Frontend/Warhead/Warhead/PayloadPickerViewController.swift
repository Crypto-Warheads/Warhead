//
//  PayloadPickerViewController.swift
//  Warhead
//
//  Created by Alok Sahay on 02.06.2024.
//

import Foundation
import UIKit

class PayloadPickerViewController: UIViewController {
    
    @IBOutlet weak var slider: UISlider!
    
    @IBOutlet weak var payloadLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
            
    }
    
    @IBAction func sliderValueChanged(_ sender: Any) {
        let step: Float = 0.1
        let roundedValue = round(slider.value / step) * step
        slider.value = roundedValue
        print("Slider value: \(slider.value)")
        payloadLabel.text = "Payload Size: \(slider.value) ETH"
    }

    
}
