//
//  APIError.swift
//  Music App-Technical Test
//
//  Created by Sae Pasomba on 10/05/25.
//

import Foundation

enum APIError: Error {
    case invalidUrl, requestError, decodingError, statusNotOk
}
