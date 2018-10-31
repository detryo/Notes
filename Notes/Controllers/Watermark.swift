//
//  Watermark.swift
//  Notes
//
//  Created by Cristian Sedano Arenas on 31/10/18.
//  Copyright © 2018 Cristian Sedano Arenas. All rights reserved.
//

import UIKit
import PDFKit

class Watermark: PDFPage {

    override func draw(with box: PDFDisplayBox, to context: CGContext) {
        // Dibuja la pagina actual del PDF
        super .draw(with: box, to: context)
        
        // Crear la marca de agua
        let stringText : NSString = "Course sample"
        let attributes : [NSAttributedString.Key : Any] = [.foregroundColor: UIColor.red,
                                                           .font : UIFont.italicSystemFont(ofSize: 20)]
        
        let stringSize = stringText.size(withAttributes: attributes)
        
        UIGraphicsPushContext(context)
        context.saveGState()
        
        // Donde dibujar la marca de agua
        let pageBounds = bounds(for: box)
        context.translateBy(x: (pageBounds.size.width-stringSize.width)/2.0,
                            y: pageBounds.size.height)
        
        context.scaleBy(x: 1.0, y: -1.0)
        context.rotate(by: CGFloat(Double.pi / 4.0))
        
        stringText.draw(at: CGPoint(x: 50, y: 150),
                        withAttributes: attributes)
        context.restoreGState()
        UIGraphicsPopContext()
        
    }
    
}
