//
//  URL+Extensions.swift
//  RxWeather
//
//  Created by JeongminKim on 2022/05/04.
//

import Foundation

extension URL {
    static func urlForWeatherAPI(city: String) -> URL? {
        return URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=d97a141fbe206743133efac99624b767&units=imperial")
    }
}
