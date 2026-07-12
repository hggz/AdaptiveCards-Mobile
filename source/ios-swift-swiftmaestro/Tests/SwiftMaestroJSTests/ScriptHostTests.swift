import XCTest
@testable import SwiftMaestroJS

final class ScriptHostTests: XCTestCase {
    func testEvaluateArithmeticAndStrings() async throws {
        let host = try ScriptHost()
        let sum = try await host.evaluate("1 + 2 * 3")
        XCTAssertEqual(sum, .number(7))
        let concat = try await host.evaluate("'a' + 'b'")
        XCTAssertEqual(concat, .string("ab"))
        let length = try await host.evaluate("[1,2].length")
        XCTAssertEqual(length, .number(2))
    }

    func testEvaluateObject() async throws {
        let host = try ScriptHost()
        let object = try await host.evaluate("({x:1, y:'z'})")
        XCTAssertEqual(object, .object(["x": .number(1), "y": .string("z")]))
    }

    func testEvaluateThrowsOnSyntaxError() async throws {
        let host = try ScriptHost()
        do {
            _ = try await host.evaluate("this is not valid ===")
            XCTFail("expected a script error")
        } catch is ScriptError {
            // expected
        }
    }

    func testOutputPersistsAcrossRuns() async throws {
        let host = try ScriptHost()
        try await host.run("output.token = 'abc123'")
        try await host.run("output.count = 2 + 3")
        let out = await host.output()
        XCTAssertEqual(out["token"], "abc123")
        XCTAssertEqual(out["count"], "5")
    }

    func testEnvironmentInjectedAsGlobals() async throws {
        let host = try ScriptHost()
        await host.setEnvironment(["NAME": "World", "COUNT": "3"])
        let name = try await host.evaluate("NAME")
        XCTAssertEqual(name, .string("World"))
        let equalsThree = await host.isTruthy("Number(COUNT) === 3")
        XCTAssertTrue(equalsThree)
        let equalsFour = await host.isTruthy("Number(COUNT) === 4")
        XCTAssertFalse(equalsFour)
    }

    func testExpandInterpolatesEnvAndOutput() async throws {
        let host = try ScriptHost()
        await host.setEnvironment(["NAME": "World"])
        try await host.run("output.n = 41 + 1")
        let expanded = await host.expand("Hi ${NAME}, n=${output.n}")
        XCTAssertEqual(expanded, "Hi World, n=42")
    }

    func testExpandEvaluatesExpressions() async throws {
        let host = try ScriptHost()
        let expanded = await host.expand("sum=${2 + 40}")
        XCTAssertEqual(expanded, "sum=42")
    }

    func testExpandLeavesUnknownVerbatim() async throws {
        let host = try ScriptHost()
        let unknown = await host.expand("${MISSING}")
        XCTAssertEqual(unknown, "${MISSING}")
        let plain = await host.expand("no placeholders")
        XCTAssertEqual(plain, "no placeholders")
    }

    func testHttpBindingViaFake() async throws {
        let fake = FakeHTTPBinding(response: HTTPScriptResponse(status: 200, body: #"{"ok":true}"#))
        let host = try ScriptHost(http: fake)
        try await host.run("""
        var r = http.get('http://example.test/data');
        output.status = r.status;
        output.ok = JSON.parse(r.body).ok;
        """)
        let out = await host.output()
        XCTAssertEqual(out["status"], "200")
        XCTAssertEqual(out["ok"], "true")
        XCTAssertEqual(fake.requests.count, 1)
        XCTAssertEqual(fake.requests.first?.url, "http://example.test/data")
        XCTAssertEqual(fake.requests.first?.method, "GET")
    }

    func testHttpPostSendsBody() async throws {
        let fake = FakeHTTPBinding(response: HTTPScriptResponse(status: 201, body: "{}"))
        let host = try ScriptHost(http: fake)
        try await host.run("http.post('http://example.test/submit', {name: 'x'});")
        XCTAssertEqual(fake.requests.first?.method, "POST")
        XCTAssertEqual(fake.requests.first?.body, #"{"name":"x"}"#)
    }

    func testAsyncHttpBindingAgainstLocalServer() async throws {
        let server = MockHTTPServer(responseJSON: #"{"hello":"world"}"#)
        let port = try server.start()
        defer { server.stop() }

        let host = try ScriptHost(http: AsyncHTTPBinding())
        try await host.run("""
        var r = http.get('http://127.0.0.1:\(port)/data');
        output.status = r.status;
        output.body = r.body;
        """)
        let out = await host.output()
        XCTAssertEqual(out["status"], "200")
        XCTAssertTrue((out["body"] ?? "").contains("world"), "expected the mock body, got \(out["body"] ?? "")")
    }
}
