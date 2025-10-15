import SwiftUI
import PDFKit

struct ReadPdfScreen: View {
    let docUrl: String
    @State private var isLoadingPDF = true
    @State private var pdfDocument: PDFDocument? = nil

    var body: some View {
        VStack(spacing: 0) {
            Toolbar()
            
            if let document = pdfDocument {
                PdfView(pdfDocument: document)
            } else if isLoadingPDF {
                VStack {
                    Spacer()
                    ProgressView("Loading PDF...")
                        .padding()
                    Spacer()
                }
            } else {
                VStack {
                    Spacer()
                    Text("Failed to load PDF")
                        .foregroundColor(.red)
                    Spacer()
                }
            }
        }
        .onAppear {
            loadPDF()
        }
    }

    private func loadPDF() {
        DispatchQueue.global(qos: .userInitiated).async {
            if let url = URL(string: docUrl), let document = PDFDocument(url: url) {
                DispatchQueue.main.async {
                    self.pdfDocument = document
                    self.isLoadingPDF = false
                }
            } else {
                DispatchQueue.main.async {
                    self.isLoadingPDF = false
                }
            }
        }
    }
}

struct PdfView: View {
    let pdfDocument: PDFDocument
    @State private var currentPageIndex: Int = 0

    var body: some View {
        VStack(spacing: 16) {
            PDFKitView(document: pdfDocument, pageIndex: currentPageIndex)
                .frame(height: .infinity)
                .cornerRadius(12)
                .padding(.top, 40)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(0..<pdfDocument.pageCount, id: \.self) { index in
                        if let page = pdfDocument.page(at: index) {
                            let thumbnail = page.thumbnail(of: CGSize(width: 60, height: 80), for: .mediaBox)
                            Image(uiImage: thumbnail)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 80)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(index == currentPageIndex ? Color.blue : Color.clear, lineWidth: 2)
                                )
                                .onTapGesture {
                                    currentPageIndex = index
                                }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct PDFKitView: UIViewRepresentable {
    let document: PDFDocument
    let pageIndex: Int

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = document
        pdfView.autoScales = true
        pdfView.displayMode = .singlePage
        pdfView.displayDirection = .horizontal
        pdfView.backgroundColor = .white
        pdfView.usePageViewController(true)
        return pdfView
    }

    func updateUIView(_ pdfView: PDFView, context: Context) {
        if let page = document.page(at: pageIndex) {
            pdfView.go(to: page)
        }
    }
}
