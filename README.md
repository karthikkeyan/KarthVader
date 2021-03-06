## Overview

KarthVader is a core data wrapper component for iOS and OS X, built to minimize the effort, of a programmers, to work with core data, by taking advantage of Swift 2.0 features. It gives you natural way of interaction with your core data models.

I would really welcome and appericate contributions to this component.

## How To Get Started

## Setup

Before start using KarthVader class, you need to setup the core data file name & object model. Before do any thing with KarthVader you need to give your core data configuration details.

```swift
	var config = KarthVaderConfiguration()
	config.dataModelName = "DataModel"
	config.sqlFileName = "database"

	KarthVader.setConfiguration(config)
```

**Note:** You dont need to include file extension.


## KarthVader

KarthVader is a singleton object, it creates and maintain your managed object contexts. It follows Core Data Stack hierarchy.

<img src="https://github.com/karthikkeyan/KarthVader/blob/master/Arch.jpg" alt="Context Hierarchy" />


## Write

Let see how we usually create an core data object,

```swift
	let context = newWriteContext()
	let user = NSEntityDescription.insertNewObjectForEntityForName("User", inManagedObjectContext: context) as? User
	if let unwrappedUser = user {
		// Set values to your attributes
	}
```

Its annoying, isn't it. Just to create a simple object do we have to write this much code. The worse thing is it not type save, it returns NSManagedObject. We have to type case the object return by this method again.

We have simplifed this process in more natural way,

```swift
	let writeContext = KarthVader.writeContext()

	let user = User(context: writeContext)
```

The changes you made in the **writeContext** remain unsaved untill you call **commit** method.

```swift
	// Example write
	let writeContext = KarthVader.writeContext()

	let user = User(context: writeContext)
	user.name = "Karthik Keyan"
	user.email = "karthikkeyan.balan@gmail.com"

	writeContext.commit()
```

**Note:** KarthVader.writeContext() will create a new context in private queue with KarthVader.manager().mainContext as its parent context.

You can send a completion closer in **commit** method,

```swift
	writeContext.commit { /* Update UI */ }
```

Method **commit()** save recursively throught all its parent context till the persistent store, asynchronously by default. If you want to commit synchronously, send **wait: true** in commit method.

```swift
	writeContext.commit(wait: true) { /* Update UI */ }
```

**Note:** completion closer wont get called in main thread if the commit operation is asynchronous.

Another way,
To write a data use **transaction** class method, wrap all you code inside the closure. The closure comes with a context, you can make use of that context to do your core data manipulations. This context is a created in Private Thread and its parent context is main context.

```swift
KarthVader.transaction { (context) -> () in
	context.parse(response as! JSONArray, type: Tweet.self)
	context.commit()
}
```

## Read

Fetch operation is simplified compared to traditional way, and here it is,

```swift
	let objects = context.objects(User.self)
```

Simple isnt it?. Also you can apply predication, Sorting, limit & offset as well

```swift
	// Predication
	let objects = context.objects(User.self, filter: "age > 26")

	// Sorting
	let objects = context.objects(User.self, filter: "age > 26", sort: ["age" : true])

	// Fetch Limit and Offset
	let objects = context.objects(User.self, filter: nil, sort: ["age" : true], chunk: NSMakeRange(0, 20))
```

**entity:** Object type you want to fetch
**filter:** filter string used as NSPredicate.
**sort:** Key-Bool dictionary, where Bool value represents ascending order. In above example result object will be sorted in ascending order based on there user's age.
**chunk:** Range objects you want to fetch.

Another way,
To read we have created a new class method **transactionMain**. Using this method you can get a closure that runs in main thread. Besides this closure also gives you a context, but this context is main context. Use this methods to fetch and update UI.

```swift
KarthVader.transactionMain { [weak self] (context) -> () in
	let objects = context.fetch(Tweet.self)
	/* Reload UI */
}
```


## JSON

One of the common functionality in any app is, the use of REST APIs, parsing JSON response into object model along with your submodels. KarthVader takes the burden of converting your JSON into core data models.

**Example JSON**

```json
	{
		"user":
		[
	         {
	            "name": "Karthik",
	            "age": 26,
	            "userID": "1",
	            "sex": "male",
	            "following":
	            [
	            	{
	            		"userID": 5,
	            		"name": "Vivek"
	            	}
	            ]
	         },
	         {
	            "name": "Ram",
	            "age": 26,
	            "userID": "2",
	            "sex": "male"
	         },
	         {
	            "name": "Darshan",
	            "age": 28,
	            "userID": "3",
	            "sex": "male"
	         }
	     ]
	}
```


**User Model**

```swift
	class User: KarthVaderObject {

		@NSManaged var age: NSNumber?

		@NSManaged var name: String?

		@NSManaged var gender: String?

		@NSManaged var userID: String?

		@NSManaged var following: NSSet?


		override class func classForKey(key: String) -> KarthVaderObject.Type? {
			if key == "following" {
            	return FollowingUser.self
        	}

        	return nil
		}

		override class func keyForJSONKey(key: String) -> String? {
			if key == "sex" {
            	return "gender"
        	}

        	return nil
    	}

	}
```

**Following User Model**

```swift
	class FollowingUser: KarthVaderObject {

		@NSManaged var name: String?

		@NSManaged var userID: String?

	}
```

And this is how you parse,

```swift
	let userJSON = getUsersList()

	let context = KarthVader.writeContext()
	context.parse(userJSON, type: User.self)
	context.commit()
```

Thas it.

**Sub Model**

In the above example user JSON dictionary have a sub array with a key **following**. It is your's responsible to provide the parse appropriate class type. For the parent dictionaries you have already provide class type, but for the sub-arrays or sub-dictionaries the parser needs to know what type of object(s) is about to be parsed, before is begins iteration.

If you notice User Object, it is overriding a method called **classForKey:**. If your JSON dictionary have a possibility of having a sub-arrays or sub-dictionarys, you should override this method in your model and provide appropriate class type. Otherwise the value this key will be simply ignored.

**Key Mapping**

It is a very common problem that, the keys in REST API response wont match exactly with your model's property. See the above JSON, it contains a key **sex**, but in the **User** model we don't have that property named **sex**, instead we have a property called **gender**. To address this type of issue, just override **keyForJSONKey:** method in your model class and return the appropriate property name. In the above User model we are mapping the JSON key **sex** to **gender** property.

So when the parser coundnt set a value for a key, it gives the model a chance to map a different property of the that key. If your send nil or if you didnt override this method, then the parser will simply ignore it.


[KarthVader]:https://github.com/karthikkeyan/KarthVader
