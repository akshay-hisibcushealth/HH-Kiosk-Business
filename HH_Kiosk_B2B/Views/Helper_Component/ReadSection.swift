import SwiftUI

struct ReadSection: View {
    @StateObject private var viewModel = DashboardViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                if viewModel.isLoading {
                    ProgressView(HomeScreenStrings.ReadSection.loading)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else if let error = viewModel.errorMessage {
                    Text("\(HomeScreenStrings.ReadSection.failedToLoadPrefix) \(error)")
                        .foregroundColor(Color(AppColors.error))
                        .padding()
                } else {
                    // Today’s Read
                    if let today = viewModel.todayRead {
                        TodayReadSection(today: today)
                    }
                    Spacer()
                    // HR Desk
                    if !viewModel.hrDeskItems.isEmpty {
                        HRDeskSection(items: viewModel.hrDeskItems)
                    }
                }
            }
            .frame(height: 650.h)
            .padding(.horizontal, 16.w)
        }
    }
}

private struct TodayReadSection: View {
    let today: TodayRead
    
    var body: some View {
        VStack {
            SectionHeader(title: HomeScreenStrings.ReadSection.todaysReadTitle, isLeading: false)
            NavigationLink(destination: ArticleScreen(imageUrl: today.image,description: today.description)) {
                HStack {
                    CachedAsyncImage(
                        url: URL(string: today.image),
                        width: 130.w,
                        height: 185.h,
                        cornerRadius: 12.r
                    ) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    }
                    .padding(.trailing, 12.w)
                    .padding(.bottom, 12.w)
                    
                    VStack(alignment: .leading, spacing: 8.h) {
                        HStack(spacing: 8.w) {
                            Image(AppIconNames.Asset.articleIcon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30.w, height: 30.h)
                            
                            Text(HomeScreenStrings.ReadSection.articleBadge)
                                .font(.system(size: 25.sp, weight: .medium))
                                .foregroundColor(Color(AppColors.warningText))
                        }
                        
                        Text(today.title)
                            .font(.system(size: 26.sp, weight: .medium))
                            .lineLimit(2)
                            .foregroundColor(Color(AppColors.bodyText))
                        
                        Text(today.read_time)
                            .font(.system(size: 18.sp, weight: .light))
                            .foregroundColor(Color(AppColors.gray))
                    }
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color(AppColors.overlayMint))
        .clipShape(RoundedRectangle(cornerRadius: 24.r))
    }
}

private struct HRDeskSection: View {
    let items: [HRDeskItem]
    
    var body: some View {
        VStack(alignment: .leading) {
            SectionHeader(title: HomeScreenStrings.ReadSection.hrDeskTitle, isLeading: false)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 24.w) {
                    ForEach(items) { item in
                        NavigationLink(destination: ReadPdfScreen(docUrl: item.doc)) {
                            VStack(alignment: .leading, spacing: 8.h) {
                                CachedAsyncImage(
                                    url: URL(string: item.image),
                                    width: 130.w,
                                    height: 185.h,
                                    cornerRadius: 12.r
                                ) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                }
                                .padding(.trailing, 12.w)
                                .padding(.bottom, 12.w)
                                Text(item.title)
                                    .font(.system(size: 22.sp, weight: .medium))
                                    .lineLimit(1)
                                    .foregroundColor(Color(AppColors.black))
                            }
                            .frame(width: 140.w)
                        }
                    }
                }
                .padding(.leading,24.h)
                .padding(.bottom, 12.w)
                
                
            }
        }
        .padding()
        .background(Color(AppColors.overlayMint))
        .clipShape(RoundedRectangle(cornerRadius: 24.r))
    }
}
