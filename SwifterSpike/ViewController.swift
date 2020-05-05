//
//  ViewController.swift
//  SwifterSpike
//
//  Created by Corbin Montague on 5/5/20.
//  Copyright © 2020 Corbin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private lazy var getButton: UIButton = {
        let button = UIButton()
        button.setTitle("Send GET", for: .normal)
        button.backgroundColor = .gray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var postButton: UIButton = {
        let button = UIButton()
        button.setTitle("Send POST", for: .normal)
        button.backgroundColor = .gray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    // MARK: - View Setup
    
    private func setupView() {
        addSubviews()
        setupConstraints()
        setupActions()
    }
    
    private func addSubviews() {
        view.addSubview(getButton)
        view.addSubview(postButton)
    }
    
    private func setupConstraints() {
        let constraints: [NSLayoutConstraint] = [
            getButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            getButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            postButton.topAnchor.constraint(equalTo: getButton.bottomAnchor, constant: 12),
            postButton.centerXAnchor.constraint(equalTo: getButton.centerXAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: - Actions
    
    private func setupActions() {
        getButton.addTarget(self, action: #selector(getButtonTapped), for: .touchDown)
        postButton.addTarget(self, action: #selector(postButtonTapped), for: .touchDown)
    }
    
    @objc private func getButtonTapped() {
        print("getButtonTapped")
        
        // Create URL
        var url: URL?
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
            appDelegate.isUITesting {
            url = URL(string: "https://localhost:8080/todos/1")
        } else {
            url = URL(string: "https://jsonplaceholder.typicode.com/todos/1")
        }
        guard let requestUrl = url else { fatalError() }
        
        // Create URLRequest
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "GET"
        
        // Send HTTP Request
        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            DispatchQueue.main.async {
                
                // Check for Error
                if let error = error {
                    print("Error took place \(error)")
                    self?.getButton.setTitle("GET Request Failed: \(error.localizedDescription)", for: .normal)
                    return
                }
                
                // Check for Data
                guard let data = data, let dataString = String(data: data, encoding: .utf8) else {
                    self?.getButton.setTitle("GET Request Failed: No Data", for: .normal)
                    return
                }
                
                // Parse the JSON
                print("Response data string:\n \(dataString)")
                guard let todoItem = self?.parseJSON(data: data) else {
                    self?.getButton.setTitle("GET Request Failed: Bad JSON", for: .normal)
                    return
                }
                self?.getButton.setTitle(todoItem.title, for: .normal)
            }
        }
        task.resume()
    }
    
    @objc private func postButtonTapped() {
        print("postButtonTapped")
        
        // Create URL
        var url: URL?
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
            appDelegate.isUITesting {
            url = URL(string: "https://localhost:8080/todos")
        } else {
            url = URL(string: "https://jsonplaceholder.typicode.com/todos")
        }
        guard let requestUrl = url else { fatalError() }
        
        // Create URLRequest
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        request.httpBody = "userId=300&title=My urgent task&completed=false".data(using: String.Encoding.utf8);
        
        // Send HTTP Request
        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            DispatchQueue.main.async {
                // Check for Error
                if let error = error {
                    print("Error took place \(error)")
                    self?.postButton.setTitle("POST Request Failed", for: .normal)
                    return
                }
                
                // Convert HTTP Response Data to a String
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    print("Response data string:\n \(dataString)")
                    self?.postButton.setTitle("POST Request Succeeded", for: .normal)
                }
            }
        }
        task.resume()
    }
    
    private func parseJSON(data: Data) -> ToDoResponseModel? {
        
        var returnValue: ToDoResponseModel?
        do {
            returnValue = try JSONDecoder().decode(ToDoResponseModel.self, from: data)
        } catch {
            print("Error: \(error.localizedDescription).")
        }
        
        return returnValue
    }
}
