//
//  File.swift
//  swift-url-form-coding-url-routing
//
//  Created by Coen ten Thije Boonkkamp on 26/07/2025.
//

import Foundation
import URLRouting

extension URLRouting.Field {
    public static func contentType(_ type: () -> Value) -> Self {
        Field("Content-Type") {
            type()
        }
    }
}

extension URLRouting.Field<String> {
    // Convenience properties for common Content-Type values
    public static var applicationJSON: Self {
        Field.contentType { "application/json" }
    }

    public static var json: Self {
        .applicationJSON
    }

    public static var applicationFormURLEncoded: Self {
        Field.contentType { "application/x-www-form-urlencoded" }
    }

    public static var formURLEncoded: Self {
        .applicationFormURLEncoded
    }

    public static var multipartFormData: Self {
        Field.contentType { "multipart/form-data" }
    }

    public static var textPlain: Self {
        Field.contentType { "text/plain" }
    }

    public static var textHTML: Self {
        Field.contentType { "text/html" }
    }

    public static var html: Self {
        .textHTML
    }

    public static var applicationXML: Self {
        Field.contentType { "application/xml" }
    }

    public static var xml: Self {
        .applicationXML
    }

    public static var applicationOctetStream: Self {
        Field.contentType { "application/octet-stream" }
    }

    public static var octetStream: Self {
        .applicationOctetStream
    }
}

extension URLRouting.Field<String> {
    public enum form {
        public static var multipart: URLRouting.Field<String> {
            .multipartFormData
        }

        public static var urlEncoded: URLRouting.Field<String> {
            applicationFormURLEncoded
        }
    }
}
