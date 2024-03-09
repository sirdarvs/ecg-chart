//
//  MainView.swift
//  ConvertPal
//
//  Created by Darvin Evidor on 2/9/24.
//

import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = CurrencyViewModel()
    @State private var currencyAmount: String = ""
    @State private var convertedAmounts: [String: String] = [:]
    
    var body: some View {
        VStack {
            HeaderView(viewModel: viewModel)
            CurrencySelectionView(viewModel: viewModel, currencyAmount: $currencyAmount, convertedAmounts: $convertedAmounts)
            CurrencyListView(viewModel: viewModel, convertedAmounts: $convertedAmounts)
        }
        .background(Color(UIColor.systemBackground))
//        .preferredColorScheme(.dark)
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text(viewModel.alertTitle),
                message: Text(viewModel.alertMessage),
                dismissButton: .default(Text("OK")) {
                    viewModel.showAlert = false
                }
            )
        }
        
    }
}

#Preview {
    MainView()
}
