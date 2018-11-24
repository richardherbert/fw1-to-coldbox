component {
	property name='beanFactory' inject='wirebox';
	variables.departments = { };

    function onDIComplete() {
		var dept = "";

		// since services are cached department data we'll be persisted
		// ideally, this would be saved elsewhere, e.g. database

		// FIRST
		dept = variables.beanFactory.getInstance( "department" );
		dept.setId("1");
		dept.setName("Accounting");

		variables.departments[dept.getId()] = dept;

		// SECOND
		dept = variables.beanFactory.getInstance( "department" );
		dept.setId("2");
		dept.setName("Sales");

		variables.departments[dept.getId()] = dept;

		// THIRD
		dept = variables.beanFactory.getInstance( "department" );
		dept.setId("3");
		dept.setName("Support");

		variables.departments[dept.getId()] = dept;

		// FOURTH
		dept = variables.beanFactory.getInstance( "department" );
		dept.setId("4");
		dept.setName("Development");

		variables.departments[dept.getId()] = dept;

        return this;
    }

    function get( id ) {
        var result = "";
        if ( len( id ) && structKeyExists( variables.departments, id ) ) {
            result = variables.departments[ id ];
        } else {
            result = variables.beanFactory.getInstance( "department" );
        }
        return result;
    }

    function list() {
        return variables.departments;
    }

}
