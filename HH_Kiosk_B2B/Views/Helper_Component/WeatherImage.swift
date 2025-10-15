func weatherIconName(for condition: String) -> String {
    switch condition.lowercased() {
    case "clear":
        return "sun"          // e.g. sunny.png
    case "clouds":
        return "clouds"         // cloudy.png
    case "rain":
        return "rain"           // rain.png
    case "snow":
        return "snow"           // snow.png
    default:
        return "sun"        // fallback.png
    }
}


func celsiusToFahrenheit(_ celsius: Int) -> Int {
   let temp = (Double(celsius) * 9/5) + 32
    return Int(temp)
}
