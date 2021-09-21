import XCTVapor
@testable import PayloadValidation

final class PayloadValidationTests: XCTestCase {
    
    func testGenerateHeaders_returnsExpected() throws {
        let token = "superSecret"
        let keyData = token.data(using: .utf8)!
        let data = "Some interesting test data.".data(using: .utf8)!
        let key = SymmetricKey(data: keyData)
        let code = HMAC<SHA256>.authenticationCode(for: data, using: key)
        let base64Code = Data(code).base64EncodedString()
        let finished = "sha256=" + base64Code
        
        let generatedKey = PayloadValidation.generateKey(secretToken: token, body: data)
        
        let result = ("sha256=" + generatedKey) == finished
        
        XCTAssertTrue(result)
    }
    
}
