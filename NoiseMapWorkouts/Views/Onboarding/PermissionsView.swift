//
//  PermissionsView.swift
//  WorkoutsNoise
//
//  Created by Merlin Chlosta on 19.05.23.
//

import SwiftUI
import HealthKit

struct PermissionsView: View {
    var body: some View {
        VStack {
            Text("permissions_title".localized())
                .fontWeight(.heavy)
                .font(.system(size: 36))
            
            VStack(alignment: .leading, spacing: 30) {
                Bullet(image: "square.3.layers.3d.down.backward", title: "permissions_title_1".localized(), text: "permissions_text_1".localized())
                Bullet(image: "moon.stars", title: "permissions_title_2".localized(), text: "permissions_text_2".localized())
            }.padding(.vertical)
        }
    }
}

struct PermissionsView_Previews: PreviewProvider {
    static var previews: some View {
        PermissionsView()
    }
}
