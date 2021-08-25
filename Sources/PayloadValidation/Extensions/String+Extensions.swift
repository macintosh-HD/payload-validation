import Crypto
import Foundation

extension String {
    var keyFormat: SymmetricKey {
        let data = Array(self.utf8)
        let key = SymmetricKey(data: data)
        return key
    }
}
