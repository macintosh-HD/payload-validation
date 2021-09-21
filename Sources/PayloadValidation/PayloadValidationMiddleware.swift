import Vapor

public struct PayloadValidationMiddleware: Middleware {
    
    let secretToken: String
    private let headerName: HTTPHeaders.Name
    
    public init(secretToken: String, signatureHeaderName: String) {
        self.secretToken = secretToken
        self.headerName = HTTPHeaders.Name(signatureHeaderName)
    }
    
    public func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        guard let requestSignature = request.headers.first(name: headerName)?.removePrefix("sha256="),
              let signatureData = Data(base64Encoded: requestSignature) else {
            request.logger.debug("No signature header supplied.")
            return request.eventLoop.future(error: Abort(.badRequest))
        }
        
        return request.body.collect().unwrap(or: Abort(.noContent)).map { bytes -> Bool in
            let bodyData = Data(buffer: bytes)
            
            return PayloadValidation.verify(secretToken: secretToken, signature: signatureData, messageBody: bodyData)
        }
        .guard({ $0 }, else: Abort(.unauthorized))
        .flatMap { _ in next.respond(to: request) }
    }
}
