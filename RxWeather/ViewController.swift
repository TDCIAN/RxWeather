//
//  ViewController.swift
//  RxWeather
//
//  Created by JeongminKim on 2022/05/04.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var cityNameTextField: UITextField!
    @IBOutlet weak var temparatureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.cityNameTextField.rx.controlEvent(.editingDidEndOnExit)
            .asObservable()
            .map { self.cityNameTextField.text }
            .subscribe(onNext: { city in
                if let city = city {
                    if city.isEmpty {
                        self.displayWeather(nil)
                    } else {
                        self.fetchWeather(by: city)
                    }
                }
            }).disposed(by: disposeBag)
    }
    
    private func fetchWeather(by city: String) {
        guard let cityEncoded = city.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
              let url = URL.urlForWeatherAPI(city: cityEncoded) else { return }
        
        let resource = Resource<WeatherResult>(url: url)
        
        let search = URLRequest.load(resource: resource)
            .observe(on: MainScheduler.instance)
            .retry(3)
            .catch { error in
                print("뷰컨트롤러 - 캐치 에러: \(error)")
                return Observable.just(WeatherResult.empty)
            }.asDriver(onErrorJustReturn: WeatherResult.empty)
        
//        let search = URLRequest.load(resource: resource)
//            .observe(on: MainScheduler.instance)
//            .asDriver(onErrorJustReturn: WeatherResult.empty)
        
        search.map { weatherResult -> String in
            return "\(weatherResult.main.temp)℉"
        }
        .drive(self.temparatureLabel.rx.text)
        .disposed(by: disposeBag)
        
        search.map { weatherResult -> String in
            return "\(weatherResult.main.humidity)💦"
        }
        .drive(self.humidityLabel.rx.text)
        .disposed(by: disposeBag)
        
//        URLRequest.load(resource: resource)
//            .observe(on: MainScheduler.instance)
//            .catchAndReturn(WeatherResult.empty)
//            .subscribe(onNext: { result in
//                print("펫치웨더 리절트: \(result)")
//                let weather = result.main
//                self.displayWeather(weather)
//            }).disposed(by: disposeBag)
    }
    
    private func displayWeather(_ weather: Weather?) {
        if let weather = weather {
            self.temparatureLabel.text = "\(weather.temp)℉"
            self.humidityLabel.text = "\(weather.humidity)💦"
        } else {
            self.temparatureLabel.text = "🙈"
            self.humidityLabel.text = "∅"
        }
    }
}

