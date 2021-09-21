import XCTVapor
@testable import PayloadValidation

final class PayloadValidationMiddlewareTests: XCTestCase {
    
    let secret = "superS4f3secret"
    let body = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam"
    let headerName = "x-http-signature"
    
    var app: Application!
    
    override func setUpWithError() throws {
        app = Application(.testing)
        configure(app)
    }
    
    override func tearDown() {
        app.shutdown()
        app = nil
    }
    
    deinit { app?.shutdown() }
    
    func testPayloadMiddleware_withSpecificContent() throws {
        let data = body.data(using: .utf8)!
        let key = PayloadValidation.generateKey(secretToken: secret, body: data)
        var headers = HTTPHeaders()
        headers.add(name: headerName, value: key)
        
        try app.test(.GET, "", headers: headers, body: ByteBuffer(data: data)) { res in
            XCTAssertEqual(res.status, .ok)
        }
    }
    
    func testPayloadMiddleware_withHandCraftedHeader_returnsOk() throws {
        let data = body.data(using: .utf8)!
        let key = generateSignature(for: data)
        var headers = HTTPHeaders()
        headers.add(name: headerName, value: key)
        
        try app.test(.GET, "", headers: headers, body: ByteBuffer(data: data)) { res in
            XCTAssertEqual(res.status, .ok)
        }
    }
    
    // MARK: - helpers
    
    private func configure(_ app: Application) {
        let middleware = PayloadValidationMiddleware(secretToken: secret, signatureHeaderName: headerName)
        app.middleware.use(middleware)
        
        app.get { req -> EventLoopFuture<HTTPStatus> in
            return req.eventLoop.future(.ok)
        }
    }
    
    private func generateSignature(for data: Data) -> String {
        let keyData = secret.data(using: .utf8)!
        let key = SymmetricKey(data: keyData)
        let code = HMAC<SHA256>.authenticationCode(for: data, using: key)
        let base64Code = Data(code).base64EncodedString()
        let finished = "sha256=" + base64Code
        
        return finished
    }
}
