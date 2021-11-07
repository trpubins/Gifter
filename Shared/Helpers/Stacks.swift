//
//  Stacks.swift
//  Shared (Helper)
//
//  Created by Tanner on 11/6/21.
//
//  https://stackoverflow.com/a/60011232
//


/// A protocol for a Stack data structure.
protocol Stackable {
    associatedtype Element
    func peek() -> Element?
    mutating func push(_ element: Element)
    @discardableResult mutating func pop() -> Element?
}

extension Stackable {
    var isEmpty: Bool { peek() == nil }
}

/// A generic stack data structure.
struct Stack<Element>: Stackable where Element: Equatable {
    private var storage: Array<Element>
    func peek() -> Element? { storage.last }
    mutating func push(_ element: Element) { storage.append(element)  }
    mutating func pop() -> Element? { storage.popLast() }
    
    init() {
        self.storage = Array<Element>()
    }
    
    init(_ array: Array<Element>) {
        self.storage = array
    }
}

extension Stack: Equatable {
    static func == (lhs: Stack<Element>, rhs: Stack<Element>) -> Bool { lhs.storage == rhs.storage }
}

extension Stack: CustomStringConvertible {
    var description: String { "\(storage)" }
}

extension Stack: ExpressibleByArrayLiteral {
    init(arrayLiteral elements: Self.Element...) { storage = elements }
}
