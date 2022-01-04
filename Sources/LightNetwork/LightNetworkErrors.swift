//
//  NetworkErrors.swift
//  
//
//  Created by Brian Hasenstab on 1/1/22.
//

import Foundation

public enum LightNetworkError: Error {
    case InvalidResponse
    case NonDecodable
    case ClientError(code: Int)
    case ServerError(code: Int)
    case UnknownRequestError(code: Int)
    case UnknownError
}
