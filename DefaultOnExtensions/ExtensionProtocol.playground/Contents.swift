import UIKit

/// Testing default parameters on protocol
protocol TestProtocol {
    func testFunction(a: Int, b: Int?) -> String
}

extension TestProtocol {
    func testFunction(a:Int, b: Int? = nil) -> String {
        return testFunction(a: a, b: b)
    }
}

class TestClass1: TestProtocol {
    var count: Int = 0
    func testFunction(a: Int, b: Int?) -> String {
        count += 1
        return "a:\(a), b:\(b)"
    }
}

class TestClass2: TestProtocol {
    var count: Int = 0
    func testFunction(a: Int) -> String {
        count += 1
        return "a:\(a)"
    }
}

let test1 = TestClass1()
let test2 = TestClass2()
print(test1.testFunction(a:10)) // print a:10, b:nil
print(test1.testFunction(a:10, b: 5)) // print a:10, b:5
print(test2.testFunction(a:10)) // print a:10
