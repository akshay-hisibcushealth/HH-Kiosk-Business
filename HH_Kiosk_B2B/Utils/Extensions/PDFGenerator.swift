import SwiftUI

@MainActor
struct PDFGenerator {
    static func generatePDF<Content: View>(view: Content, fileName: String) -> URL? {
        let directory = FileManager.default.temporaryDirectory
        let url = directory.appendingPathComponent("\(fileName).pdf")
        
        let pageWidth: CGFloat = 595.2
        let pageHeight: CGFloat = 841.8
        
        // 1. Wrap the view and propose a size to force layout expansion
        let renderer = ImageRenderer(content: view)
        renderer.proposedSize = ProposedViewSize(width: pageWidth, height: nil)
        renderer.scale = 2.0 // Higher quality for text
        
        // 2. FORCE RENDER: This is the secret to fixing blank PDFs.
        // Accessing uiImage forces SwiftUI to process the View tree and images.
        guard let uiImage = renderer.uiImage else {
            print("❌ PDF Error: View content could not be converted to image.")
            return nil
        }
        
        let contentSize = uiImage.size
        let totalPages = Int(ceil(contentSize.height / (pageHeight * 2.0))) // Adjust for scale 2.0
        
        var box = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        guard let consumer = CGDataConsumer(url: url as CFURL),
              let context = CGContext(consumer: consumer, mediaBox: &box, nil) else {
            return nil
        }
        
        for page in 0..<totalPages {
            context.beginPage(mediaBox: &box)
            
            // Shift the drawing area for each page
            // We use the pageHeight and account for the scale used in uiImage
            context.translateBy(x: 0, y: -CGFloat(page) * pageHeight)
            
            renderer.render { size, renderInContext in
                renderInContext(context)
            }
            context.endPage()
        }
        
        context.closePDF()
        print("✅ PDF successfully created at: \(url.path)")
        return url
    }
}
