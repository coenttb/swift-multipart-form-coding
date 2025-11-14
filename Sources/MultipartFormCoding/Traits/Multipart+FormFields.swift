//
//  Multipart+FormFields.swift
//  MultipartFormCoding
//
//  Created by swift-multipart-form-coding contributors
//

import Foundation
import RFC_2046

extension RFC_2046.Multipart {
    /// Extracts form fields from multipart/form-data into a dictionary
    /// - Returns: Dictionary mapping field names to their values
    public func extractFormFields() -> [String: Any] {
        var fields: [String: Any] = [:]

        for part in parts {
            // Extract the field name from Content-Disposition header (case-insensitive)
            guard let contentDisposition = part.headers.first(where: { $0.key.lowercased() == "content-disposition" })?.value else {
                continue
            }

            // Parse the name parameter from Content-Disposition
            // Format: form-data; name="fieldname"
            guard let nameStart = contentDisposition.range(of: "name=\""),
                  let nameEnd = contentDisposition[nameStart.upperBound...].range(of: "\"") else {
                continue
            }

            let fieldName = String(contentDisposition[nameStart.upperBound..<nameEnd.lowerBound])

            // Convert content data to string
            if let stringValue = String(data: part.content, encoding: .utf8) {
                fields[fieldName] = stringValue
            }
        }

        return fields
    }
}
