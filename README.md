Spearal iOS
============

## What is Spearal?

Spearal is a compact binary format for exchanging arbitrary complex data between various endpoints such as Java EE, JavaScript / HTML, Android and iOS applications.

SpearalIOS is the Apple Swift implementation of the Spearal serialization format.

## How to use the library?

### Add the SpearalIOS project to a new XCode workspace

Download the last source release of SpearalIOS [here](https://github.com/spearal/SpearalIOS/releases) and unpack it. Create a new XCode 6.1+ workspace and add a reference to the `path/to/SpearalIOS.xcodeproj` file. Then, create a new iOS project alongside.

You can also add SpearalIOS as a Github submodule in your new workspace.

### Create a SpearalFactory

In each file where you want to use SpearalIOS, type the following import:

````swift
import SpearalIOS
````

To start using the Spearal serialization, create and configure a SpearalFactory:

````swift
let factory:SpearalFactory = DefaultSpearalFactory()
````

To encode data (say a `myObject` object), create a new encoder:

````swift
let output = SpearalNSDataOutput()
let encoder = factory.newEncoder(output, printer: printer)
encoder.writeAny(myObject)
let myEncodedData:NSData = output.data
````

You can then send the encoded data over a network (eg. through HTTP with a NSURLSession).

To decode data, create a new decoder:

````swift
let decoder = factory.newDecoder(SpearalNSDataInput(data: myEncodedData))
let myObject = decoder.readAny()
````

## Exchanging class instances with a Java backend

Let's say you have a Java entity bean as follow:

````java
package com.acme.entities;

// skipped imports...

@Entity
public class Person implements Serializable {

    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;
    private String imageUrl;

    // skipped getters and setters...
}
````

You must first replicate this data model in Swift:

````swift
@objc(Person)
public class Person: SpearalAutoPartialable {

    public dynamic var id:NSNumber?
    public dynamic var name:String?
    public dynamic var imageUrl:String?
}
````

Then, configure your factory so the server-side "com.acme.entities.Person" is mapped to the client-side "Person" class:

````swift
let aliasStrategy = BasicSpearalAliasStrategy(localToRemoteClassNames: [
    "Person": "com.acme.entities.Person"
])
factory.context.configure(aliasStrategy)
````

If all your entities (or beans) use the same package, you can also use closures to configure this translation:

````swift
let aliasStrategy = BasicSpearalAliasStrategy(
    localToRemoteAliaser: { (localName) in
        return "com.acme.entities." + localName
    },
    remoteToLocalAliaser: { (remoteName) in
        // return the package-less remote name...
    }
])
factory.context.configure(aliasStrategy)
````

## Working with partial objects

TODO...

## How to get and build the project?

````sh
$ git clone https://github.com/spearal/SpearalIOS.git
````

Use XCode 6.1+ to build the project.
