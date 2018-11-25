component {
    // copy this to your application root to use as your Application.cfc
    // or incorporate the logic below into your existing Application.cfc

    // you can provide a specific application name if you want:
    //this.name = hash( getBaseTemplatePath() );
    this.name = 'fw1-userManager';

    // any other application settings:
    this.sessionManagement = true;

    // set up per-application mappings as needed:
    this.mappings[ '/framework' ] = expandPath( '../../framework' );
    this.mappings[ '/userManager' ] = getDirectoryFromPath( getCurrentTemplatePath() );

	// COLDBOX STATIC PROPERTY, DO NOT CHANGE UNLESS THIS IS NOT THE ROOT OF YOUR COLDBOX APP
	COLDBOX_APP_ROOT_PATH = getDirectoryFromPath( getCurrentTemplatePath() );
	// The web server mapping to this application. Used for remote purposes or static purposes
	COLDBOX_APP_MAPPING = '';
	// COLDBOX PROPERTIES
	COLDBOX_CONFIG_FILE = '';
	// COLDBOX APPLICATION KEY OVERRIDE
	COLDBOX_APP_KEY = '';

    function _get_framework_one() {
        if ( !structKeyExists( request, '_framework_one' ) ) {

            // create your FW/1 application:
            request._framework_one = new MyApplication();

            // you can specify FW/1 configuration as an argument:
            // request._framework_one = new framework.one({
            //     base : '/app',
            //     trace : true
            // });

            // if you need to override extension points, use
            // MyApplication.cfc for those and then do:
            // request._framework_one = new MyApplication({
            //     base : '/app',
            //     trace : true
            // });

        }
        return request._framework_one;
    }

    function onApplicationStart() {
        // load Colbox framework
        application.cbBootstrap = new coldbox.system.Bootstrap( COLDBOX_CONFIG_FILE, COLDBOX_APP_ROOT_PATH, COLDBOX_APP_KEY, COLDBOX_APP_MAPPING );

        application.cbBootstrap.loadColdbox();

        // load FW/1 framework
        _get_framework_one().onApplicationStart();

        return true;
    }

    public void function onApplicationEnd( struct appScope ) {
		arguments.appScope.cbBootstrap.onApplicationEnd( arguments.appScope );
    }

    function onError( exception, event ) {
        return _get_framework_one().onError( exception, event );
    }

    function onRequest( targetPath ) {
        return _get_framework_one().onRequest( targetPath );
    }

    function onRequestEnd() {
        return _get_framework_one().onRequestEnd();
    }

    function onRequestStart( targetPath ) {
        if( url.keyExists( 'fwreinit' ) && url.fwreinit == '1' ) {
            application.cbBootstrap.loadColdbox();
        }

		var actionEventMap = {
            'user.list': 'user.list',
            'user.delete': 'user.delete'
        };

        if( url.keyExists( 'action' ) && actionEventMap.keyExists( url.action ) ) {
            url.event = actionEventMap[ url.action ];

            application.cbBootstrap.onRequestStart( arguments.targetPath );

            return false;
        } else {
            return _get_framework_one().onRequestStart( targetPath );
        }
    }

    function onSessionStart() {
        application.cbBootStrap.onSessionStart();

        return _get_framework_one().onSessionStart();
    }

    public void function onSessionEnd( struct sessionScope, struct appScope ) {
		arguments.appScope.cbBootStrap.onSessionEnd( argumentCollection=arguments );
    }

    public boolean function onMissingTemplate( template ) {
		return application.cbBootstrap.onMissingTemplate( argumentCollection=arguments );
	}
}
