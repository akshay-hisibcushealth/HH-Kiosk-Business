import SwiftUI
import UIKit

@MainActor
class PDFGenerator {
    static func generatePDF(from view: some View, fileName: String) -> URL? {
        let renderer = ImageRenderer(content: view)
        
        // Set a standard A4 page size
        let pageWidth: CGFloat = 595.2 // A4 Width
        let pageHeight: CGFloat = 841.8 // A4 Height
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(fileName).pdf")
        
        renderer.render { size, context in
            var box = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
            
            guard let pdfContext = CGContext(tempURL as CFURL, mediaBox: &box, nil) else { return }
            
            // Calculate how many pages we need based on the SwiftUI view's intrinsic size
            let totalHeight = size.height
            let numberOfPages = Int(ceil(totalHeight / pageHeight))
            
            for pageIndex in 0..<numberOfPages {
                pdfContext.beginPage(mediaBox: &box)
                
                // Shift the context upward so the "current" section of the view 
                // aligns with the top of the current PDF page
                let translationY = CGFloat(pageIndex) * pageHeight
                pdfContext.translateBy(x: 0, y: -translationY)
                
                // Render the view into the context
                context(pdfContext)
                
                pdfContext.endPage()
            }
            
            pdfContext.closePDF()
        }
        
        return tempURL
    }
}