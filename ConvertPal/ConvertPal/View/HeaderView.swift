//
//  HeaderView.swift
//  ConvertPal
//
//  Created by Darvin Evidor on 2/10/24.
//

import SwiftUI

struct HeaderView: View {
    @ObservedObject var viewModel: CurrencyViewModel

    var body: some View {
        HStack {
            Button {
                viewModel.fetchExchangeRates(isTappedRefresh: true)
            } label: {
                Label("",
                      systemImage: "arrow.clockwise.circle")
                    .font(.title)
            }
            .padding()

            Text("Last update:")
                .accessibilityLabel("Last update: \(viewModel.formatTime(lastUpdateTime: viewModel.lastUpdateTime))")

            Text("\(viewModel.formatTime(lastUpdateTime: viewModel.lastUpdateTime))")
                .padding()
        }
    }
}
