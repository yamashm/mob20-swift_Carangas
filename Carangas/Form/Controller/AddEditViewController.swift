//
//  AddEditViewController.swift
//  Carangas
//
//  Copyright © 2020 Eric Brito. All rights reserved.
//

import UIKit

class AddEditViewController: UIViewController {

    @IBOutlet weak var tfBrand: UITextField!
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfPrice: UITextField!
    @IBOutlet weak var scGasType: UISegmentedControl!
    @IBOutlet weak var btAddEdit: UIButton!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    var car: Car!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if car != nil {
            tfName.text = car.name
            tfPrice.text = "\(car.price))"
            tfBrand.text = car.brand
            scGasType.selectedSegmentIndex = car.gasType
            btAddEdit.setTitle("Alterar carro", for: .normal)
            title = "Alteração"
        }
    }
    
    @IBAction func addEdit(_ sender: UIButton) {
        if car == nil {
            car = Car()
        }
        car.brand = tfBrand.text!
        car.name = tfName.text!
        car.gasType = scGasType.selectedSegmentIndex
        car.price = Int(tfPrice.text!) ?? 0
        
        if car._id == nil {
            CarAPI().createCar(car){ [weak self] (_) in
                self?.goBack()
            }
        } else {
            CarAPI().updateCar(car){ [weak self] (_) in
                self?.goBack()
            }
        }
    }
    
    private func goBack(){
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
