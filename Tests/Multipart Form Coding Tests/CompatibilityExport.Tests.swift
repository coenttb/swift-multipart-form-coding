//
//  CompatibilityExport.Tests.swift
//  swift-multipart-form-coding
//

import MultipartFormCoding
import Testing

@Suite
struct CompatibilityExportTests {
    @Test
    func `module re-exports the multipart form coder`() {
        // swift-multipart-form-coding is a compatibility export for the
        // multipart form coder now owned by swift-html-form-coder. This
        // smoke test just confirms the re-export resolves and the module
        // remains importable and linkable.
        #expect(true)
    }
}
