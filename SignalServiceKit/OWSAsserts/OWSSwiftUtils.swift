//
// Copyright 2024 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation

/**
 * We synchronize access to state in this class using this queue.
 */
public func assertOnQueue(_ queue: DispatchQueue) {
    dispatchPrecondition(condition: .onQueue(queue))
}

@inlinable
public func AssertIsOnMainThread(
    file: String = #fileID,
    function: String = #function,
    line: Int = #line
) {
    if !Thread.isMainThread {
        owsFailDebug("Must be on main thread.", file: file, function: function, line: line)
    }
}

@inlinable
public func AssertNotOnMainThread(
    file: String = #fileID,
    function: String = #function,
    line: Int = #line
) {
    if Thread.isMainThread {
        owsFailDebug("Must be off main thread.", file: file, function: function, line: line)
    }
}

@inlinable
public func owsFailDebug(
    _ logMessage: String,
    file: String = #fileID,
    function: String = #function,
    line: Int = #line
) {
    Logger.error(logMessage, file: file, function: function, line: line)
    if IsDebuggerAttached() {
        TrapDebugger()
    } else {
        assertionFailure(logMessage)
    }
}

@inlinable
public func owsFail(
    _ logMessage: String,
    file: String = #fileID,
    function: String = #function,
    line: Int = #line
) -> Never {
    logStackTrace()
    owsFailDebug(logMessage, file: file, function: function, line: line)
    Logger.flush()
    fatalError(logMessage)
}

@inlinable
public func owsAssertDebug(
    _ condition: Bool,
    _ message: @autoclosure () -> String = String(),
    file: String = #fileID,
    function: String = #function,
    line: Int = #line
) {
    if !condition {
        let message: String = message()
        owsFailDebug(message.isEmpty ? "Assertion failed." : message, file: file, function: function, line: line)
    }
}

/// Like `Swift.precondition(_:)`, this will trap if `condition` evaluates to
/// `false`. Also performs additional logging before terminating the process.
/// See `owsFail(_:)` for more information about logging.
@inlinable
public func owsPrecondition(
    _ condition: @autoclosure () -> Bool,
    _ message: @autoclosure () -> String = String(),
    file: String = #fileID,
    function: String = #function,
    line: Int = #line
) {
    if !condition() {
        let message: String = message()
        owsFail(message.isEmpty ? "Assertion failed." : message, file: file, function: function, line: line)
    }
}

@objc
public class OWSSwiftUtils: NSObject {
    // This method can be invoked from Obj-C to exit the app.
    @objc
    public class func owsFailObjC(
        _ logMessage: String,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) -> Never {
        owsFail(logMessage, file: file, function: function, line: line)
    }
}

public func logStackTrace() {
    Logger.error(Thread.callStackSymbols.joined(separator: "\n"))
}
