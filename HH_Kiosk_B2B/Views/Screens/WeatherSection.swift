import SwiftUI

struct WeatherSection: View {
    @ObservedObject var viewModel: WeatherViewModel
    
    var body: some View {
        if viewModel.isLoading {
            ProgressView("Loading Weather...")
                .progressViewStyle(CircularProgressViewStyle())
                .padding()
                .frame(maxWidth: .infinity, alignment: .top)
        } else if let error = viewModel.errorMessage {
            VStack {
                Text("Error:")
                Text(error).foregroundColor(Color(AppColors.error))
            }
            .frame(maxWidth: .infinity, alignment: .top)
        } else {
            WeatherCard(viewModel: viewModel)
        }
    }
}



private struct WeatherCard: View {
    @ObservedObject var viewModel: WeatherViewModel
    
    var body: some View {
        ZStack(alignment: .leading) {
            HStack {
                Image(weatherIconName(for: viewModel.condition))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 175.w,height: 160.w)
                    .padding(.trailing, 15.w)
                
                VStack(alignment: .trailing) {
                    buildSemiBoldText("\(celsiusToFahrenheit(viewModel.currentTemp))°F",64.sp,color: Color(AppColors.black))
                    
                    Text(viewModel.condition.uppercased())
                        .font(.system(size: 20.sp, weight: .semibold))
                        .foregroundColor(Color(AppColors.black))
                    
                
                }
                Spacer()
                         }
            .padding(.leading, 72.w)
            .padding(.vertical,32.h)
        }
    }
}

fileprivate func celsiusToFahrenheit(_ celsius: Double) -> Int {
    return Int((celsius * 9/5) + 32)
}

