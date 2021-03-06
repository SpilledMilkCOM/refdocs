# The SOLID Principles

    S – Single-responsibility Principle
    O – Open-closed Principle
    L – Liskov Substitution Principle
    I – Interface Segregation Principle
    D – Dependency Inversion Principle

Michael Feathers introduced the acronymn

## 1. Single-responsibility Principle

    “There should never be more than one reason for a class to change.”

* A **SINGLE** resonsibility for a class.
* If a class is handling many different responsibilities then it may need to change too often based on its underlying framework or needs of the application.
* Leads to better readability and less complexity.

## 2. Open-closed Principle

    “Software entities (classes, modules, functions, etc.) should be open for extension, but closed for modification.”

* Use Dependency Injection or Inheritance for extension.
* If you want flexibity the either inject it or use overrides.

## 3. Liskov Substitution Principle

    “subtypes must be substitutable for their base types”

* Able to replace/substitue subclasses of a base type without the application crashing.
* Make sure that all of the methods implemented in the interface actually **work**, or at the very least don't crash. (see #4 below)

## 4. Interface Segregation Principle

    “Classes that implement interfaces, should not be forced to implement methods they do not use.”
    "Many client-specific interfaces are better than one general-purpose interface."

* If the class is throwing `NotImplemented` exceptions or doing nothing, then maybe rethink those methods or the entire class.

## 5. Dependency Inversion Principle

    “High level modules should not depend on low level modules rather both should depend on abstraction.
    Abstraction should not depend on details; rather detail should depend on abstraction.”

* **INTERFACES!!**

### Reference

* [THE 5 SOLID PRINCIPLES EXPLAINED](https://apiumhub.com/tech-blog-barcelona/solid-principles/#:~:text=The%20SOLID%20Principles%201%20Single-responsibility%20principle.%20%E2%80%9CThere%20should,3%20Liskov%20substitution%20principle.%20...%20More%20items...%20)
* [SOLID Principles — explained with examples](https://medium.com/mindorks/solid-principles-explained-with-examples-79d1ce114ace)
* [Wikipedia - SOLID](https://en.wikipedia.org/wiki/SOLID)
