//
//  WelcomeView.swift
//  WorkoutsNoise
//
//  Created by Merlin Chlosta on 19.05.23.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        VStack {
            Text("welcome_to".localized())
                .fontWeight(.heavy)
                .font(.system(size: 36))
            
            Text("WorkoutsNoise")
                .fontWeight(.heavy)
                .font(.system(size: 36))
                .gradientForeground(gradient: LinearGradient(gradient: .init(colors: Constants.defaultColors), startPoint: .bottomLeading, endPoint: .topTrailing))
                .gradientForeground(gradient: LinearGradient(gradient: .init(colors: Constants.defaultColors), startPoint: .topTrailing, endPoint: .topLeading))
            
            VStack(alignment: .leading, spacing: 30) {
                Bullet(image: "map", title: "welcome_bullet_1_title".localized(), text: "welcome_bullet_1_text".localized())
                Bullet(image: "applewatch.watchface", title: "welcome_bullet_2_title".localized(), text: "welcome_bullet_2_text".localized())
                Bullet(image: "figure.run", title: "welcome_bullet_3_title".localized(), text: "welcome_bullet_3_text".localized())
            }.padding(.vertical)
        }
    }
}

struct Bullet: View {
    var image: String
    var title: String
    var text: String
    
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: image)
                .font(.largeTitle)
                .frame(width: 50, height: 50)
                .gradientForeground(gradient: LinearGradient(gradient: .init(colors: Constants.defaultColors), startPoint: .bottomLeading, endPoint: .topTrailing))

            VStack(alignment: .leading) {
                Text(title).fontWeight(.bold)
                Text(text)
            }
        }.padding(.horizontal)
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
        WelcomeView().environment(\.locale, .init(identifier: "de"))
    }
}
