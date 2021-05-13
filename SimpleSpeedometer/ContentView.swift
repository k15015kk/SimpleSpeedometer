//
//  ContentView.swift
//  SimpleSpeedometer
//
//  Created by 井上晴稀 on 2021/05/04.
//

import SwiftUI
import MapKit

struct ContentView: View {
    let font = Font.custom("HiraginoSans-W3",size: 18)
    @State var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 35.681111, longitude: 139.766667),
            latitudinalMeters: 300,longitudinalMeters: 300)
    // 速度を表示するためにLocationHelperクラスを宣言
    @ObservedObject var lh = LocationHelper(start: true)
    
    var body: some View {
        VStack(alignment: .center, spacing: 8){
            HStack(){
                Text("ただいまの速度")
                    .fontWeight(.bold)
                    .font(.custom("HiraginoSans-W3", size: 24))
                Spacer()
            }.padding(.top, 32)
            HStack(alignment: .bottom){
                Spacer()
                Text("\(lh.display_speed)")
                    .fontWeight(.bold)
                    .font(.custom("Futura", size: 96))
                Text("km/h")
                    .fontWeight(.bold)
                    .font(.custom("Futura", size: 24))
                    .offset(y: -16)
            }
            HStack{
                Spacer()
                Text("GPS誤差半径")
                    .font(font)
                Text("\(lh.accuracy)m")
                    .fontWeight(.bold)
                    .frame(width:96, height:36, alignment: .trailing)
                    .font(.custom("Futura", size: 24))
            }.padding(.vertical, 8)
            Spacer()
            HStack {
                Map(coordinateRegion: $region, interactionModes: .all, showsUserLocation: true, userTrackingMode: .constant(.follow))
            }
        }
        .padding(.horizontal ,16)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
