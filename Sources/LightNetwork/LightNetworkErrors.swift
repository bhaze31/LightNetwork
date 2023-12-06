//
//  NetworkErrors.swift
//  
//
//  Created by Brian Hasenstab on 1/1/22.
//

import Foundation

public enum LightNetworkError: Error {
    case InvalidResponse(data: Data, response: URLResponse)
    case NonDecodable(data: Data, response: URLResponse)
    case ClientError(data: Data, response: URLResponse)
    case ServerError(data: Data, response: URLResponse)
    case UnknownRequestError(data: Data, response: URLResponse)
    case UnknownError
    
    var errorDescription: String {
        switch self {
            case .InvalidResponse:
                "Error handling response"
            case .NonDecodable:
                "Error handling response"
            case .ClientError:
                "Bad request"
            case .ServerError:
                "Server error"
            case .UnknownRequestError:
                "Unknown request error"
            case .UnknownError:
                "Unknown error"
        }
    }
}
