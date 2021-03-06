//
//  reconsideration-generics .swift
//  PracticeSwift
//
//

import Foundation

private protocol Calculator {
    associatedtype Value
    func add(_ lhs: Value, _ rhs: Value) -> Value
}

private struct BasicCalculator: Calculator {
    //func add(_ lhs: Int, _ rhs: Int) -> Int {
    //    return lhs + rhs
    //}
    //protocolがジェネリクスでメソッド宣言していてもoverloadするとコンパイルエラーになる。
    func add(_ lhs: Double, _ rhs: Double) -> Double {
        return lhs + rhs
    }
}

private struct BiCalculator<Element: Numeric>: Calculator {
    private let values: (Element, Element)
    init(_ values: (Element, Element)) {
        self.values = values
    }
    func add(_ lhs: Element, _ rhs: Element) -> Element {
        return lhs + rhs
    }
    func add() -> Element {
        return add(values.0, values.1)
    }
}

//protocolにはmethod・computed property・subscriptだけ宣言するのが安全？
//associatedtypeを使うpropertyは書かない方が実装する側の負担を減らせる。
//以下の例では試しに書いている。
private protocol CalculatorIncludedValues {
    associatedtype Value
    func sum() -> Value
    var values: [Value] { get }
}

private struct AllValuesCalculator<Element: Numeric>: CalculatorIncludedValues {
    var values = [Element]()
    func sum() -> Element {
        return values.reduce(0, { $0 + $1 })
    }
}

private func testAllValuesCalculator() {
    let c = AllValuesCalculator(values: [1, 2, 3, 4, 5])
    print("\(c.sum())")
}

private protocol Term {
    associatedtype Value
    var value: Value { get }
    //SelfをTermと書くとコンパイルエラー。
    static func +(lhs: Self, rhs: Self) -> Self
}

private extension Term {
    var description: String {
        return String(describing: value)
    }
}

private struct MyTerm: Term {
    var value = 0
    //以下のtypealiasはあってもなくても結果に変化は無い。ただしvalueの型とは異なる型を
    //指定するとコンパイルエラーになる。
    //typealias Value = Int
    static func +(lhs: MyTerm, rhs: MyTerm) -> MyTerm {
        return MyTerm(value: lhs.value + rhs.value)
    }
}

//Termはassociatedtypeを使っているため戻り値の型に指定できない。
//しかしジェネリクス型を戻り値に指定してもコンパイルエラーになる。
//private func getZeroTerm<T: Term>() -> T {
//    return MyTerm(value: 0)
//}

private func testMyTerms() {
    let term1 = MyTerm(value: 100),
        term2 = MyTerm(value: 200)
    print("\((term1 + term2).description)")
}

private protocol TermManager {
    associatedtype T
    func sum() -> T
}

private protocol Mapper {
    associatedtype T
    associatedtype U
    func map(_ arg: T) -> U
    //associatedtype無しでprotocolにジェネリックメソッドは宣言できないのでは？
    //正確には宣言したところでprotocolのの要求に従うclassやstructを定義できない。
    //func map<T, U>(_ arg: T) -> U
}

private class MyMapper: Mapper {
    //以下ではprotocolのジェネリックメソッドの要求を満たせない。
    //func map<T, U>(_ arg: T) -> U where T: Integer, U: String {
    //    return arg.description
    //}

    //以下もエラー。
    //func map<T: Integer, U: String>(_ arg: T) -> U {
    //    return arg.description
    //}

    func map(_ arg: Int) -> String {
        return arg.description
    }
}

//Termを型として指定すると以下のコードはコンパイルエラーとなる。
//associatedtypeを含むprotocolに従うclassやstructのプロパティは
//具象的な型を早々に指定するしかないのかもしれない。
//以下の例ではTermと指定したい箇所を全てMyTermにすることでエラーを回避している。
//associatedtypeを使うことでprotocolの宣言に柔軟性を持たせることは可能になるが，
//protocolに従うclassやstructの抽象度は低下する・・・ということだろうか。
private class MyTermManager: TermManager {
    private let terms: [MyTerm?]
    init(terms: [MyTerm]) {
        self.terms = terms
    }
    func sum() -> MyTerm {
        guard var result = terms[0] else {
            return MyTerm(value: 0)
        }
        for index in 1..<terms.count {
            let tmp = result + terms[index]!
            result = tmp
        }
        return result
    }
}

//Mapperを戻り値の型には指定できない。associatedtypeを使っているため。
private func getMapper() -> MyMapper {
    return MyMapper()
}

//getMapper1とgetMapper2はコンパイルに成功するが実体の型ではなくTを返してしまう。
//as!でTに型変換しなければコンパイルに成功しない。
private func getMapper1<T: Mapper>() -> T {
    return MyMapper() as! T
}

private func getMapper2<T>() -> T where T: Mapper {
    return MyMapper() as! T
}

private func testMyMapper() {
    //mapperの型をMapperと明示的に指定するとコンパイルエラーとなる。
    let mapper = getMapper()
    print("\(mapper.map(100))")
}

private func testTermManager() {
    let mn = MyTermManager(terms: [
        MyTerm(value: 100), MyTerm(value: 250), MyTerm(value: 450)
    ])
    print("\(mn.sum().description)")
}

private protocol User {
    var name: String { get set }
    var age: Int { get set }
    var description: String { get }
}

private struct MyUser: User {
    private var userName: String
    private var userAge: Int
    init(name: String, age: Int) {
        userName = name
        userAge = age
        //全てのstored propertyが初期化される前にselfを参照することはできない。
        //self.name = name
        //self.age = age
    }
    var name: String {
        get {
            return userName
        }
        set {
            userName = newValue
        }
    }
    var age: Int {
        get {
            return userAge
        }
        set {
            userAge = newValue
        }
    }
    var description: String {
        return "My name is \(name), I am \(age) years old."
    }
}

private func swapUserName<T: User, U: User>(first: inout T, second: inout U) {
    let tmpName = first.name
    //引数型宣言のT及びUの前にinoutが無いとコンパイルエラーとなる。
    first.name = second.name
    second.name = tmpName
}

private func testGenericsUsers() {
    var u1 = MyUser(name: "foo", age: 20)
    var u2 = MyUser(name: "bar", age: 40)
    swapUserName(first: &u1, second: &u2)
    print("\(u1.description)")
    print("\(u2.description)")
}

private enum TeamType {
    case baseball, soccer
}

private enum TeamError: Error {
    case missingTeam
}

private protocol Team {
    associatedtype Member
    //associatedtype Member: User
    //propertyの場合はsetが指定されていないとoverrideできない。
    var count: Int { get set }
    //func getMemberCount() -> Int
    //subscript(index: Int) -> Member { get }
    func getMember(index: Int) -> Member
}

private class BaseTeam: Team {
    //overrideされる前提のproperty
    var count = 0
    //overrideされる前提のsubscript
    //subscript(index: Int) -> MyUser {
    //    return MyUser(name: "no name", age: -1)
    //}
    //Teamのassociatedtypeが
    //associatedtype Member: User
    //になっているとUserを戻り値に指定できない。
    func getMember(index: Int) -> User {
        return MyUser(name: "no name", age: -1)
    }
}

//Teamのassociatedtypeが以下のようになっている場合，
//associatedtype Member: User
//class BaseballTeam<U: User>の型変数Uを使わず全てUserと記述すると
//protocolに従っていないと見なされてエラーになってしまう。MyUserと記述するぶんには問題無い。
//generic functionの仕様と一貫性が無いように思える。(下記のaddTwoNSNumbers参照)
private class BaseballTeam: BaseTeam {
    private let members: [User]
    init(members: [User]) {
        self.members = members
    }
    override var count: Int {
        get {
            return members.count
        }
        set {
            //This count is effective read-only
        }
    }
    //subscriptはoverrideされない！インスタンスの実体の型ではなくインスタンスを指す変数の型の
    //classで定義されたsubscriptが常に利用されてしまう。subscriptはstaticメソッドのようなものである。
    //subscriptはprotocolに宣言しない方が安全かもしれない。
    //subscript(index: Int) -> U {
    //    return members[index]
    //}
    override func getMember(index: Int) -> User {
        return members[index]
    }
}

private extension Team {
    //subscript形式でインスタンスが参照されたら，
    //実行時のインスタンスの型で定義されたgetMemberメソッドを呼び出す。
    subscript(index: Int) -> Member {
        return getMember(index: index)
    }
}

//戻り値がTeamを継承したassociatedtypeを宣言していないprotocolの型でもエラーとなる。
//ここで返しているBaseTeamはJavaでいうところの抽象クラスみたいなものである。
private func createTeam<U: User>(type: TeamType, members: [U]) throws -> BaseTeam {
    switch type {
    case .baseball:
        return BaseballTeam(members: members)
    default:
        throw TeamError.missingTeam
    }
}

private func testTeamMembers() {
    let members = [
        MyUser(name: "foo", age: 18),
        MyUser(name: "bar", age: 24),
        MyUser(name: "baz", age: 48)
    ]
    guard let team = try? createTeam(type: .baseball, members: members) else {
        print("Missing team")
        return
    }
    print("\(team.count)")
    print("\(team[team.count - 1].description)")
}

//戻り値の型をDとするとコンパイルエラーとなる。
//常に型変数の境界を指定せよということだろうか。
private func addTwoNSNumbers<D: NSNumber>(_ x: D, _ y: D) -> NSNumber {
    return NSNumber(integerLiteral: x.intValue + y.intValue)
}

/**
 * <h2>protocolまとめ</h2>
 * <p>以下の要素はprotocolに定義するとコードが扱いにくくなる恐れがある。<br />
 * 「扱いにくい」とはその後の変更が困難になる・要らないはずのコードを書くことを強要される・
 * 可読性が低下するといったことを指す。</p>
 * 
 * <h3>associatedtype</h3>
 * protocolの型を引数・戻り値・変数・定数の型として指定することができなくなる。
 * associatedtypeの型に境界を指定した場合，さらに難解な挙動を示すようになる。
 *
 * <h3>convenienceではないinit</h3>
 * protocolを実装するclassで別のinitを定義した際，そのinit内部からprotocolに従って
 * 定義された方のinitを呼び出すことができない。
 *
 * <h3>computedではないproperty</h3>
 * 実装する側でprivateやletを指定できるような状況でも指定することができない。
 * またsetを指定していなければoverrideできない。もっともpropertyをoverrideすること自体
 * 良い考えではない。(getterやsetterをoverrideするようなもの)
 * 
 * <h3>subscript</h3>
 * 実行時のインスタンスの型ではなく変数が指す型のclassで定義されたsubscriptが使われる。
 * func getObj() -> Super { return Sub() }
 * let obj = getObj()
 * let element = obj[0] //Superのsubscriptが参照される。
 * subscriptはextensionに定義する方が安全で柔軟性もあるかもしれない。
 */

//Test functions array
private let sampleFuncs = [
    {
        let calclator = BasicCalculator()
        print("\(calclator.add(1.1, 4.5))")
    },
    {
        let bc = BiCalculator((10, 20))
        print("\(bc.add())")
    },
    testAllValuesCalculator,
    testMyTerms,
    testMyMapper,
    testTermManager,
    testGenericsUsers,
    testTeamMembers,
    {
        let n1 = NSNumber(integerLiteral: 10)
        let n2 = NSNumber(integerLiteral: 90)
        print("\(addTwoNSNumbers(n1, n2).description)")
    }
]

// Generics method and function practice

private enum EaterType {
    case human, dog, cat
}

private protocol Food {
    var description: String { get }
}

// associatedtypeを有効にする場合，Eaterを実装するclass及びstructでeatの引数の型に
// どんな型でも指定できる。associatedtype関連の制約はそのあたりが自由になりすぎないように
// するためのものだろうか？
private protocol Eater {
    //associatedtype Food
    func eat(_ food: Food) -> String
}

private struct Rice: Food {
    var description: String {
        return "gohan"
    }
}

private struct DogFood: Food {
    var description: String {
        return "dog food"
    }
}

private struct Nekokan: Food {
    var description: String {
        return "nekodaisuki"
    }
}

private struct Human: Eater {
    func eat(_ food: Food) -> String {
        return "kuchakucha \(food.description)"
    }
}

private struct Dog: Eater {
    func eat(_ food: Food) -> String {
        return "bakubaku \(food.description)"
    }
}

private struct Cat: Eater {
    func eat(_ food: Food) -> String {
        return "mogmog \(food.description)"
    }
}

// 次の宣言ではコンパイルエラーになる。
// private func makeEater<T: Eater>(type: EaterType) -> T
// 一方次の宣言ではコンパイルエラーにはならない。
// private func makeEater(type: EaterType) -> Eater
// ここでEaterがassociatetypeを含む場合，型パラメータを使わなければならない。
// しかし上記の通り，型パラメータを使った戻り値を返す関数の宣言はコンパイルエラーとなる。
private func makeEater(type: EaterType) -> Eater {
    switch type {
    case .human:
        return Human()
    case .dog:
        return Dog()
    case .cat:
        return Cat()
    }
}

private func testGenericsFunction() {
    let human = makeEater(type: EaterType.human)
    let dog = makeEater(type: EaterType.dog)
    let cat = makeEater(type: EaterType.cat)
    print("\(human.eat(Rice()))!")
    print("\(dog.eat(DogFood()))!")
    print("\(cat.eat(Nekokan()))!")
}

// associated typeとファクトリメソッド

private protocol Stack {
    associatedtype Item
    func push(_ item: Item)
    func pop() -> Item?
}

private class AnyStack<Element>: Stack {
    private var stack = [Element]()
    func push(_ item: Element) {
        stack.append(item)
    }
    func pop() -> Element? {
        return stack.popLast()
    }
}

private class NumberStack<N: Numeric>: Stack {
    private var stack = [N]()
    func push(_ item: N) {
        stack.append(item)
    }
    func pop() -> N? {
        return stack.popLast()
    }
}

private enum StackType {
    case any, number
}

private class StackFactory<S: Stack> {
    static func makeStack(type: StackType) -> S {
        if type == .number {
            return NumberStack<Int>() as! S
        } else {
            return AnyStack<Any>() as! S
        }
    }
}

// TODO: 以下のコードはどうしてもコンパイルエラーになる。
//private func makeStack<T: Stack>(type: StackType) -> T {
//    if type == .number {
//        return NumberStack()
//    } else {
//        return AnyStack()
//    }
//}

private struct MyElement {
    var name: String
}

private protocol MyContainer {
    associatedtype Item
    var count: Int { get }
    subscript(index: Int) -> Item { get }
    
    associatedtype Iterator: IteratorProtocol
    // 現在のコンパイラでは今はまだエラーになる。
    //associatedtype Iterator: IteratorProtocol where Iterator.Item == Item
    func makeIterator() -> Iterator
}

private class SampleContainer: MyContainer {
    private let items: [Int]
    init(items: [Int]) {
        self.items = items
    }
    var count: Int {
        return items.count
    }
    subscript(index: Int) -> Int {
        return items[index]
    }
    func makeIterator() -> IndexingIterator<[Int]> {
        return items.makeIterator()
    }
}

// やはり以下のコードはコンパイルエラーになる。
//private func makeSampleContainer() -> MyContainer {
//    return SampleContainer(items: [1, 2, 3, 4, 5])
//}

struct ReconsiderationGenerics {
    static func main() {
        //sampleFuncs.forEach { $0() }
        testGenericsFunction();
    }
}
