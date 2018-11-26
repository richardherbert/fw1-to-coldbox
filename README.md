# Migrating an FW/1 Application to ColdBox

Sometimes you need to migrate an existing application to a new framework. This can be because your current framework is no longer supported or future development has stopped and you need a feature that isn't supported. Or it could be that you want to concentrate your knowledge and efforts into learning and supporting your applications with one framework. Whatever your reason, transitioning to `ColdBox` can be easy.

Many times it's not possible to "stop the world", rewrite your application from scratch, and then just flip a switch in production and you're done. More often than not it has to be an evolution rather than a revolution. Taking one feature at a time and converting that to the new framework. Deciding which parts of the application to transition, what can be reused and in what order, can be a major task. From my experience it can be best to start from the outer-most edges of any work-flow and move towards the centre or start of any transaction.

This is an example of moving a sample `FW/1` (Framework One) v4.2 application to `ColdBox` v5.2 in small steps. You can either follow along with the narrative, not all the steps are detailed, or checkout the tagged releases at each stage to get the functioning code.

**Assumptions**:

* You are familiar with the command line, `FW/1`, `ColdBox` and `WireBox`
* You have `CommandBox` installed

## Tag v0.1.0 - Setup FW/1 Sample Application

Open your terminal or command line application of choice.

Create and open a directory of your choice:

```
mkdir fw1-to-coldbox
cd fw1-to-coldbox
```

Export the `v4.2.0` tagged release of `FW/1` source code from Github to your new directory:

```
svn export https://github.com/framework-one/fw1/tags/v4.2.0 fw1
```

NOTE: We have used `SVN` here as GitHub doesn't support the `git archive` function.

Remove the files and other sample applications that are not required. This is to just leave the `userManger` sample application:

```
cd fw1
rm -rf css docs introduction skeleton tests
rm -f * .*

cd examples
rm -rf buildurl layouts modular mustache qBall remote render rest skinning subsystems todos userManagerAccessControl userManagerAJAX views wirebox
rm -f *

cd userManager
```

Open `CommandBox` and start up a server:

```
box
server start
```

The server should start and your default browser should open to display the `User Manager` dashboard.

Select all of the options on the menu to familiarise yourself with the application.

## Tag v0.2.0 - Install ColdBox

From your terminal, install `ColdBox` using `CommandBox`:

```
install coldbox
```

Then you'll need to wire in the `ColdBox` framework into the `Application.cfc` methods (checkout the v0.2.0 tagged release) and restart the server.

```
server restart
```

When the server comes back up you should be able to browse the application as before, unchanged. Now both the `FW/1` and `ColdBox` frameworks are in memory but all requests are still being served by `FW/1`.

## Tag v0.3.0 - Migrate User Listing

The first feature for migrating is the listing of users.

NOTE: This sample `FW/1` application has no persistent storage (database) and therefore caches the records within it's own bean factory.

The objective of this migration is to leave the existing `FW/1` views unchanged and create a new model and controllers for the `ColdBox` application. Luckily the convention for `ColdBox` for controllers is `handlers` and for the model it is `models` so we can create these anew without conflicting with the existing `FW/1` application. Once again we can use `CommandBox` to build out the handler.

```
coldbox create handler name="user" actions="index,list,form,delete,save" views=false integrationTests=false
```

Here we've asked `CommandBox` to create a handler with some actions stubbed out but no views or tests.

For the model we'll start by copying over the `user` and `department` beans and services from the `model` directories to the `models` directory. We've copied these files to the root of the `models` directory because it's a `WireBox` convention that means we don't need to worry about configuring `WireBox` in this simple application.

```
cp model/beans/user.cfc models/
cp model/beans/department.cfc models/

cp model/services/user.cfc models/userService.cfc
cp model/services/department.cfc models/departmentService.cfc
```

Then we need to make some changes to these copied `FW/1` services so that they will work in a `ColdBox/Wirebox` application:

* Inject `Wirebox` as the `beanFactory` that the existing application expects
  * `property name='beanFactory' inject='wirebox';`
* Rename the `init` methods to `onDIComplete` to ensure the cached data is populated after `WireBox` has been instantiated
* Change `beanFactory.getBean()` to `beanFactory.getInstance()`
* Change all the `userBean` references to `user` and `departmentBean` to `department`
* Inject `departmentService` into the `userService`
* Remove some unnecessary code references

For our layout we'll copy the `FW/1` default layout over to the default `ColdBox` layout.

```
cp layouts/default.cfm layouts/Main.cfm
```

We need to change the rendering of the content inside the layout from:

```
<div id="primary">
    <cfoutput>#body#</cfoutput>
</div>
```

...to...

```
<div id="primary">
    <cfoutput>#renderView()#</cfoutput>
</div>
```

Just to be sure which framework is rendering what page, we'll add the framework name to each layout.

Now we can look to direct requests from the `FW/1` application to the `ColdBox` application. We do this by looking at the incoming request and deciding which requests to redirect to `ColdBox` and leaving the others carry onto `FW/1`.

```
function onRequestStart( targetPath ) {
    if( url.keyExists( 'fwreinit' ) && url.fwreinit == '1' ) {
        application.cbBootstrap.loadColdbox();
    }

     var actionEventMap = {
        'user.list': 'user.list'
    };

   if( url.keyExists( 'action' ) && actionEventMap.keyExists( url.action ) ) {
        url.event = actionEventMap[ url.action ];

        application.cbBootstrap.onRequestStart( arguments.targetPath );

        return false;
    } else {
        return _get_framework_one().onRequestStart( targetPath );
    }
}
```

Firstly we need see if there was a request to reinitialise the `ColdBox` framework with the convention `fwreinit=1` and if so, reload `ColdBox`.

Secondly we need a map of the `FW/1` actions to listen for and the `ColdBox` event that we now want to service that request. If we get a match on the `url.action` we'll set the `ColdBox` event `url.event` and then stop the application from falling through to the `FW/1` framework as well by returning the request.

We'll be adding to the `actionEventMap` as we migrate this application.

Finally we need to restart the server to ensure all these changes are applied:

```
server restart
```

From now on we can reinitialise the `ColdBox` framework by either adding the `fwreinit=1` name-value pair to the URL or from `CommandBox`:

```
fwreinit
```

## Tag v0.4.0 - Migrate User Deletion

All we need to add is a call to the `userService.delete()` method in the handler `delete` action and relocate back to the user listing page.

Then, to get requests to delete a user to be handled by `ColdBox` rather than `FW/1` we just need to add ` 'user.delete': 'user.delete'` to the `actionEventMap` variable.

NOTE: We now have two frameworks in play within the one application. The `ColdBox` framework now handles the listing and deletion of users from its cached bean factory. The `FW/1` framework handles adding and updating users to its, separate, bean factory.

To illustrate this, try adding or updating a user. You won't see any change in the user listing as this is managed and cached by `ColdBox` whereas the adding and updating is made to the `FW/1` managed cache. If you did want to see the change, just delete the `'user.list': 'user.list'` entry from the `actionEventMap` variable in the `Application.cfc` method `onRequestStart()`. This will allow the user listing requests to be serviced by `FW/1` once again.

## Tag v0.5.0 - Migrate User Addition and Update

Both the adding and updating of a user passes through the `form` action in the `user` handler. The only difference being, of course, the passing of the user ID when updating a user. The `user.form` action gets the user if it can find it, with its associated department, and then displays the form on the page.

```
function form( event, rc, prc ){
	event.paramValue( 'id', '' );

	rc.user = variables.userService.get( rc.id );
	rc.departments = variables.departmentService.list();

	event.setView( "user/form" );
}
```

The `departmentService` is injected into the pseudo constructor of the handler with the `property name='departmentService' inject='departmentService';` line.

The `user.save` action, which the add/update form submits to, gets the user model object and populates it with the `rc` scope variable using the `WireBox` framework supertype method `populateModel()`. The selected department is also associated with the user. Then the user model object is then saved and the request is relocated back to the user listing.

```
function save( event, rc, prc ){
	var user = variables.userService.get( rc.id );

	populateModel( user );

	if( structKeyExists( rc, 'departmentId' ) && len( rc.departmentId ) ) {
		user.setDepartmentId( rc.departmentId );
		user.setDepartment( variables.departmentService.get( rc.departmentId ) );
	}

	variables.userService.save( user );

	relocate( url='index.cfm?action=user.list' );
}
```

NOTE: The `userService.save()` method remains unchanged from the `FW/1` application.

Finally the `actionEventMap` variable in the `Application.cfc` is updated to reroute the `form` and `save` actions to `ColdBox`.

```
var actionEventMap = {
    'user.list': 'user.list',
    'user.delete': 'user.delete',
    'user.form': 'user.form',
    'user.save': 'user.save'
};
```

And that's it!

Obviously there will be more to your application than what has been covered by the migration of this simple `FW/1` application but hopefully this will give you some pointers and guidance on an approach.

## Tag v1.0.0 - Documentation

This README.md documentation.
