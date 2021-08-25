import Crypto
import Foundation

public enum PayloadValidation {
    public static func generateKey(secretToken: String, body data: Data) -> String {
        let code = HMAC<SHA256>.authenticationCode(for: data, using: secretToken.keyFormat)
        return Data(code).base64EncodedString()
    }
    
    static func verify(secretToken: String, signature: Data, messageBody: Data) -> Bool {
        return HMAC<SHA256>.isValidAuthenticationCode(signature, authenticating: messageBody, using: secretToken.keyFormat)
    }
}
