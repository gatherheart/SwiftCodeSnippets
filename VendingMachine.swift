import Foundation

class Drink {

    enum Condition: String {
        case notExpired, expired
        case sold
    }
    
    let name: String
    var amount: Int = 10
    var condition: Condition = .notExpired
    static var price: Int = 0
    
    init(name: String) {
        self.name = name
    }
}

class Coke: Drink {
    
    init() {
        super.init(name: "Coke")
        self.amount = 100
        Coke.price = 400
    }
}

class Customer {
    var budget: Int = 100
}

class VendingMachine {
    
    enum StateOfDrink: String {
        case outOfStock
        case inStock
    }
    
    var stateOfDrink: [ObjectIdentifier: StateOfDrink] = [:]
    var drinks: [ObjectIdentifier: Array<Drink>] = [:]
    
    init() {
        stateOfDrink[ObjectIdentifier(Coke.self)] = .inStock
        drinks[ObjectIdentifier(Coke.self)] = (0..<10).map { _ in Coke.init() }
    }
    
    // monster method
    func getDrink<T: Drink>(drinkType: T.Type, numberOfDrink: Int, customer: Customer) -> [Drink] {
        var drinksForCustomer: [Drink] = []

        // check drinks condition
        for drink in self.drinks[ObjectIdentifier(drinkType)]! {
            if drink.condition == .notExpired {
                drinksForCustomer.append(drink)
                drink.condition = .sold
            }
        }

        // pay for the drinks
        customer.budget -= numberOfDrink * self.price(of: drinkType)
        
        // if there is not enough drinks for the order
        if self.drinks[ObjectIdentifier(drinkType)]!.count < numberOfDrink {
            // set sold out for the drinks
            self.stateOfDrink[ObjectIdentifier(drinkType)] = .outOfStock
            // give the customer change back
            let change = (numberOfDrink - drinks.count) * self.price(of: drinkType)
            customer.budget += change
        }

        // remove expired drinks
        self.drinks[ObjectIdentifier(drinkType)] = self.drinks[ObjectIdentifier(drinkType)]!.filter { $0.condition == .notExpired }

        return drinksForCustomer
    }
    
    func price<T: Drink>(of: T.Type) -> Int {
        return T.price
    }
    
}

print(VendingMachine().getDrink(drinkType: Coke.self, numberOfDrink: 10, customer: Customer()).map { $0.name })
