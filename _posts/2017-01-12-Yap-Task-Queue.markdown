---
title: YapDatabase Task Queue
layout: post
date: 2017-01-12 14:47:29
tags: swift open source ios yapdatbase yap queue
---

In an attempt to make [ChatSecure](https://chatsecure.org) more asynchronous it needed a way to ensure messages are sent even if the conditions aren't appropriate at the moment the send button is pressed. 

In the past messages were sent over the XMPP stream and forgotten. We would block if the stream wasn't connected and forced the user to connect manually. This isn't great experience on mobile devices where network state can change. We wanted [ChatSecure](https://chatsecure.org) to behave more like iMessage. We also wanted to make sure we could guarantee that a message intended to be sent using [OMEMO](https://conversations.im/omemo/) or [OTR](https://otr.cypherpunks.ca/) used the proper encryption method. This means in the case of OTR we need to create a session and ensure the contact is ready to receive the message. And for OMEMO we need to fetch pre-keys and prepare sessions with every device.

ChatSecure uses [YapDatabase](https://github.com/yapstudios/YapDatabase) extensively to manage application state and storage (except for a few items in the key chain). YapDatabase recently added [ActionManager](https://github.com/yapstudios/YapDatabase/tree/master/YapDatabase/Extensions/ActionManager) but it wasn't quite what we needed and the block API didn't fit our needs easily.

## Solution

[YapTaskQueue](https://github.com/davidchiles/YapTaskQueue) allows us a single object that is able to handle sending all (text) messages on a first in first out persistent queue.

### How it works

#### First the setup:

{% highlight swift %}
let database = YapDatabase(path: path)
let handler = //Some object that conforms to YapTaskQueueHandler
do {
	let broker = try YapTaskQueueBroker.setupWithDatabase(database, name: "handlerName", handler: handler) { (queueName) -> Bool in
        // return true here if it's a queue that this handler understands and 'handles'
        return true
}
} catch {
	
}
{% endhighlight %}

The handler needs to implement one function:

```swift
func handleNextItem(action:YapTaskQueueAction, completion:(success:Bool, retryTimeout:NSTimeInterval)->Void)
```

After an action is complete just call the completion closure whether it was successful or not and if not how long before the queue should retry it. Since it's a first in first out the queue blocks until the action at the tip is marked as completed or manually removed.

The queue itself automatically removes a task if it's completed successfully.

#### Second create an action:

Then Create an object that conforms to `YapTaskQueueAction` and save it to the database. This object should contain all necessary data to perform the action and know which queue it belongs to.

```swift
class Action:NSObject,NSCoding {
	let actionKey:String
	let actionCollection:String

	let text:String
	let buddyId:String
	let date:NSDate
	...
}

extension Action:YapTaskQueueAction {
	/// The yap key of this item
    func yapKey() -> String {
    	return self.actionKey
	}
    
    /// The yap collection of this item
    func yapCollection() -> String {
    	return self.actionCollection
    }
    
    /// The queue that this item is in.
    func queueName() -> String {
    	return self.buddyId
    }
    
    /// How this item should be sorted compared to other items in it's queue
    func sort(otherObject:YapTaskQueueAction) -> NSComparisonResult {
    	if let otherAction = otherObject as? Action {
    		return self.date.compare(otherAction.date)
    	}
    	return .OrderedSame
    }
}
```



### Conclusion

This setup is pretty straight forward and limits all the logic to handle an action to a single object. In our case this object knows how to prepare the necessary cryptographic session. It also confines the places that errors are handled and associated with a message.

### Next Steps

We did run into some issues where one action was stuck in the queue and ended up blocking any other action in that queue. But this was resolved by better error handling. There were some error cases that weren't properly being sent back to the queue handler.

It would also be great if the queue supported other methods like last in first out. In some situations you may not be interested in handling all actions sequentially. In this case it would be nice if the queue was concurrent.

