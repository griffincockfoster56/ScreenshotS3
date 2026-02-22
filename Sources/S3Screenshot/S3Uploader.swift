import CryptoKit
import Foundation

struct S3Object {
    let key: String
    let lastModified: Date
    let size: Int64
}

struct ListObjectsResult {
    let objects: [S3Object]
    let continuationToken: String?
}

class S3Uploader {
    enum UploadError: LocalizedError {
        case notConfigured
        case fileReadError
        case uploadFailed(String)
        case invalidResponse
        case listFailed(String)

        var errorDescription: String? {
            switch self {
            case .notConfigured: return "AWS credentials not configured"
            case .fileReadError: return "Failed to read screenshot file"
            case .uploadFailed(let msg): return "Upload failed: \(msg)"
            case .invalidResponse: return "Invalid response from S3"
            case .listFailed(let msg): return "List failed: \(msg)"
            }
        }
    }

    // MARK: - Upload screenshot

    func upload(fileURL: URL, completion: @escaping (Result<String, Error>) -> Void) {
        let settings = SettingsManager.shared

        guard let accessKey = settings.accessKeyId,
              let secretKey = settings.secretAccessKey,
              let region = settings.region,
              let bucket = settings.bucketName
        else {
            completion(.failure(UploadError.notConfigured))
            return
        }

        guard let fileData = try? Data(contentsOf: fileURL) else {
            completion(.failure(UploadError.fileReadError))
            return
        }

        let df = DateFormatter()
        df.dateFormat = "yyyy/MM/dd"
        df.timeZone = TimeZone(identifier: "UTC")
        let datePath = df.string(from: Date())
        let id = UUID().uuidString.prefix(8).lowercased()
        let ext = fileURL.pathExtension.lowercased()
        let key = "\(datePath)/\(id).\(ext)"

        let contentType = Self.mimeType(for: ext)
        let host = "\(bucket).s3.\(region).amazonaws.com"
        let urlString = "https://\(host)/\(key)"

        guard let url = URL(string: urlString) else {
            completion(.failure(UploadError.invalidResponse))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")

        signRequest(&request, body: fileData, accessKey: accessKey, secretKey: secretKey, region: region)

        let task = URLSession.shared.uploadTask(with: request, from: fileData) { data, response, error in
            if let error = error {
                completion(.failure(UploadError.uploadFailed(error.localizedDescription)))
                return
            }
            guard let http = response as? HTTPURLResponse else {
                completion(.failure(UploadError.invalidResponse))
                return
            }
            if http.statusCode == 200 {
                completion(.success(urlString))
            } else if http.statusCode == 301 || http.statusCode == 307 {
                // Bucket is in a different region — extract and retry
                let redirectRegion = http.allHeaderFields["x-amz-bucket-region"] as? String
                    ?? data.flatMap({ Self.extractRegionFromRedirect($0) })
                    ?? "us-east-1"
                NSLog("[ScreenshotS3] Redirect to region: %@, headers: %@", redirectRegion, "\(http.allHeaderFields)")
                self.uploadToRegion(
                    fileData: fileData, key: key, contentType: contentType,
                    bucket: bucket, region: redirectRegion,
                    accessKey: accessKey, secretKey: secretKey,
                    completion: completion
                )
            } else {
                let body = data.flatMap { String(data: $0, encoding: .utf8) } ?? "Unknown error"
                completion(.failure(UploadError.uploadFailed("HTTP \(http.statusCode): \(body)")))
            }
        }
        task.resume()
    }

    /// Retry upload to the correct region after a 301 redirect
    private func uploadToRegion(
        fileData: Data, key: String, contentType: String,
        bucket: String, region: String,
        accessKey: String, secretKey: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let host = "\(bucket).s3.\(region).amazonaws.com"
        let urlString = "https://\(host)/\(key)"

        guard let url = URL(string: urlString) else {
            completion(.failure(UploadError.invalidResponse))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")

        signRequest(&request, body: fileData, accessKey: accessKey, secretKey: secretKey, region: region)

        URLSession.shared.uploadTask(with: request, from: fileData) { data, response, error in
            if let error = error {
                completion(.failure(UploadError.uploadFailed(error.localizedDescription)))
                return
            }
            guard let http = response as? HTTPURLResponse else {
                completion(.failure(UploadError.invalidResponse))
                return
            }
            if http.statusCode == 200 {
                completion(.success(urlString))
            } else {
                let body = data.flatMap { String(data: $0, encoding: .utf8) } ?? "Unknown error"
                completion(.failure(UploadError.uploadFailed("HTTP \(http.statusCode): \(body)")))
            }
        }.resume()
    }

    /// Parse the region from an S3 301 PermanentRedirect response
    private static func extractRegionFromRedirect(_ data: Data) -> String? {
        guard let body = String(data: data, encoding: .utf8) else { return nil }
        NSLog("[ScreenshotS3] Redirect body: %@", body)

        // Try <Region>REGION</Region> first (most reliable)
        if let range = body.range(of: "(?<=<Region>)[^<]+", options: .regularExpression) {
            return String(body[range])
        }
        // Try <Endpoint>bucket.s3.REGION.amazonaws.com</Endpoint> (dot format)
        if let range = body.range(of: "(?<=<Endpoint>)[^<]+", options: .regularExpression) {
            let endpoint = String(body[range])
            // Handle both s3.REGION. and s3-REGION. formats
            if let r = endpoint.range(of: "(?<=\\.s3[.-])[^.]+(?=\\.amazonaws)", options: .regularExpression) {
                return String(endpoint[r])
            }
        }
        return nil
    }

    // MARK: - List buckets

    func listBuckets(
        accessKey: String, secretKey: String, region: String,
        completion: @escaping (Result<[String], Error>) -> Void
    ) {
        let host = "s3.\(region).amazonaws.com"
        guard let url = URL(string: "https://\(host)/") else {
            completion(.failure(UploadError.invalidResponse))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        signRequest(&request, body: Data(), accessKey: accessKey, secretKey: secretKey, region: region)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(UploadError.uploadFailed(error.localizedDescription)))
                return
            }
            guard let http = response as? HTTPURLResponse else {
                completion(.failure(UploadError.invalidResponse))
                return
            }
            guard let data = data else {
                completion(.failure(UploadError.invalidResponse))
                return
            }
            if http.statusCode == 200 {
                let parser = BucketListXMLParser()
                let xml = XMLParser(data: data)
                xml.delegate = parser
                xml.parse()
                completion(.success(parser.buckets.sorted()))
            } else {
                let body = String(data: data, encoding: .utf8) ?? ""
                if http.statusCode == 403 {
                    completion(.failure(UploadError.uploadFailed("Invalid credentials (HTTP 403)")))
                } else {
                    completion(.failure(UploadError.uploadFailed("HTTP \(http.statusCode): \(body)")))
                }
            }
        }.resume()
    }

    // MARK: - Create bucket

    func createBucket(
        name: String, accessKey: String, secretKey: String, region: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let host = "\(name).s3.\(region).amazonaws.com"
        guard let url = URL(string: "https://\(host)/") else {
            completion(.failure(UploadError.invalidResponse))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"

        var body = Data()
        if region != "us-east-1" {
            let xml = """
                <CreateBucketConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/">\
                <LocationConstraint>\(region)</LocationConstraint>\
                </CreateBucketConfiguration>
                """
            body = Data(xml.utf8)
            request.setValue("application/xml", forHTTPHeaderField: "Content-Type")
        }

        signRequest(&request, body: body, accessKey: accessKey, secretKey: secretKey, region: region)

        URLSession.shared.uploadTask(with: request, from: body) { data, response, error in
            if let error = error {
                completion(.failure(UploadError.uploadFailed(error.localizedDescription)))
                return
            }
            guard let http = response as? HTTPURLResponse else {
                completion(.failure(UploadError.invalidResponse))
                return
            }
            if http.statusCode == 200 {
                completion(.success(()))
            } else if http.statusCode == 409 {
                // Check if it's ours or someone else's
                let body = data.flatMap { String(data: $0, encoding: .utf8) } ?? ""
                if body.contains("BucketAlreadyOwnedByYou") {
                    completion(.success(()))
                } else {
                    completion(.failure(UploadError.uploadFailed(
                        "The bucket name \"\(name)\" is already taken. S3 bucket names are globally unique — try a different name."
                    )))
                }
            } else {
                let body = data.flatMap { String(data: $0, encoding: .utf8) } ?? "Unknown error"
                if http.statusCode == 403 {
                    completion(.failure(UploadError.uploadFailed("Access denied — check your credentials and permissions")))
                } else {
                    completion(.failure(UploadError.uploadFailed("HTTP \(http.statusCode): \(body)")))
                }
            }
        }.resume()
    }

    // MARK: - List objects

    private static let imageExtensions: Set<String> = ["png", "jpg", "jpeg", "tiff", "tif", "gif"]

    func listObjects(
        bucket: String, accessKey: String, secretKey: String, region: String,
        continuationToken: String? = nil,
        completion: @escaping (Result<ListObjectsResult, Error>) -> Void
    ) {
        let host = "\(bucket).s3.\(region).amazonaws.com"
        var queryParts = ["list-type=2", "max-keys=100"]
        if let token = continuationToken {
            queryParts.append("continuation-token=\(token.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? token)")
        }
        let queryString = queryParts.joined(separator: "&")

        guard let url = URL(string: "https://\(host)/?\(queryString)") else {
            completion(.failure(UploadError.invalidResponse))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        signRequest(&request, body: Data(), accessKey: accessKey, secretKey: secretKey, region: region)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(UploadError.listFailed(error.localizedDescription)))
                return
            }
            guard let http = response as? HTTPURLResponse, let data = data else {
                completion(.failure(UploadError.invalidResponse))
                return
            }
            if http.statusCode == 200 {
                let parser = ObjectListXMLParser()
                let xml = XMLParser(data: data)
                xml.delegate = parser
                xml.parse()

                let filtered = parser.objects.filter { obj in
                    let ext = (obj.key as NSString).pathExtension.lowercased()
                    return Self.imageExtensions.contains(ext)
                }

                let result = ListObjectsResult(
                    objects: filtered,
                    continuationToken: parser.isTruncated ? parser.nextContinuationToken : nil
                )
                completion(.success(result))
            } else {
                let body = String(data: data, encoding: .utf8) ?? ""
                completion(.failure(UploadError.listFailed("HTTP \(http.statusCode): \(body)")))
            }
        }.resume()
    }

    // MARK: - Make bucket publicly accessible

    func makeBucketPublic(
        bucket: String, accessKey: String, secretKey: String, region: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let host = "\(bucket).s3.\(region).amazonaws.com"

        // Step 1: Delete Block Public Access
        s3Request(method: "DELETE", host: host, query: "publicAccessBlock", body: Data(),
                  accessKey: accessKey, secretKey: secretKey, region: region) { result in
            switch result {
            case .failure(let error):
                NSLog("[ScreenshotS3] Failed to delete public access block: %@", error.localizedDescription)
                completion(.failure(error))
            case .success(let (status, _)):
                NSLog("[ScreenshotS3] Delete public access block: HTTP %d", status)

                // Step 2: Set object ownership to BucketOwnerPreferred (enables ACLs)
                let ownershipXML = """
                    <OwnershipControls><Rule><ObjectOwnership>BucketOwnerPreferred</ObjectOwnership></Rule></OwnershipControls>
                    """
                self.s3Request(method: "PUT", host: host, query: "ownershipControls",
                               body: Data(ownershipXML.utf8), contentType: "application/xml",
                               accessKey: accessKey, secretKey: secretKey, region: region) { result in
                    switch result {
                    case .failure(let error):
                        NSLog("[ScreenshotS3] Failed to set ownership controls: %@", error.localizedDescription)
                        completion(.failure(error))
                    case .success(let (status, _)):
                        NSLog("[ScreenshotS3] Set ownership controls: HTTP %d", status)

                        // Step 3: Set public-read bucket policy
                        let policy = """
                            {"Version":"2012-10-17","Statement":[{"Sid":"PublicReadGetObject","Effect":"Allow","Principal":"*","Action":"s3:GetObject","Resource":"arn:aws:s3:::\(bucket)/*"}]}
                            """
                        self.s3Request(method: "PUT", host: host, query: "policy",
                                       body: Data(policy.utf8), contentType: "application/json",
                                       accessKey: accessKey, secretKey: secretKey, region: region) { result in
                            switch result {
                            case .failure(let error):
                                NSLog("[ScreenshotS3] Failed to set bucket policy: %@", error.localizedDescription)
                                completion(.failure(error))
                            case .success(let (status, _)):
                                NSLog("[ScreenshotS3] Set bucket policy: HTTP %d", status)
                                completion(.success(()))
                            }
                        }
                    }
                }
            }
        }
    }

    /// Generic signed S3 request helper
    private func s3Request(
        method: String, host: String, query: String, body: Data,
        contentType: String? = nil,
        accessKey: String, secretKey: String, region: String,
        completion: @escaping (Result<(Int, String), Error>) -> Void
    ) {
        guard let url = URL(string: "https://\(host)/?\(query)") else {
            completion(.failure(UploadError.invalidResponse))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        if let ct = contentType {
            request.setValue(ct, forHTTPHeaderField: "Content-Type")
        }

        signRequest(&request, body: body, accessKey: accessKey, secretKey: secretKey, region: region)
        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(UploadError.uploadFailed(error.localizedDescription)))
                return
            }
            guard let http = response as? HTTPURLResponse else {
                completion(.failure(UploadError.invalidResponse))
                return
            }
            let responseBody = data.flatMap { String(data: $0, encoding: .utf8) } ?? ""
            let status = http.statusCode
            if status >= 200 && status < 300 {
                completion(.success((status, responseBody)))
            } else {
                NSLog("[ScreenshotS3] S3 %@ /?%@ failed: HTTP %d %@", method, query, status, responseBody)
                completion(.failure(UploadError.uploadFailed("S3 \(method) /?\(query): HTTP \(status)")))
            }
        }.resume()
    }

    // MARK: - AWS Signature V4

    private func signRequest(
        _ request: inout URLRequest,
        body: Data,
        accessKey: String,
        secretKey: String,
        region: String
    ) {
        let service = "s3"
        let now = Date()

        let isoFmt = DateFormatter()
        isoFmt.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        isoFmt.timeZone = TimeZone(identifier: "UTC")
        let amzDate = isoFmt.string(from: now)

        let shortFmt = DateFormatter()
        shortFmt.dateFormat = "yyyyMMdd"
        shortFmt.timeZone = TimeZone(identifier: "UTC")
        let dateStamp = shortFmt.string(from: now)

        let payloadHash = sha256Hex(body)

        request.setValue(request.url!.host!, forHTTPHeaderField: "Host")
        request.setValue(amzDate, forHTTPHeaderField: "x-amz-date")
        request.setValue(payloadHash, forHTTPHeaderField: "x-amz-content-sha256")

        let method = request.httpMethod!
        let canonicalURI =
            request.url!.path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
            ?? request.url!.path
        let canonicalQueryString: String
        if let query = request.url?.query, !query.isEmpty {
            canonicalQueryString = query.components(separatedBy: "&")
                .map { $0.contains("=") ? $0 : $0 + "=" }
                .sorted()
                .joined(separator: "&")
        } else {
            canonicalQueryString = ""
        }

        let headers = request.allHTTPHeaderFields ?? [:]
        let sortedHeaderKeys = headers.keys.sorted { $0.lowercased() < $1.lowercased() }

        let canonicalHeaders =
            sortedHeaderKeys
            .map { "\($0.lowercased()):\(headers[$0]!.trimmingCharacters(in: .whitespaces))\n" }
            .joined()

        let signedHeaders = sortedHeaderKeys.map { $0.lowercased() }.joined(separator: ";")

        let canonicalRequest = [
            method, canonicalURI, canonicalQueryString,
            canonicalHeaders, signedHeaders, payloadHash,
        ].joined(separator: "\n")

        let credentialScope = "\(dateStamp)/\(region)/\(service)/aws4_request"

        let stringToSign = [
            "AWS4-HMAC-SHA256", amzDate, credentialScope,
            sha256Hex(Data(canonicalRequest.utf8)),
        ].joined(separator: "\n")

        let kDate = hmac(key: Data("AWS4\(secretKey)".utf8), data: Data(dateStamp.utf8))
        let kRegion = hmac(key: kDate, data: Data(region.utf8))
        let kService = hmac(key: kRegion, data: Data(service.utf8))
        let kSigning = hmac(key: kService, data: Data("aws4_request".utf8))

        let signature = hmacHex(key: kSigning, data: Data(stringToSign.utf8))

        let auth =
            "AWS4-HMAC-SHA256 Credential=\(accessKey)/\(credentialScope), "
            + "SignedHeaders=\(signedHeaders), Signature=\(signature)"

        request.setValue(auth, forHTTPHeaderField: "Authorization")
    }

    // MARK: - Crypto

    private func sha256Hex(_ data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }

    private func hmac(key: Data, data: Data) -> Data {
        Data(HMAC<SHA256>.authenticationCode(for: data, using: SymmetricKey(data: key)))
    }

    private func hmacHex(key: Data, data: Data) -> String {
        hmac(key: key, data: data).map { String(format: "%02x", $0) }.joined()
    }

    private static func mimeType(for ext: String) -> String {
        switch ext {
        case "png": return "image/png"
        case "jpg", "jpeg": return "image/jpeg"
        case "tiff", "tif": return "image/tiff"
        case "gif": return "image/gif"
        default: return "application/octet-stream"
        }
    }
}

// MARK: - XML parser for ListBuckets response

private class BucketListXMLParser: NSObject, XMLParserDelegate {
    var buckets: [String] = []
    private var inBucket = false
    private var inName = false
    private var currentName = ""

    func parser(
        _ parser: XMLParser, didStartElement elementName: String,
        namespaceURI: String?, qualifiedName: String?,
        attributes: [String: String] = [:]
    ) {
        if elementName == "Bucket" {
            inBucket = true
            currentName = ""
        } else if elementName == "Name" && inBucket {
            inName = true
            currentName = ""
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if inName { currentName += string }
    }

    func parser(
        _ parser: XMLParser, didEndElement elementName: String,
        namespaceURI: String?, qualifiedName: String?
    ) {
        if elementName == "Name" && inBucket {
            inName = false
        } else if elementName == "Bucket" {
            if !currentName.isEmpty { buckets.append(currentName) }
            inBucket = false
        }
    }
}

// MARK: - XML parser for ListObjectsV2 response

private class ObjectListXMLParser: NSObject, XMLParserDelegate {
    var objects: [S3Object] = []
    var isTruncated = false
    var nextContinuationToken: String?

    private var inContents = false
    private var currentElement = ""
    private var currentKey = ""
    private var currentLastModified = ""
    private var currentSize = ""
    private var currentText = ""

    private static let dateFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    func parser(
        _ parser: XMLParser, didStartElement elementName: String,
        namespaceURI: String?, qualifiedName: String?,
        attributes: [String: String] = [:]
    ) {
        currentText = ""
        if elementName == "Contents" {
            inContents = true
            currentKey = ""
            currentLastModified = ""
            currentSize = ""
        }
        currentElement = elementName
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentText += string
    }

    func parser(
        _ parser: XMLParser, didEndElement elementName: String,
        namespaceURI: String?, qualifiedName: String?
    ) {
        let text = currentText.trimmingCharacters(in: .whitespacesAndNewlines)

        if inContents {
            switch elementName {
            case "Key": currentKey = text
            case "LastModified": currentLastModified = text
            case "Size": currentSize = text
            case "Contents":
                let date = Self.dateFormatter.date(from: currentLastModified) ?? Date.distantPast
                let size = Int64(currentSize) ?? 0
                objects.append(S3Object(key: currentKey, lastModified: date, size: size))
                inContents = false
            default: break
            }
        } else {
            switch elementName {
            case "IsTruncated": isTruncated = (text == "true")
            case "NextContinuationToken": nextContinuationToken = text
            default: break
            }
        }
    }
}
