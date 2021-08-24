import Vapor

struct PayloadValidationMiddleware: Middleware {
    
    let secretToken: SymmetricKey
    private let headerName: HTTPHeaders.Name
    
    init(secretToken: String, signatureHeaderName: String) {
        let data = Array(secretToken.utf8)
        self.secretToken = SymmetricKey(data: data)
        
        self.headerName = HTTPHeaders.Name(signatureHeaderName)
    }
    
    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        guard let requestSignature = request.headers.first(name: headerName),
              let signatureData = Data(base64Encoded: requestSignature) else {
            request.logger.debug("No signature header supplied.")
            return request.eventLoop.future(error: Abort(.badRequest))
        }
        
        return request.body.collect().unwrap(or: Abort(.noContent)).map { bytes -> Bool in
            let bodyData = Data(buffer: bytes)
            
            return verify(signature: signatureData, messageBody: bodyData)
        }
        .guard({ $0 }, else: Abort(.unauthorized))
        .flatMap { _ in next.respond(to: request) }
    }
    
    private func verify(signature: Data, messageBody: Data) -> Bool {
        return HMAC<SHA256>.isValidAuthenticationCode(signature, authenticating: messageBody, using: secretToken)
    }
}

