//
//  BrowsePhotoAlbumsSection.swift
//  HH_Kiosk_B2B
//
//  Created by Applite Solutions on 03/03/26.
//
import SwiftUI

struct BrowsePhotoAlbumsSection: View {
    @State private var selectedAlbum: Album? = nil
    @StateObject private var viewModel = AlbumViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            header
            content
        }
        .onAppear {
            viewModel.loadAlbums()
        }
    }
    
    
    private var header: some View {
        HStack {
            buildSemiBoldText("Browse Photo Albums >", 40.sp)
                .padding(.horizontal, 24.w)
                        
            Spacer()
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
            
        case .idle, .loading:
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 24.w) {
                    ForEach(0..<3) { _ in
                        AlbumSkeletonCard()
                    }
                }
                .padding(.horizontal)
            }
            
        case .success(let albums):
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 24.w) {
                    ForEach(albums) { album in
                        
                        NavigationLink(destination: AlbumGalleryScreen(album: album)) {
                            AlbumCardView(album: album)
                        }
                        .buttonStyle(.plain)
                        
                    }
                }
                .padding(.horizontal)
            }
        case .failure(let message):
            Text(message)
                .foregroundColor(.red)
                .padding()
        }
    }
}

