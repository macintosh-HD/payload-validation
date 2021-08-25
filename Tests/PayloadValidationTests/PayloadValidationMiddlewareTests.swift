import XCTVapor
@testable import PayloadValidation

final class PayloadValidationMiddlewareTests: XCTestCase {
    let secret = "superS4f3secret"
    let body = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam"
    let headerName = "HTTP_SIGNATURE"
    
    func testPayloadMiddleware_withSpecificContent() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        configure(app)
        
        let data = body.data(using: .utf8)!
        let key = PayloadValidation.generateKey(secretToken: secret, body: data)
        var headers = HTTPHeaders()
        headers.add(name: headerName, value: key)
        
        try app.test(.GET, "", headers: headers, body: ByteBuffer(data: data)) { res in
            XCTAssertEqual(res.status, .ok)
        }
    }
    
    private func configure(_ app: Application) {
        let middleware = PayloadValidationMiddleware(secretToken: secret, signatureHeaderName: headerName)
        app.middleware.use(middleware)
        
        app.get { req -> EventLoopFuture<HTTPStatus> in
            return req.eventLoop.future(.ok)
        }
    }
}
