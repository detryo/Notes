//
//  ViewController.swift
//  Notes
//
//  Created by Cristian Sedano Arenas on 21/10/18.
//  Copyright © 2018 Cristian Sedano Arenas. All rights reserved.
//

import UIKit
import PDFKit

class ViewController: UIViewController {
    
    let pdfView = PDFView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pdfView)
        
        pdfView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        pdfView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        pdfView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        pdfView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    func load(_ filename: String){
        print(filename)
    }

}

