import Foundation

extension String: Value {
    public func pushValue(L: VirtualMachine) { L.pushString(self) }
    public static func fromLua(L: VirtualMachine, at position: Int) -> String? {
        if L.kind(position) != .String { return nil }
        var len: UInt = 0
        let str = lua_tolstring(L.luaState, Int32(position), &len)
        return NSString(CString: str, encoding: NSUTF8StringEncoding)
    }
    public static func typeName() -> String { return "<String>" }
    public static func kind() -> Kind { return .String }
    public static func arg() -> TypeChecker { return (String.typeName, String.isValid) }
    public static func isValid(L: VirtualMachine, at position: Int) -> Bool {
        return L.kind(position) == kind()
    }
}

extension Int64: Value {
    public func pushValue(L: VirtualMachine) { L.pushInteger(self) }
    public static func fromLua(L: VirtualMachine, at position: Int) -> Int64? {
        if L.kind(position) != .Integer { return nil }
        return lua_tointegerx(L.luaState, Int32(position), nil)
    }
    public static func typeName() -> String { return "<Integer>" }
    public static func kind() -> Kind { return .Integer }
    public static func arg() -> TypeChecker { return (Int64.typeName, Int64.isValid) }
    public static func isValid(L: VirtualMachine, at position: Int) -> Bool {
        return L.kind(position) == kind()
    }
}

extension Double: Value {
    public func pushValue(L: VirtualMachine) { L.pushDouble(self) }
    public static func fromLua(L: VirtualMachine, at position: Int) -> Double? {
        if L.kind(position) != .Double { return nil }
        return lua_tonumberx(L.luaState, Int32(position), nil)
    }
    public static func typeName() -> String { return "<Double>" }
    public static func kind() -> Kind { return .Double }
    public static func arg() -> TypeChecker { return (Double.typeName, Double.isValid) }
    public static func isValid(L: VirtualMachine, at position: Int) -> Bool {
        return L.kind(position) == kind()
    }
}

extension Bool: Value {
    public func pushValue(L: VirtualMachine) { L.pushBool(self) }
    public static func fromLua(L: VirtualMachine, at position: Int) -> Bool? {
        if L.kind(position) != .Bool { return nil }
        return lua_toboolean(L.luaState, Int32(position)) != 0
    }
    public static func typeName() -> String { return "<Boolean>" }
    public static func kind() -> Kind { return .Bool }
    public static func arg() -> TypeChecker { return (Bool.typeName, Bool.isValid) }
    public static func isValid(L: VirtualMachine, at position: Int) -> Bool {
        return L.kind(position) == kind()
    }
}

// meant for putting functions into Lua only; can't take them out
public struct FunctionBox: Value {
    public let fn: Function
    public init(_ fn: Function) { self.fn = fn }
    
    public func pushValue(L: VirtualMachine) { L.pushFunction(self.fn) }
    public static func fromLua(L: VirtualMachine, at position: Int) -> FunctionBox? {
        // can't ever convert functions to a usable object
        return nil
    }
    public static func typeName() -> String { return "<Function>" }
    public static func kind() -> Kind { return .Function }
    public static func arg() -> TypeChecker { return (FunctionBox.typeName, FunctionBox.isValid) }
    public static func isValid(L: VirtualMachine, at position: Int) -> Bool {
        return L.kind(position) == kind()
    }
}

public final class NilType: Value {
    public func pushValue(L: VirtualMachine) { L.pushNil() }
    public class func fromLua(L: VirtualMachine, at position: Int) -> NilType? {
        if L.kind(position) != .Nil { return nil }
        return Nil
    }
    public class func typeName() -> String { return "<nil>" }
    public class func kind() -> Kind { return .Nil }
    public class func arg() -> TypeChecker { return (NilType.typeName, NilType.isValid) }
    public class func isValid(L: VirtualMachine, at position: Int) -> Bool {
        return L.kind(position) == kind()
    }
}

public let Nil = NilType()

extension NSPoint: Value {
    public func pushValue(L: VirtualMachine) {
        KeyedTable<String,Double>(["x":Double(self.x), "y":Double(self.y)]).pushValue(L)
    }
    public static func fromLua(L: VirtualMachine, at position: Int) -> NSPoint? {
        let table = KeyedTable<String, Double>.fromLua(L, at: position)
        if table == nil { return nil }
        let x = table!["x"] ?? 0
        let y = table!["y"] ?? 0
        return NSPoint(x: x, y: y)
    }
    public static func typeName() -> String { return "<Point>" }
    public static func kind() -> Kind { return .Table }
    public static func arg() -> TypeChecker { return (NSPoint.typeName, NSPoint.isValid) }
    public static func isValid(L: VirtualMachine, at position: Int) -> Bool {
        if L.kind(position) != kind() { return false }
        let dict = KeyedTable<String,Double>.fromLua(L, at: position)
        if dict == nil { return false }
        return dict!["x"] != nil && dict!["y"] != nil
    }
}