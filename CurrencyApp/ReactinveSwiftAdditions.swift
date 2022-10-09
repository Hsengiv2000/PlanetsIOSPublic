//
//  ReactinveSwiftAdditions.swift
//  CurrencyApp
//
//  Created by Rahul Parthasarathy on 3/11/22.
//

import Foundation
import ReactiveSwift
import Result

// MARK: - SignalProducer

public typealias STSignalProducer<T> = SignalProducer<T, AnyError>

public enum NoValue {
    case none
}

extension SignalProducer {
    
    public static var weakError: STSignalProducer<Value> {
        return STSignalProducer(anyError: InternalError.weakError)
    }
    
    public static var needsLoginError: STSignalProducer<Value> {
        return STSignalProducer(anyError: InternalError.needsLogin)
    }
    
    public init(_ deferHandler: @escaping () -> SignalProducer<Value, Error>) {
        self.init { (observer, disposable) in
            disposable += deferHandler().start(observer)
        }
    }
}

extension SignalProducer where Error == AnyError {
    
    public init(anyError error: Swift.Error) {
        
        if let anyError = error as? AnyError {
            self.init(error: anyError)
        } else {
            self.init(error: AnyError(error))
        }
    }
    
    public init(_ deferHandler: @escaping () throws -> SignalProducer<Value, AnyError>) {
        self.init { (observer, disposable) in
            do {
                disposable += try deferHandler().start(observer)
            }
            catch {
                observer.send(anyError: error)
            }
        }
    }
    
    func timeout(after interval: TimeInterval,
                 raisingAny error: Swift.Error,
                 on scheduler: DateScheduler) -> STSignalProducer<Value> {
        
        return timeout(after: interval, raising: AnyError(error), on: scheduler)
    }
    
    public func flatMapLatest<Inner: SignalProducerConvertible>(
        _ transform: @escaping (Value) throws -> Inner)
        -> SignalProducer<Inner.Value, Error> where Inner.Error == Error {
            return flatMap(.latest, { (value) -> SignalProducer<Inner.Value, Error> in
                do {
                    return try transform(value).producer
                } catch {
                    return SignalProducer<Inner.Value, Error>(anyError: error)
                }
            })
    }
    
    public static func value<T>(_ value: T) -> SignalProducer<T, AnyError> {
        return SignalProducer<T, AnyError>(value: value)
    }
    
    public static func anyError<T>(_ error: Swift.Error) -> SignalProducer<T, AnyError> {
        return SignalProducer<T, AnyError>(anyError: error)
    }
    
}

// MARK: - Signal

public typealias STSignal<T> = Signal<T, NoError>

extension Signal.Observer where Error == AnyError {
    
    public func send(anyError error: Swift.Error) {
        send(error: AnyError(error))
    }
    
    public func sendWeakError() {
        send(anyError: InternalError.weakError)
    }
}

public enum Generators {
    public static func connectionRetryTimes(on scheduler: DateScheduler) -> Signal<NoValue, NoError> {
        return Signal { (observer, lifetime) in
            let interval: Int = 3
            
            lifetime += scheduler.schedule(after: scheduler.currentDate, interval: .seconds(interval), leeway: .seconds(1), action: {
                observer.send(value: .none)
            })
        }
    }
}


extension SignalProducer where Error == AnyError, Value == NoValue {
    public func filterErrorsAndInterrupts() -> STSignalProducer<NoValue> {
        return materialize().filter({ (event) -> Bool in
            switch event {
            case .completed, .value: return true
            case .interrupted, .failed: return false
            }
        }).dematerialize()
    }
}

extension SignalProducer where Error == AnyError {
    public func mapErrorAndInterruptToEmpty() -> STSignalProducer<Value?> {
        return materialize().map({ (event) -> Signal.Event in
            switch event {
            case .value(let value):
                return .value(value)
            case .interrupted, .failed: return .value(nil)
            case .completed: return .completed
            }
        }).dematerialize()
    }
}

extension SignalProducer {
    public func mapToNoValue() -> SignalProducer<NoValue, Error> {
        return map(value: .none)
    }

    public func mapVoid() -> SignalProducer<Void, Error> {
        return map(value: ())
    }
}

extension Signal {
    public func mapVoid() -> Signal<Void, Error> {
        return map(value: ())
    }
}

extension Signal.Observer where Value == Void {
    public func send() {
        send(value: ())
    }
}
