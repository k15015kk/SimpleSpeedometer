//
//  LocationHelper.swift
//  SimpleSpeedometer
//
//  Created by 井上晴稀 on 2021/05/05.
//

import Foundation
import CoreLocation
import Combine

class LocationHelper: NSObject, ObservableObject {
    let locationManager = CLLocationManager()
    
    var location :CLLocation?
    var statues :CLAuthorizationStatus?
    
    var lon :Double = 0.0
    var lat :Double = 0.0
    
    var location_count :Int = 0
    
    // Effect用のタイマー
    var timer: Timer = Timer()
    
    @Published var display_speed :Int = 0
    @Published var accuracy :Int = 0
    
    init(start: Bool) {
        
        // 継承元の初期関数実行
        super.init()
        
        // デリゲート設定
        self.locationManager.delegate = self

        // 位置情報の権限をリクエストする
        self.locationManager.requestAlwaysAuthorization()

        // 位置情報データの受信精度
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.distanceFilter = kCLDistanceFilterNone
//
//        // バックグラウンドでも位置情報を取得する設定
//        self.locationManager.allowsBackgroundLocationUpdates = true
//
        // バッテリー制御とアクティビティタイプの定義
        self.locationManager.pausesLocationUpdatesAutomatically = false
        self.locationManager.activityType = .otherNavigation
        
        if start {
            locationStart()
        }
    }
    
}

extension LocationHelper: CLLocationManagerDelegate {
    
    // 位置情報の権限
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        self.statues = status
        
        // Locationのステータス確認用
        switch status {
            
        case .notDetermined :
            print("notDetermined")
        case .authorizedWhenInUse :
            print("authorizedWhenInUse")
        case .authorizedAlways :
            print("authorizedAlways")
        case .restricted :
            print("resetriected")
        case .denied :
            print("denied")
        default :
            print("unknown")
        }
    }
    
    // 位置情報の更新があったら動く関数
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // 残っているタイマーを破棄する
        timer.invalidate()
        
        // 最初の5ポイントは捨てる
        if self.location_count > 5 {
            // 位置情報の様々な情報が格納されているlocationを格納
            guard let location = locations.last else {return}
            self.location = location
            
            // デバッグ用に出力
            print(location)
            
            // lon/latデータを格納
            self.lon = location.coordinate.longitude
            self.lat = location.coordinate.latitude
            let speed = location.speed * 3.6
            
            // 速度を格納する
            if speed < 0 {
                speedEffect(maxSpeed: 0.0)
            } else if speed >= 1000 {
                speedEffect(maxSpeed: 999.9)
            } else {
                speedEffect(maxSpeed: speed)
            }
            
            //誤差半径を格納する
            if location.horizontalAccuracy < 0{
                self.accuracy = 9999
            } else if location.horizontalAccuracy >= 10000 {
                self.accuracy = 9999
            } else {
                self.accuracy = Int(location.horizontalAccuracy)
            }
        }

        self.location_count = self.location_count + 1

    }
    
    func speedEffect(maxSpeed: Double){
        let max = Int(maxSpeed)
        
        let diff = abs(max - self.display_speed)
        
        if diff == 0 {
            self.display_speed = max
        } else {
            let interval :Double = 1.0 / Double(diff)
            
            //timer処理
            timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: { (timer) in
                if max > self.display_speed {
                    self.display_speed = self.display_speed + 1
                } else if max < self.display_speed {
                    self.display_speed = self.display_speed - 1
                } else {
                    self.display_speed = self.display_speed
                }
                
                // 一応ここでタイマーを捨てる処理をしているが，ちゃんと動作するかどうか不明
                if max == self.display_speed {
                    timer.invalidate()
                }
                
            })
        }
    }
    
    func locationStart() {
        // 位置情報を取ってくる
        self.locationManager.startUpdatingLocation()
    }
    
    func locationStop() {
        // 位置情報を止める
        self.locationManager.stopUpdatingLocation()
        self.location_count = 0
    }
    
}
