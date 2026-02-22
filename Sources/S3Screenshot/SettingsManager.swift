import Foundation

class SettingsManager {
    static let shared = SettingsManager()

    private let defaults = UserDefaults.standard

    var isConfigured: Bool {
        guard let ak = accessKeyId, !ak.isEmpty,
              let sk = secretAccessKey, !sk.isEmpty,
              let r = region, !r.isEmpty,
              let b = bucketName, !b.isEmpty else {
            return false
        }
        return true
    }

    var accessKeyId: String? {
        get { defaults.string(forKey: "awsAccessKeyId") }
        set { defaults.set(newValue, forKey: "awsAccessKeyId") }
    }

    var secretAccessKey: String? {
        get { defaults.string(forKey: "awsSecretAccessKey") }
        set { defaults.set(newValue, forKey: "awsSecretAccessKey") }
    }

    var region: String? {
        get { defaults.string(forKey: "awsRegion") }
        set { defaults.set(newValue, forKey: "awsRegion") }
    }

    var bucketName: String? {
        get { defaults.string(forKey: "s3BucketName") }
        set { defaults.set(newValue, forKey: "s3BucketName") }
    }
}
