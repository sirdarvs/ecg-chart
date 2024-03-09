//
//  CurrencySelectionView.swift
//  ConvertPal
//
//  Created by Darvin Evidor on 2/10/24.
//

import SwiftUI
import Combine

struct CurrencySelectionView: View {
    @ObservedObject var viewModel: CurrencyViewModel
    @Binding var currencyAmount: String
    @Binding var convertedAmounts: [String: String]
    
    private let defaultAmountValue: Double = 0.0
    private let decimalFormat: String = "%.2f"

    var body: some View {
        HStack {
            Picker("Select a currency", selection: $viewModel.selectedCurrency) {
                ForEach(viewModel.currencies, id: \.code) { currency in
                    Text("\(viewModel.countryEmoji(countryCode: currency.code)) (\(currency.code))\n\(currency.name)")
                        .tag(currency.code)
                }
            }
            .onChange(of: viewModel.selectedCurrency) {
                viewModel.fetchExchangeRates()

                convertedAmounts = viewModel.currencies.reduce(into: [:]) { result, currency in
                    if let convertedAmount = viewModel.convert(amount: Double(currencyAmount) ?? 0.0, fromCurrency: viewModel.selectedCurrency, toCurrency: currency.code) {
                        result[currency.code] = String(format: decimalFormat, convertedAmount)
                    } else {
                        result[currency.code] = defaultAmountValue.description
                    }
                }
            }
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .labelsHidden()

            TextField("Enter amount", text: $currencyAmount)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
                .padding()
                .accessibility(label: Text("Enter the amount in the selected currency"))
                .onChange(of: currencyAmount, initial: true) { oldValue, newValue in
                    if newValue != oldValue {
                        viewModel.fetchExchangeRates()
                        convertedAmounts = viewModel.currencies.reduce(into: [:]) { result, currency in
                            if let convertedAmount = viewModel.convert(amount: Double(newValue) ?? 0.0, fromCurrency: viewModel.selectedCurrency, toCurrency: currency.code) {
                                result[currency.code] = String(format: decimalFormat, convertedAmount)
                            } else {
                                result[currency.code] = defaultAmountValue.description
                            }
                        }
                        
                        // Filter to not accept any letters from the text field
                        let filtered = newValue.filter { "0123456789".contains($0) }
                        if filtered != newValue {
                            self.currencyAmount = filtered
                        }
                    }
                }
                .onAppear {
                    UITextField.appearance().clearButtonMode = .whileEditing
                }
        }
    }
}
