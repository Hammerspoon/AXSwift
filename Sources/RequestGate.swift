import Cocoa
import Foundation

// Hammerspoon fork divergence: see "Divergences from upstream" in README.md.

/// Decides whether an accessibility request may be sent to an application.
///
/// It's given the process ID of the application the request would go to, and returns `nil` to let
/// the request go ahead, or the error to throw instead of sending it.
///
/// - note: An app's accessibility requests to *itself* aren't sent anywhere: the system calls the
///         app's own `NSAccessibility` implementation directly, on whichever thread made the
///         request. A gate can refuse those that would run AppKit code off the main thread.
public typealias AXRequestGate = @Sendable (_ targetProcessID: pid_t) -> AXError?

extension UIElement {
    private static let requestGateLock = NSLock()
    nonisolated(unsafe) private static var storedRequestGate: AXRequestGate?

    /// Consulted before every request any `UIElement`, `Application` or `Observer` sends to an
    /// application. `nil` (the default) lets every request through.
    ///
    /// Requests whose target can't be determined (e.g. those sent to the system-wide element, or
    /// to an element that's no longer valid) aren't checked.
    public static var requestGate: AXRequestGate? {
        get {
            requestGateLock.lock()
            defer { requestGateLock.unlock() }
            return storedRequestGate
        }
        set {
            requestGateLock.lock()
            defer { requestGateLock.unlock() }
            storedRequestGate = newValue
        }
    }

    /// Throws the error the request gate chooses for a request to `processID`, if any
    static func checkRequestGate(forProcessID processID: pid_t) throws(AXError) {
        guard let gate = requestGate else { return }
        if let refusal = gate(processID) {
            throw refusal
        }
    }

    /// Throws the error the request gate chooses for a request to this element, if any
    func checkRequestGate() throws(AXError) {
        guard let gate = UIElement.requestGate else { return }
        var processID: pid_t = 0
        // Getting the pid is answered locally, without sending a request
        guard AXUIElementGetPid(element, &processID) == .success, processID > 0 else { return }
        if let refusal = gate(processID) {
            throw refusal
        }
    }
}
