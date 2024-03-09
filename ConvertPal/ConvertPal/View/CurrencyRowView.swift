//
//  CurrencyRowView.swift
//  ConvertPal
//
//  Created by Darvin Evidor on 2/10/24.
//

import SwiftUI

struct CurrencyRowView: View {
    @ObservedObject var viewModel: CurrencyViewModel

    var currency: Currency
    var convertedAmount: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(currency.code)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Color(UIColor.label))

                Spacer()
                Text("\(viewModel.countryEmoji(countryCode: currency.code))")
                    .font(.largeTitle)
            }

            Text("\(currency.name)")
                .font(.caption)
                .multilineTextAlignment(.leading)
                .foregroundColor(Color(UIColor.secondaryLabel))

            if let doubleAmount = Double(convertedAmount) {
                Text("\(viewModel.getCurrencySymbol(for: currency.code) ?? "") \(viewModel.formatAmount(doubleAmount))")
                    .font(.body)
                    .foregroundColor(Color(UIColor.label))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.gray.opacity(0.4), radius: 4, x: 0, y: 2)
    }
}
