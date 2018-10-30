//
//  ViewController.swift
//  Notes
//
//  Created by Cristian Sedano Arenas on 21/10/18.
//  Copyright © 2018 Cristian Sedano Arenas. All rights reserved.
//

import UIKit
import PDFKit
import SafariServices

class ViewController: UIViewController, PDFViewDelegate {
    
    let pdfView = PDFView()
    let textView = UITextView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pdfView)
        
        pdfView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        pdfView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        pdfView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        pdfView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)
        
        textView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        textView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        textView.isEditable = false
        textView.isHidden = true
        textView.textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        let search = UIBarButtonItem(barButtonSystemItem: .search,
                                     target: self,
                                     action: #selector(promptForSearch))
        
        let share = UIBarButtonItem(barButtonSystemItem: .action,
                                    target: self,
                                    action: #selector(shareSelection))
        
        let previus = UIBarButtonItem(barButtonSystemItem: .rewind,
                                      target: self.pdfView,
                                      action: #selector(PDFView.goToPreviousPage(_:)))
        
        let next = UIBarButtonItem(barButtonSystemItem: .fastForward,
                                   target: self.pdfView,
                                   action: #selector(PDFView.goToNextPage(_:)))
        
        self.navigationItem.leftBarButtonItems = [search, share, previus, next]
        self.pdfView.autoScales = true
        self.pdfView.delegate = self
        
        let pdfMode = UISegmentedControl(items: ["PDF", "Only Text"])
        pdfMode.addTarget(self, action: #selector(changePDFMode), for: .valueChanged)
        pdfMode.selectedSegmentIndex = 0
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: pdfMode)
        self.navigationItem.rightBarButtonItem?.width = 160
    }

    func load(_ name: String){
    
        let filename = name.replacingOccurrences(of: " ", with: "_").lowercased()
        guard let path = Bundle.main.url(forResource: filename, withExtension: "pdf") else { return }
        
        if let document = PDFDocument(url: path){
        
            self.pdfView.document = document
            self.pdfView.goToFirstPage(nil)
            self.readText()
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
    
    func pdfViewWillClick(onLink sender: PDFView, with url: URL) {
        
        let viewController = SFSafariViewController(url: url)
        viewController.modalPresentationStyle = .formSheet
        present(viewController, animated: true)
    }
    
    @objc func changePDFMode(segmentedControl: UISegmentedControl){
        
        if segmentedControl.selectedSegmentIndex == 0 {
            // Mostrar PDF
            pdfView.isHidden = false
            textView.isHidden = true
        } else {
            // Mostrar Texto
            pdfView.isHidden = true
            textView.isHidden = false
        }
    }
    
    func readText() {
        
        guard let pageCount = self.pdfView.document?.pageCount else { return }
        
        let pdfContent = NSMutableAttributedString()
        
        let space = NSAttributedString(string: "\n\n\n")
        
        for i in 1..<pageCount {
            guard let page = self.pdfView.document?.page(at: i) else { continue }
            guard let pageContent = page.attributedString else { continue }
            
            pdfContent.append(space)
            pdfContent.append(pageContent)
        }
        
        self.textView.attributedText = pdfContent
    }
}

