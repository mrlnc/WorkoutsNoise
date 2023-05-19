//
//  AboutTab.swift
//  WorkoutsNoise
//
//  Created by Merlin Chlosta on 22.06.23.
//

import SwiftUI

struct AboutTab: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                Bullet(image: "pencil.and.outline", title: "What's this app about?", text: "I wanted to understand where I encounter noise pollution like traffic noise. Apple Watch tells me when my environment was loud. But where was I at that time? That's what the app tells you.")
                Bullet(image: "brain.head.profile", title: "Are the readings accurate?", text: "It depends. The noise readings itself are accurate, according to a 2022 study:")
                Image("fneur-13-856219-g004")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.horizontal)
                Text("Source: Are Smartwatches a Suitable Tool to Monitor Noise Exposure for Public Health Awareness and Otoprotection?, T. Fischer, S. Schraivogel, M. Caversaccio, W. Wimmer, 2022, Frontiers in Neurology, cc-by 4.0").italic().font(.footnote).padding(.horizontal)
                
                Bullet(image: "skew", title: "However…", text: "Percieved sound levels depend on proximity to the source. While cycling is quiet in general, Apple Watch is extremely close e.g. only centimeters from your bell. That leads to high noise readings. I found airstream also makes a big source of high noise readings.")
                
                Bullet(image: "skew", title: "Open Source", text: "Check out the source code and submit PRs on Github :)")

            }.padding(.vertical)
        }
    }
}

struct AboutTab_Previews: PreviewProvider {
    static var previews: some View {
        AboutTab()
    }
}
