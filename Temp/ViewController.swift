//
//  ViewController.swift
//  Temp
//
//  Created by Roland on 2018-03-06.
//  Copyright © 2018 MoozX Internet Ventures. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        populateDb()
        basicFetch()
        if let dogResults = fetchWithFilter() {
            update(dogs: dogResults)
            clearDatabase(dogs: dogResults)
        }
    }

    private func populateDb() {
        var name = "Dino"
        let dog = createDog(with: name)
        // To assign to RealmOptional use .value property
        dog.age.value = 2
        
        name = "Fred"
        let image = UIImage(named: "Fred")
        let person = createPerson(with: name, and: image)
        person.dogs.append(dog)
        
        do {
            let realm = try Realm()
            try realm.write {
                // Add to the realm inside a write transaction
                realm.add(person)
            }
        }
        catch {
            print("Error encountered")
        }
    }
    
    private func createDog(with name: String, and age: Int? = nil)-> Dog {
        let dog = Dog()
        dog.name = name
        dog.age.value = age
        return dog
    }
    
    private func createPerson(with name: String, and image: UIImage? = nil)-> Person {
        let person = Person()
        person.name = name
        if let image = image {
            person.picture = UIImageJPEGRepresentation(image, 1.0)
        }
        return person
    }
    
    private func basicFetch() {
        guard let realm = try? Realm() else {
            print("Error")
            return
        }

        let results = realm.objects(Person.self)
        // loop through result set
        for person in results {
            print(#line, person.name)
            print(#line, person.dogs.first?.name ?? "no dog or no name")
        }
    }
    
    private func fetchWithFilter() -> Results<Dog>? {
        guard let realm = try? Realm() else {
            print("Error")
            return nil
        }
        
        let predicate = NSPredicate(format:"age > 1")
        let results = realm.objects(Dog.self).filter(predicate)
        for dog in results {
            print(#line, dog.name ?? "no name set")
        }
        
        return results
    }
    
    private func update(dogs: Results<Dog>) {
        guard let realm = try? Realm() else {
            print(#line, "Error")
            return
        }
        
        do {
            try realm.write {
                for dog in dogs {
                    if let value = dog.age.value {
                        dog.age.value = value + 1
                    }
                }
            }
        }
        catch {
            print(#line, "Error")
        }
    }
    
    private func clearDatabase(dogs: Results<Dog>) {
        for dog in dogs {
            remove(dog: dog)
        }
        removeAllPeople()
    }

    private func remove(dog: Dog) {
        guard let realm = try? Realm() else {
            print(#line, "Error")
            return
        }
        
        do {
            try realm.write {
                realm.delete(dog)
            }
        }
        catch {
            print(#line, "Error")
        }
    }
    
    private func removeAllPeople() {
        guard let realm = try? Realm() else {
            print(#line, "Error")
            return
        }
        
        do {
            try realm.write {
                realm.delete(realm.objects(Person.self))
            }
        }
        catch {
            print(#line, "Error")
        }
    }
}

// Define your models like regular Swift classes
class Dog: Object {
    // Optional String, Date, Data properties built in
    @objc dynamic var name: String? // set to nil automatically
    // RealmOptional properties used to make other types optional.
    // Should always be declared with `let`.
    // No @objc dynamic
    let age = RealmOptional<Int>()
}

class Person: Object {
    @objc dynamic var name = ""
    @objc dynamic var picture: Data? = nil // optionals supported
    let dogs = List<Dog>() // models a one to many relationship
}
