//
//  PickCountryVC.swift
//  country-chat-app
//
//  Created by Quinto Cossio on 1/11/16.
//  Copyright © 2016 Quinto Cossio. All rights reserved.
//

import UIKit

class PickCountryVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var countryTextField: RoundTextField!
    
    var countryArray = [String]()
    var pickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        countryTextField.inputView = pickerView
        
        //Para hacer una lista de paises para usar despues
        for code in Locale.isoRegionCodes as [String]{
            let id = Locale.identifier(fromComponents: [NSLocale.Key.countryCode.rawValue : code])
            let name = (Locale(identifier: "en_EN") as NSLocale).displayName(forKey: NSLocale.Key.identifier, value: id) ?? "Country not found for code \(code)"
            countryArray.append(name)
            countryArray.sort(by: { (name1, name2) -> Bool in
                
                name1 < name2
            })
        }
        
        //Extensions para hacer desaparecer el keyboard
        self.hideKeyboardWhenTappedAround()
        self.hideKeyboardWhenSwipeDown()
    }

    @IBAction func continueBtnPressed(_ sender: AnyObject) {
        
        if let country = countryTextField.text, (country.characters.count > 0){
            
            
            
            
            //Preform segue to ChatVC
            
        }else{
            print("No country selected")
        }
        
        
        self.resignAllFirstResponder()
        
        
        
    }
    
    // MARK: - PickerView
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return countryArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        countryTextField.text = countryArray[row]
        
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countryArray.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func dismissPickerView(_ gesture: UITapGestureRecognizer){
        self.view.endEditing(true)
        
    }
    
    //MARK: Keyboard
    
    //To dismiss picker and keyboard when button pressed
    func resignAllFirstResponder(){
        
        countryTextField.resignFirstResponder()
       
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
