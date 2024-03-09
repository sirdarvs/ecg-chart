//
//  ExchangeRateResponse.swift
//  ConvertPal
//
//  Created by Darvin Evidor on 2/9/24.
//

struct ExchangeRateResponse: Decodable, Encodable {
    let rates: [String: Double]
}
