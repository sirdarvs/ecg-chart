//
//  CurrencyViewModel.swift
//  ConvertPal
//
//  Created by Darvin Evidor on 2/9/24.
//

import Foundation

class CurrencyViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var currencies: [Currency] = []
    @Published var selectedCurrency: String = "USD"
    @Published var currencyAmount: String? = nil
    @Published var exchangeRates: [String: Double] = [:]
    @Published var lastUpdateTime = Date()
    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    
    // MARK: - Initializer
    init() {
        fetchCurrencies()
        fetchExchangeRates()
    }
    
    // MARK: - Data Fetching
    
    // Fetch available currencies from the Open Exchange Rates API
    func fetchCurrencies() {
        guard let url = URL(string: "https://openexchangerates.org/api/currencies.json") else {
            showAlert(title: "Invalid URL", message: "Invalid URL for currencies API.")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error as? URLError, error.code == .notConnectedToInternet {
                self.showAlert(title: "No Internet connection", message: "No internet connection. Please check your network settings.")
                return
            }
            
            if let data = data {
                do {
                    let decodedData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String]
                    let currencyArray = decodedData?.map { Currency(code: $0.key, name: $0.value) } ?? []
                    
                    DispatchQueue.main.async {
                        self.currencies = currencyArray.sorted { $0.name < $1.name }
                        self.selectedCurrency = self.currencies.first?.code ?? ""
                    }
                } catch {
                    print("Error decoding currency data: \(error)")
                    self.showAlert(title: "Error decoding", message: "Error decoding currency data.")
                }
            }
        }.resume()
    }
    
    // Fetch exchange rates from the Open Exchange Rates API and handle caching
    func fetchExchangeRates(isTappedRefresh: Bool = false) {
        let cacheKey = "exchangeRatesCache"
        
        // Check if data is cached and not expired
        if let cachedData = UserDefaults.standard.data(forKey: cacheKey),
           let cachedTimestamp = UserDefaults.standard.value(forKey: "lastUpdateTimestamp") as? Date,
           Date().timeIntervalSince(cachedTimestamp) < 1800 { // 1800 seconds = 30 minutes
            if(isTappedRefresh) {
                showAlert(title: "Cannot be refreshed", message: "Exchange rates data is already the latest within the last 30 minutes.")
            }
            do {
                let cachedResult = try JSONDecoder().decode(ExchangeRateResponse.self, from: cachedData)
                DispatchQueue.main.async {
                    self.exchangeRates = cachedResult.rates
                    self.lastUpdateTime = cachedTimestamp
                }
                return
            } catch {
                print("Error decoding cached exchange rate data: \(error.localizedDescription)")
                showAlert(title: "Error decoding", message: "Error decoding exchange rate data.")
            }
        }
        
        guard let url = URL(string: "https://openexchangerates.org/api/latest.json?app_id=07b1814ec629403b9b396b9821fff67c") else {
            showAlert(title: "Invalid URL", message: "Invalid URL for exchange rates API.")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error as? URLError, error.code == .notConnectedToInternet {
                self.showAlert(title: "No Internet connection", message: "No internet connection. Please check your network settings.")
                return
            }
            
            if let data = data {
                do {
                    let result = try JSONDecoder().decode(ExchangeRateResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.exchangeRates = result.rates
                        self.lastUpdateTime = Date()
                    }
                    
                    if let encodedData = try? JSONEncoder().encode(result) {
                        UserDefaults.standard.set(encodedData, forKey: cacheKey)
                        UserDefaults.standard.set(Date(), forKey: "lastUpdateTimestamp")
                    }
                } catch {
                    print("Error decoding exchange rate data: \(error.localizedDescription)")
                    self.showAlert(title: "Error decoding", message: "Error decoding exchange rate data.")
                }
            }
        }.resume()
    }
    
    // MARK: - Exchange Rate Update
    
    // Update exchange rates based on the selected currency
    func updateExchangeRate() {
        guard !selectedCurrency.isEmpty else {
            return
        }
        
        guard let selectedRate = exchangeRates[selectedCurrency] else {
            print("Exchange rate not available for selected currency")
            return
        }
        
        DispatchQueue.main.async {
            self.exchangeRates = self.exchangeRates.mapValues { $0 * selectedRate }
            self.exchangeRates[self.selectedCurrency] = 1.0
        }
    }
    
    // MARK: - Currency Conversion
    
    // Convert amount from one currency to another
    func convert(amount: Double, fromCurrency: String, toCurrency: String) -> Double? {
        guard let fromRate = exchangeRates[fromCurrency], let toRate = exchangeRates[toCurrency] else {
            return nil
        }
        
        let amountInUSD = amount / fromRate
        let amountInToCurrency = amountInUSD * toRate
        return amountInToCurrency
    }
    
    // MARK: - Utility Functions
    
    // Get emoji corresponding to the country code
    func countryEmoji(countryCode: String) -> String {
        if countryCode == "BTC" {
            return "🇧 🇹 🇨"
        }
        
        var countryIndicator = countryCode
            .unicodeScalars
            .compactMap { UnicodeScalar(127397 + $0.value) }
            .map { String($0) }
            .joined()
        
        countryIndicator = countryIndicator
            .filter { !["🇦", "🇧", "🇨", "🇩", "🇪", "🇫", "🇬", "🇭", "🇮", "🇯", "🇰", "🇱", "🇲", "🇳", "🇴", "🇵", "🇶", "🇷", "🇸", "🇹", "🇺", "🇻", "🇼", "🇽", "🇾", "🇿"].contains(String($0)) }
        
        return countryIndicator
    }
    
    // Format the timestamp for display
    func formatTime(lastUpdateTime: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy, HH:mm:ss"
        return formatter.string(from: lastUpdateTime)
    }
    
    // Format amount for display
    func formatAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: amount)) ?? ""
    }
    
    // Get currency symbol based on currency code
    func getCurrencySymbol(for currencyCode: String) -> String? {
        let currencySymbols: [String: String] = [
            "AED": "د.إ",
            "AFN": "؋",
            "ALL": "L",
            "AMD": "֏",
            "ANG": "ƒ",
            "AOA": "Kz",
            "ARS": "$",
            "AUD": "$",
            "AWG": "ƒ",
            "AZN": "₼",
            "BAM": "KM",
            "BBD": "$",
            "BDT": "৳",
            "BGN": "лв",
            "BHD": "ب.د",
            "BIF": "FBu",
            "BMD": "$",
            "BND": "$",
            "BOB": "Bs.",
            "BRL": "R$",
            "BSD": "$",
            "BTC": "₿",
            "BTN": "Nu.",
            "BWP": "P",
            "BYN": "Br",
            "BZD": "BZ$",
            "CAD": "$",
            "CDF": "FC",
            "CHF": "CHF",
            "CLF": "UF",
            "CLP": "$",
            "CNH": "CNH",
            "CNY": "¥",
            "COP": "$",
            "CRC": "₡",
            "CUC": "CUC$",
            "CUP": "CUP$",
            "CVE": "$",
            "CZK": "Kč",
            "DJF": "Fdj",
            "DKK": "kr",
            "DOP": "RD$",
            "DZD": "د.ج",
            "EGP": "ج.م",
            "ERN": "Nfk",
            "ETB": "Br",
            "EUR": "€",
            "FJD": "$",
            "FKP": "£",
            "GBP": "£",
            "GEL": "₾",
            "GGP": "£",
            "GHS": "₵",
            "GIP": "£",
            "GMD": "D",
            "GNF": "FG",
            "GTQ": "Q",
            "GYD": "$",
            "HKD": "$",
            "HNL": "L",
            "HRK": "kn",
            "HTG": "G",
            "HUF": "Ft",
            "IDR": "Rp",
            "ILS": "₪",
            "IMP": "£",
            "INR": "₹",
            "IQD": "ع.د",
            "IRR": "﷼",
            "ISK": "kr",
            "JEP": "£",
            "JMD": "$",
            "JOD": "د.ا",
            "JPY": "¥",
            "KES": "Ksh",
            "KGS": "сом",
            "KHR": "៛",
            "KMF": "CF",
            "KPW": "₩",
            "KRW": "₩",
            "KWD": "د.ك",
            "KYD": "$",
            "KZT": "₸",
            "LAK": "₭",
            "LBP": "ل.ل",
            "LKR": "₨",
            "LRD": "$",
            "LSL": "L",
            "LYD": "ل.د",
            "MAD": "د.م.",
            "MDL": "L",
            "MGA": "Ar",
            "MKD": "ден",
            "MMK": "K",
            "MNT": "₮",
            "MOP": "P",
            "MRU": "UM",
            "MUR": "₨",
            "MVR": "ރ",
            "MWK": "MK",
            "MXN": "$",
            "MYR": "RM",
            "MZN": "MT",
            "NAD": "$",
            "NGN": "₦",
            "NIO": "C$",
            "NOK": "kr",
            "NPR": "₨",
            "NZD": "$",
            "OMR": "﷼",
            "PAB": "B/.",
            "PEN": "S/",
            "PGK": "K",
            "PHP": "₱",
            "PKR": "₨",
            "PLN": "zł",
            "PYG": "₲",
            "QAR": "ر.ق",
            "RON": "lei",
            "RSD": "din.",
            "RUB": "₽",
            "RWF": "RF",
            "SAR": "﷼",
            "SBD": "$",
            "SCR": "₨",
            "SDG": "ج.س.",
            "SEK": "kr",
            "SGD": "$",
            "SHP": "£",
            "SLL": "Le",
            "SOS": "Sh",
            "SRD": "$",
            "SSP": "£",
            "STD": "Db",
            "STN": "Db",
            "SVC": "$",
            "SYP": "£",
            "SZL": "L",
            "THB": "฿",
            "TJS": "ЅМ",
            "TMT": "T",
            "TND": "د.ت",
            "TOP": "T$",
            "TRY": "₺",
            "TTD": "TT$",
            "TWD": "NT$",
            "TZS": "TSh",
            "UAH": "₴",
            "UGX": "USh",
            "USD": "$",
            "UYU": "$U",
            "UZS": "UZS",
            "VEF": "Bs.F.",
            "VES": "Bs.S.",
            "VND": "₫",
            "VUV": "Vt",
            "WST": "WS$",
            "XAF": "FCFA",
            "XAG": "XAG",
            "XAU": "XAU",
            "XCD": "$",
            "XDR": "SDR",
            "XOF": "CFA",
            "XPD": "XPD",
            "XPF": "CFP",
            "XPT": "XPT",
            "YER": "﷼",
            "ZAR": "R",
            "ZMW": "ZK",
            "ZWL": "Z$"
        ]
        
        return currencySymbols[currencyCode.uppercased()]
    }
    
    // Function to display alerts
    func showAlert(title: String = "Alert", message: String) {
        DispatchQueue.main.async {
            self.alertTitle = title
            self.alertMessage = message
            self.showAlert = true
        }
    }
}
