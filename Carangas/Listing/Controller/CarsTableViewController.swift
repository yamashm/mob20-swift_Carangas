//
//  CarsTableViewController.swift
//  Carangas
//
//  Copyright © 2020 Eric Brito. All rights reserved.
//

import UIKit

class CarsTableViewController: UITableViewController {
    
    // MARK: - Properties
    var cars: [Car] = []
    
    // MARK: - Super Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl?.addTarget(self, action: #selector(loadCars), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadCars()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? CarViewController, let row = tableView.indexPathForSelectedRow?.row{
            vc.car = cars[row]
        }
    }
    
    // MARK: - Methods
    @objc private func loadCars(){
        
        //GEITO VIDA LOKA
               /*
               URLSession.shared.dataTask(with: URL(string: "https://carangas.herokuapp.com/cars")!) { (data, _, _) in
                   self.cars = try! JSONDecoder().decode([Car].self, from: data!)
                   DispatchQueue.main.async {self.tableView.reloadData()}
               }.resume()
               */
        
        //weak self para evitar referencia ciclica
        CarAPI().loadCars {[weak self] (result) in
            guard let self = self else {return}
            switch result{
            case .success(let cars):
                self.cars = cars
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let apiError):
                switch apiError {
                case .badURL:
                    print("URL inválida")
                default:
                    print("Outro cenário de erro")
                }
                
            }
            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing()
            }
        }
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cars.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let car = cars[indexPath.row]
        cell.textLabel?.text = car.name
        cell.detailTextLabel?.text = car.brand
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let car = cars[indexPath.row]
            CarAPI().deleteCar(car) { [weak self] (result) in
                switch result {
                case .success:
                    self?.cars.remove(at: indexPath.row)
                    DispatchQueue.main.async {
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                    }
                case .failure:
                    print("Erro")
                }
            }
        }
    }
}
