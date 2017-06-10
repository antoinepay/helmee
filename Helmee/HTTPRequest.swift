import Alamofire

enum Result<T, E: Error> {
    case value(T)
    case error(E)
}

struct HTTPError: Error {
    var type: ErrorEnum
    var message: String?
}

enum ErrorEnum {
    case personalized
    case unauthorized
    case serviceUnavailable
    case notFound
    case unprocessableEntity
    case unspecified
    case notConnectedToInternet
    case badParameters
}

struct HTTPRequest {
    let method: HTTPMethod
    let URL: String
    let completion: (Result<Any, HTTPError>) -> Void

    var parameters: Parameters?
    var encoding: JSONEncoding = .default

    init(_ method: HTTPMethod, URL: String, parameters: Parameters, completion: @escaping (Result<Any, HTTPError>) -> Void) {
        self.method = method
        self.URL = URL
        self.completion = completion
        self.parameters = parameters
    }
}
