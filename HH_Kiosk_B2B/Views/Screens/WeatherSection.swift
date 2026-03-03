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
            WeatherContentView(viewModel: viewModel)
        }
    }
}

private struct WeatherContentView: View {
    @ObservedObject var viewModel: WeatherViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Current Weather")
                    .font(.headline)
                    .foregroundColor(Color(AppColors.primaryText))
                Spacer()
            }
            WeatherCard(viewModel: viewModel)
        }
        .padding()
        .background(Color(AppColors.backgroundSecondary))
        .cornerRadius(12)
        .shadow(radius: 4)
        .padding([.leading, .trailing])
    }
}

private struct WeatherCard: View {
    @ObservedObject var viewModel: WeatherViewModel
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: weatherIconName(for: viewModel.weatherCondition))
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(Color(AppColors.accent))
            
            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.weatherDescription.capitalized)
                    .font(.title3)
                    .foregroundColor(Color(AppColors.primaryText))
                
                HStack {
                    Text("\(Int(viewModel.temperature))°C")
                        .font(.largeTitle)
                        .bold()
                    
                    Text("\(celsiusToFahrenheit(viewModel.temperature))°F")
                        .font(.title3)
                        .foregroundColor(Color(AppColors.secondaryText))
                }
                
                Text("Humidity: \(viewModel.humidity)%")
                    .font(.subheadline)
                    .foregroundColor(Color(AppColors.secondaryText))
                
                Text("Wind: \(viewModel.windSpeed, specifier: "%.1f") km/h")
                    .font(.subheadline)
                    .foregroundColor(Color(AppColors.secondaryText))
            }
            Spacer()
        }
        .padding()
        .background(Color(AppColors.background))
        .cornerRadius(10)
    }
}

fileprivate func celsiusToFahrenheit(_ celsius: Double) -> Int {
    return Int((celsius * 9/5) + 32)
}

fileprivate func weatherIconName(for condition: String) -> String {
    switch condition.lowercased() {
    case "clear":
        return "sun.max.fill"
    case "clouds":
        return "cloud.fill"
    case "rain":
        return "cloud.rain.fill"
    case "snow":
        return "snow"
    case "thunderstorm":
        return "cloud.bolt.fill"
    case "drizzle":
        return "cloud.drizzle.fill"
    case "fog", "mist", "haze":
        return "cloud.fog.fill"
    default:
        return "questionmark"
    }
}
