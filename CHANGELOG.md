#Changes

## 1.1

Transaction methods created to read and write data. Use read transaction method to fetch and update UI and write transaction method to save data. Everything else remain the unchanged.

### Write

To write a data use **transaction** class method, wrap all you code inside the closure. The closure comes with a context, you can make use of that context to do your core data manipulations. This context is a created in Private Thread and its parent context is main context.

```swift
KarthVader.transaction { (context) -> () in
	context.parse(response as! JSONArray, type: Tweet.self)
	context.commit()
}
```

### Read

To read we have created a new class method **transactionMain**. Using this method you can get a closure that runs in main thread. Besides this closure also gives you a context, but this context is main context. Use this methods to fetch and update UI.

```swift
KarthVader.transactionMain { [weak self] (context) -> () in
	let objects = context.fetch(Tweet.self)
	/* Reload UI */
}
```

### KarthVaderObject

We made KarthVaderObject as a protocol, from 1.1 onwards you dont need to subclass your managed object. If only you want KarthVader parsing feature you confirm **KarthVaderObject** protocol.
