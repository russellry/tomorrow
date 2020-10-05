//
//  SKProduct+Localized.swift
//  tomorrow
//
//  Created by Russell Ong on 1/10/20.
//  Copyright © 2020 trillion.unicorn. All rights reserved.
//
import StoreKit

extension SKProduct {
    fileprivate static var formatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }

    var localizedPrice: String {
        if self.price == 0.00 {
            return "Get"
        } else {
            let formatter = SKProduct.formatter
            formatter.locale = self.priceLocale

            guard let formattedPrice = formatter.string(from: self.price) else {
                return "Unknown Price"
            }

            return formattedPrice
        }
    }
}
