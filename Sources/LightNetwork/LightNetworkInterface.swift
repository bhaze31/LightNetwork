import Foundation

open class LightNetworkInterface: LightNetworkInterfaceProtocol {
    private let defaultHeaders = [
        "Content-Type": "application/json"
    ]
    
    open func setHeaders(for request: inout URLRequest, headers: Dictionary<String, String>) {
        for (header, value) in defaultHeaders {
            request.setValue(value, forHTTPHeaderField: header)
        }
        
        for (header, value) in headers {
            request.setValue(value, forHTTPHeaderField: header)
        }
    }
}
