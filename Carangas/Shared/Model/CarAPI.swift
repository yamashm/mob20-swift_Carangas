//
//  CarAPI.swift
//  Carangas
//
//  Created by Usuário Convidado on 29/09/20.
//  Copyright © 2020 Eric Brito. All rights reserved.
//

import Foundation

enum APIError: Error{
    case badURL
    case taskError
    case noResponse
    case invalidStatusCpde(Int)
    case noData
    case decodeError
}

class CarAPI{
    // Por padrão tudo é internal
    private let basePath = "https://carangas.herokuapp.com/cars"
    private let configuration: URLSessionConfiguration = {
        //Configurações padrão
        let configuration = URLSessionConfiguration.default
        //Configuração anônima
        //let configuration = URLSessionConfiguration.ephemeral
        //Usa dados dados móveis do celular
        configuration.allowsCellularAccess = false
        //Timeou em segundos
        configuration.timeoutIntervalForRequest = 60
        configuration.httpAdditionalHeaders = ["Content-Type": "application/json"]
        configuration.httpMaximumConnectionsPerHost = 5
        
        return configuration
    }()
    private lazy var session = URLSession(configuration: configuration)
    
    //@escaping, retem o parametro para que ele nao seja desalocado ao final do metodo
    func loadCars(onComplete: @escaping (Result<[Car],APIError >) -> Void) {
        guard let url = URL(string: basePath) else {
            onComplete(.failure(.badURL))
            return
        }
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if let _ = error {
                onComplete(.failure(.taskError))
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                onComplete(.failure(.noResponse))
                return
            }
            
            if !(200...299 ~= response.statusCode) {
                onComplete(.failure(.invalidStatusCpde(response.statusCode)))
                return //print("Status code inválido:", response.statusCode)
            }
            
            guard let data = data else {
                onComplete(.failure(.noData))
                return// print("Sem dados!!!")
            }
            
            do {
                let cars = try JSONDecoder().decode([Car].self, from: data)
                onComplete(.success(cars))
                //print("Você tem um total de \(cars.count) carros")
            } catch {
                onComplete(.failure(.decodeError))
                //print(error)
            }
        }
        task.resume()
    }
    
    func deleteCar(_ car: Car, onComplete: @escaping (Result<Void, APIError>) -> Void){
        request("DELETE", car: car, onComplete: onComplete)
    }
    
    func updateCar(_ car: Car, onComplete: @escaping (Result<Void, APIError>) -> Void){
        request("PUT", car: car, onComplete: onComplete)
    }
    
    func createCar(_ car: Car, onComplete: @escaping (Result<Void, APIError>) -> Void){
        request("POST", car: car, onComplete: onComplete)
    }
    
    private func request(_ httpMethod: String, car: Car, onComplete: @escaping (Result<Void, APIError>) -> Void){
        let urlString = basePath + "/" + (car._id ?? "")
        let url = URL(string: urlString)!
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpBody = try? JSONEncoder().encode(car)
        urlRequest.httpMethod = httpMethod
        
        session.dataTask(with: urlRequest) {(data, _, _) in
            if data == nil{
                onComplete(.failure(.taskError))
            } else {
                onComplete(.success(()))
            }
        }.resume()
    }
}

