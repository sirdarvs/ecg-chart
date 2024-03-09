//
//  ConvertPalTests.swift
//  ConvertPalTests
//
//  Created by Darvin Evidor on 2/9/24.
//

import XCTest
@testable import ConvertPal

class CurrencyViewModelTests: XCTestCase {
    
    var viewModel: CurrencyViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = CurrencyViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    func testFetchCurrencies() {
        let expectation = XCTestExpectation(description: "Fetching currencies")
        
        viewModel.fetchCurrencies()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { // Adjust the delay based on API response time
            XCTAssertGreaterThan(self.viewModel.currencies.count, 0)
            XCTAssertNotNil(self.viewModel.selectedCurrency)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10)
    }
    
    func testFetchExchangeRates() {
        let expectation = XCTestExpectation(description: "Fetching exchange rates")
        
        viewModel.fetchExchangeRates()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { // Adjust the delay based on API response time
            XCTAssertGreaterThan(self.viewModel.exchangeRates.count, 0)
            XCTAssertNotNil(self.viewModel.lastUpdateTime)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10)
    }
    
    func testUpdateExchangeRate() {
        viewModel.currencies = [Currency(code: "USD", name: "United States Dollar"), Currency(code: "EUR", name: "Euro")]
        viewModel.exchangeRates = ["USD": 1.0, "EUR": 0.85]
        viewModel.selectedCurrency = "USD"
        
        viewModel.updateExchangeRate()
        
        XCTAssertEqual(viewModel.exchangeRates["USD"], 1.0)
        XCTAssertEqual(viewModel.exchangeRates["EUR"], 0.85)
    }
    
    func testConvert() {
        viewModel.exchangeRates = ["USD": 1.0, "EUR": 0.85, "GBP": 0.75]
        
        let convertedAmount = viewModel.convert(amount: 100, fromCurrency: "USD", toCurrency: "EUR")
        
        XCTAssertEqual(convertedAmount, 85.0)
    }
    
    func testCountryEmoji() {
        let emoji = viewModel.countryEmoji(countryCode: "US")
        XCTAssertEqual(emoji, "🇺🇸")
    }
    
    func testFormatTime() {
        let components = DateComponents(year: 2022, month: 2, day: 9, hour: 15, minute: 30, second: 45)
        guard let testDate = Calendar.current.date(from: components) else {
            XCTFail("Failed to create test date")
            return
        }
        let formattedTime = viewModel.formatTime(lastUpdateTime: testDate)
        
        let expectedFormattedTime = "02/09/2022, 15:30:45"
        
        XCTAssertEqual(formattedTime, expectedFormattedTime)
    }
}
