/**
* I am a new handler
*/
component{
	property name='userService' inject='userService';
	property name='departmentService' inject='departmentService';

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
		event.paramValue( 'id', '' );

		rc.user = variables.userService.get( rc.id );
        rc.departments = variables.departmentService.list();

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
		var user = variables.userService.get( rc.id );

		populateModel( user );

		if( structKeyExists( rc, 'departmentId' ) && len( rc.departmentId ) ) {
            user.setDepartmentId( rc.departmentId );
            user.setDepartment( variables.departmentService.get( rc.departmentId ) );
        }

		variables.userService.save( user );

		relocate( url='index.cfm?action=user.list' );
	}
}
