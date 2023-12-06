//
//  LightNetworkProtocol.swift
//  
//
//  Created by Brian Hasenstab on 1/2/22.
//

import Foundation

public protocol LightNetworkInterfaceProtocol {
    func get<T: Codable>(for url: URL, decodeInto format: T.Type, headers: Dictionary<String, String>) async -> (T?, LightNetworkError?)
    func post<T: Codable, B: Codable>(for url: URL, decodeInto format: T.Type, headers: Dictionary<String, String>, body: B) async -> (T?, LightNetworkError?)
    func put<T: Codable, B: Codable>(for url: URL, decodeInto format: T.Type, headers: Dictionary<String, String>, body: B) async -> (T?, LightNetworkError?)
    func patch<T: Codable, B: Codable>(for url: URL, decodeInto format: T.Type, headers: Dictionary<String, String>, body: B) async -> (T?, LightNetworkError?)
    func delete<T: Codable>(for url: URL, decodeInto format: T.Type, headers: Dictionary<String, String>) async -> (T?, LightNetworkError?)
    
    func serializeBody<B: Codable>(body: B) -> Data?
    func setHeaders(for reqest: inout URLRequest, headers: Dictionary<String, String>)
    func createRequestWithBody<B: Codable>(for url: URL, method: HTTPMethod, headers: Dictionary<String, String>, body: B) -> URLRequest
    func createRequest(for url: URL, method: HTTPMethod, headers: Dictionary<String, String>) -> URLRequest
    
    
    func handleResponse<T: Codable>(request: URLRequest, decodeInto format: T.Type) async -> (T?, LightNetworkError?)
}

public extension LightNetworkInterfaceProtocol {
    func handleResponse<T: Codable>(request: URLRequest, decodeInto format: T.Type) async -> (T?, LightNetworkError?) {
        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                return (nil, LightNetworkError.InvalidResponse(data: data, response: response))
            }

            guard httpResponse.statusCode < 400 && httpResponse.statusCode >= 200 else {
                if httpResponse.statusCode >= 400 && httpResponse.statusCode < 500 {
                    return (nil, LightNetworkError.ClientError(data: data, response: response))
                }
                
                if httpResponse.statusCode >= 500 {
                    return (nil, LightNetworkError.ServerError(data: data, response: response))
                }
                
                
                return (nil, LightNetworkError.UnknownRequestError(data: data, response: response))
            }

            guard let decoded = try? JSONDecoder().decode(format, from: data) else {
                return (nil, LightNetworkError.NonDecodable(data: data, response: response))
            }

            return (decoded, nil)
        } catch {
            print(error)
        }

        return (nil, LightNetworkError.UnknownError)
    }
    
    func setHeaders(for request: inout URLRequest, headers: Dictionary<String, String>) {
        for (header, value) in headers {
            request.setValue(value, forHTTPHeaderField: header)
        }
    }
    
    func serializeBody<B: Codable>(body: B) -> Data? {
        return try? JSONEncoder().encode(body)
    }
    
    func createRequestWithBody<B: Codable>(for url: URL, method: HTTPMethod, headers: Dictionary<String, String>, body: B) -> URLRequest {
        var request = URLRequest(url: url)
        
        request.httpMethod = method.rawValue
        request.httpBody = serializeBody(body: body)
        
        setHeaders(for: &request, headers: headers)
        
        return request
    }
    
    func createRequest(for url: URL, method: HTTPMethod, headers: Dictionary<String, String>) -> URLRequest {
        var request = URLRequest(url: url)
        
        request.httpMethod = method.rawValue
        
        setHeaders(for: &request, headers: headers)
        
        return request
    }
    
    func get<T: Codable>(for url: URL, decodeInto format: T.Type, headers: Dictionary<String, String>) async -> (T?, LightNetworkError?) {
        var request = URLRequest(url: url)
        
        request.httpMethod = HTTPMethod.GET.rawValue
        
        setHeaders(for: &request, headers: headers)
        
        return await handleResponse(request: request, decodeInto: format)
    }
    
    func post<T: Codable, B: Codable>(for url: URL, decodeInto format: T.Type, headers: Dictionary<String, String>, body: B) async -> (T?, LightNetworkError?) {
        let request = createRequestWithBody(for: url, method: .POST, headers: headers, body: body)
        
        return await handleResponse(request: request, decodeInto: format)
    }

    func put<T: Codable, B: Codable>(for url: URL, decodeInto format: T.Type, headers: Dictionary<String, String>, body: B) async ->  (T?, LightNetworkError?) {
        let request = createRequestWithBody(for: url, method: .PUT, headers: headers, body: body)
        
        return await handleResponse(request: request, decodeInto: format)
    }
    
    func patch<T: Codable, B: Codable>(for url: URL, decodeInto format: T.Type, headers: Dictionary<String, String>, body: B) async -> (T?, LightNetworkError?) {
        let request = createRequestWithBody(for: url, method: .PATCH, headers: headers, body: body)
        
        return await handleResponse(request: request, decodeInto: format)
    }
    
    
    func delete<T: Codable>(for url: URL, decodeInto format: T.Type, headers: Dictionary<String, String>) async -> (T?, LightNetworkError?) {
        let request = createRequest(for: url, method: .DELETE, headers: headers)
        
        return await handleResponse(request: request, decodeInto: format)
    }
}
