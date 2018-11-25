/**
* I am a new handler
*/
component{
	property name='userService' inject='userService';

	// OPTIONAL HANDLER PROPERTIES
	this.prehandler_only 	= "";
	this.prehandler_except 	= "";
	this.posthandler_only 	= "";
	this.posthandler_except = "";
	this.aroundHandler_only = "";
	this.aroundHandler_except = "";
	// REST Allowed HTTP Methods Ex: this.allowedMethods = {delete='POST,DELETE',index='GET'}
	this.allowedMethods = {};

	/**
	IMPLICIT FUNCTIONS: Uncomment to use
	function preHandler( event, rc, prc, action, eventArguments ){
	}
	function postHandler( event, rc, prc, action, eventArguments ){
	}
	function aroundHandler( event, rc, prc, targetAction, eventArguments ){
		// executed targeted action
		arguments.targetAction( event );
	}
	function onMissingAction( event, rc, prc, missingAction, eventArguments ){
	}
	function onError( event, rc, prc, faultAction, exception, eventArguments ){
	}
	function onInvalidHTTPMethod( event, rc, prc, faultAction, eventArguments ){
	}
	*/

	/**
	* index
	*/
	function index( event, rc, prc ){
		event.setView( "user/index" );
	}

	/**
	* list
	*/
	function list( event, rc, prc ){
		rc.data = variables.userService.list();

		event.setView( "user/list" );
	}

	/**
	* form
	*/
	function form( event, rc, prc ){
		event.setView( "user/form" );
	}

	/**
	* delete
	*/
	function delete( event, rc, prc ){
        variables.userService.delete( rc.id );

		relocate( url='index.cfm?action=user.list' );
	}

	/**
	* save
	*/
	function save( event, rc, prc ){
		event.setView( "user/save" );
	}
}
