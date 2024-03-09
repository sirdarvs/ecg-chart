//
//  Currency.swift
//  ConvertPal
//
//  Created by Darvin Evidor on 2/9/24.
//

import Foundation

struct Currency: Identifiable, Hashable {
    let id = UUID()
    let code: String
    let name: String
}
