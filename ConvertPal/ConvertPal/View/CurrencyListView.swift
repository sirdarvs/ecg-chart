//
//  CurrencyListView.swift
//  ConvertPal
//
//  Created by Darvin Evidor on 2/10/24.
//

import SwiftUI

struct CurrencyListView: View {
    @ObservedObject var viewModel: CurrencyViewModel
    @Binding var convertedAmounts: [String: String]

    var body: some View {
        NavigationView {
            List {
                ForEach(sortedCurrencies, id: \.key) { key, currencies in
                    Section(header: Text(key)) {
                        ForEach(currencies, id: \.code) { currency in
                            CurrencyRowView(viewModel: viewModel, currency: currency, convertedAmount: convertedAmounts[currency.code] ?? "")
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .onAppear {
                    UITableView.appearance().sectionIndexBackgroundColor = .clear
                }
            }
        }
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .refreshable {
            viewModel.fetchExchangeRates(isTappedRefresh: true)
        }
    }

    private var sortedCurrencies: [(key: String, value: [Currency])] {
        return Dictionary(grouping: viewModel.currencies, by: { String($0.code.prefix(1)) })
            .sorted(by: { $0.key < $1.key })
    }
}
