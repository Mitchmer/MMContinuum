//
//  SearchableRecord.swift
//  MMContinuum
//
//  Created by Mitch Merrell on 8/28/19.
//  Copyright © 2019 Mitch Merrell. All rights reserved.
//

import Foundation

protocol SearchableRecord {
    func matches(searchTerm: String) -> Bool
}
