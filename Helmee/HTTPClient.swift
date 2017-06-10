import Alamofire

struct HTTPClient {

    public static let sharedManager: SessionManager = {
        return Alamofire.SessionManager.default
    }()

    func send(request: HTTPRequest) {
        let manager = HTTPClient.sharedManager
        let httpRequest = manager.request(
            request.URL,
            method: request.method,
            parameters: request.parameters,
            encoding: URLEncoding.httpBody,
            headers: nil
        )
        httpRequest.responseJSON { response in
            let result = self.httpResult(from: response)
            request.completion(result)
        }
        httpRequest.resume()
    }

    // MARK: - Private

    private func httpResult(from response: DataResponse<Any>) -> Result<Any, HTTPError> {
        let result: Result<Any, HTTPError>
        switch response.result {
        case let .failure(error as NSError) where error.code == NSURLErrorNotConnectedToInternet:
            result = .error(HTTPError(type: .notConnectedToInternet, message: nil))
        case .failure(_):
            result = .error(HTTPError(type: .unspecified, message: nil))
        case let .success(value):
            switch response.response?.statusCode ?? 0 {
            case 200...299:
                result = .value(value)
            case 500...599:
                result = .error(HTTPError(type: .serviceUnavailable, message: nil))
            case 400:
                result = .value(value)
            case 401:
                result = .error(HTTPError(type: .unauthorized, message: nil))
            case 404:
                result = .error(HTTPError(type: .notFound, message: nil))
            case 422:
                result = .error(HTTPError(type: .unprocessableEntity, message: nil))
            default:
                result = .error(HTTPError(type: .unspecified, message: nil))
            }
        }
        return result
    }
}
