func weatherIconName(for condition: String) -> String {
    switch condition.lowercased() {
    case "clear":
        return AppIconNames.Asset.sun
    case "clouds":
        return AppIconNames.Asset.clouds
    case "rain":
        return AppIconNames.Asset.rain
    case "snow":
        return AppIconNames.Asset.snow
    default:
        return AppIconNames.Asset.sun
    }
}


func celsiusToFahrenheit(_ celsius: Int) -> Int {
   let temp = (Double(celsius) * 9/5) + 32
    return Int(temp)
}
