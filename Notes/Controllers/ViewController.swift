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
        
        let search = UIBarButtonItem(barButtonSystemItem: .search,
                                     target: self,
                                     action: #selector(promptForSearch))
        
        let share = UIBarButtonItem(barButtonSystemItem: .action,
                                    target: self,
                                    action: #selector(shareSelection))
        
        self.navigationItem.leftBarButtonItems = [search, share]
    }

    func load(_ name: String){
    
        let filename = name.replacingOccurrences(of: " ", with: "_").lowercased()
        guard let path = Bundle.main.url(forResource: filename, withExtension: "pdf") else { return }
        
        if let document = PDFDocument(url: path){
        
            self.pdfView.document = document
            self.pdfView.goToFirstPage(nil)
            if UIDevice.current.userInterfaceIdiom == .pad {
                title = name
            }
        }
    }
    
    @objc func promptForSearch() {
        
        let alert = UIAlertController(title: "Search", message: nil, preferredStyle: .alert)
        alert.addTextField()
        
        alert.addAction(UIAlertAction(title: "Search", style: .default, handler: {
            (action) in
            guard let searchText = alert.textFields?[0].text else { return }
            
            guard let match = self.pdfView.document?.findString (
                searchText, fromSelection: self.pdfView.highlightedSelections?.first,
                withOptions: .caseInsensitive
                ) else { return }
            
            self.pdfView.go(to: match)
            self.pdfView.highlightedSelections = [match]
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    @objc func shareSelection(sender: UIBarButtonItem){
        
        guard let selection = self.pdfView.currentSelection?.attributedString else {
              let alert = UIAlertController(title: "Nothing is selected",
                                          message: "Select a fragment of the file to share",
                                          preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true)
            return
        }
        
        let activityVC = UIActivityViewController(activityItems: [selection], applicationActivities: nil)
        activityVC.popoverPresentationController?.barButtonItem = sender
        
        present(activityVC, animated: true)
    }
}

