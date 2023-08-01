//
//  Coordinator.swift
//  NavigationApp
//
//  Created by Filip Šašala on 14/06/2023.
//

import Foundation

fileprivate var kAsyncContinuationKey = "kAsyncContinuationKey"
fileprivate var kAsyncStreamKey = "kAsyncStreamKey"

public protocol Coordinator: Screen, AnyObject {

    associatedtype State
    associatedtype Input
    associatedtype Output

    init(_ input: Input)

    var parent: (any Coordinator)? { get set }
    var state: State { get set }

    /// Removes the last child from coordinator stack.
    /// Useful when popping from different coordinators
    /// or dismissing context.
    func abortChild()

    /// Yields result back to previous coordinator and
    /// dismisses current coordinator.
    func yield(_ output: Output)

    /// Sends new result into asynchronous result stream o
    /// current coordinator. Do not forget to call `finish`
    /// on disappear or when no longer required.
    func send(_ output: Output)

    /// Finishes asynchronous stream of current coordinator.
    /// You must call this function when returning from
    /// current screen to prevent memory leaks and undefined
    /// behaviour.
    func finish()

    func setRoot(to: any Screen)

    func route<Transition: RouteType>(to route: KeyPath<Self, Transition>) -> Transition.ScreenType where Transition.InputType == Void
    func route<Transition: RouteType>(to route: KeyPath<Self, Transition>, _ input: Transition.InputType) -> Transition.ScreenType

}

// MARK: - Synchronous routing

public extension Coordinator {

    func route<Transition: RouteType>(to route: KeyPath<Self, Transition>) -> Transition.ScreenType where Transition.InputType == Void {
        self.route(to: route, ())
    }

    func route<Transition: RouteType>(to route: KeyPath<Self, Transition>, _ input: Transition.InputType) -> Transition.ScreenType {
        assert(self is Transition.CoordinatorType)

        let transition = self[keyPath: route]
        let result: Transition.ScreenType = transition.apply(
            coordinator: (self as! Transition.CoordinatorType),
            input: input
        )

        return result
    }

}

// MARK: - Async result

public extension Coordinator {

    func route<Transition: RouteType>(to route: KeyPath<Self, Transition>) async -> Transition.ScreenType.Output where Transition.ScreenType: Coordinator, Transition.InputType == Void {
        let child = self.route(to: route, ()) as any Coordinator
        let output = await result(from: child) as Transition.ScreenType.Output

        self.abortChild()
        return output
    }

    func route<Transition: RouteType>(to route: KeyPath<Self, Transition>, _ input: Transition.InputType) async -> Transition.ScreenType.Output where Transition.ScreenType: Coordinator {
        let child = self.route(to: route, input) as any Coordinator
        let output = await result(from: child) as Transition.ScreenType.Output

        self.abortChild()
        return output
    }

    private func result<Result>(from child: any Coordinator) async -> Result {
        await withCheckedContinuation { [child] (continuation: CheckedContinuation<Result, Never>) -> () in
            objc_setAssociatedObject(child, &kAsyncContinuationKey, continuation, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

}

// MARK: - Async stream

public extension Coordinator {

    func route<Transition: RouteType>(to route: KeyPath<Self, Transition>) -> AsyncStream<Transition.ScreenType.Output> where Transition.ScreenType: Coordinator, Transition.InputType == Void {
        let child = self.route(to: route, ()) as any Coordinator
        let asyncStream = stream(from: child) as AsyncStream<Transition.ScreenType.Output>

        return asyncStream
    }

    func route<Transition: RouteType>(to route: KeyPath<Self, Transition>, _ input: Transition.InputType) -> AsyncStream<Transition.ScreenType.Output> where Transition.ScreenType: Coordinator {
        let child = self.route(to: route, input) as any Coordinator
        let asyncStream = stream(from: child) as AsyncStream<Transition.ScreenType.Output>

        return asyncStream
    }

    private func stream<Result>(from child: any Coordinator) -> AsyncStream<Result> {
        return AsyncStream { continuation in
            objc_setAssociatedObject(child, &kAsyncStreamKey, continuation, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

}

// MARK: - Async result yielding

public extension Coordinator {

    func yield(_ output: Output) {
        let continuation = objc_getAssociatedObject(self, &kAsyncContinuationKey) as? CheckedContinuation<Output, Never>
        objc_removeAssociatedObjects(self)

        continuation?.resume(returning: output)
    }

    func send(_ output: Output) {
        let continuation = objc_getAssociatedObject(self, &kAsyncStreamKey) as? AsyncStream<Output>.Continuation
        continuation?.yield(output)
    }

    func finish() {
        let continuation = objc_getAssociatedObject(self, &kAsyncStreamKey) as? AsyncStream<Output>.Continuation
        objc_removeAssociatedObjects(self)

        continuation?.finish()
    }

}
