//////////////////////////////////////////////////////////////////////////////////////
//							Luis Manuel Pascoe Bautista								//
//						Controlador Reasignar oportunidades							//
//////////////////////////////////////////////////////////////////////////////////////

public with sharing class ctrl_landing_reasignar_oportunidades {
    //Metodo que Obtiene a los Agentes a los cuales hay que reasignar sus oportunidades al gerente asignado a ellos
    @RemoteAction
	public static Boolean updateOportunidadesGerente(String agentesStr){
        try{
            //Objeto que tendra todos los Ids de los usuarios a cuales hay que quitarles las oportunidades
            List<Id> agentes = New List<Id>();
            //Se hace un parse de texto a Json para obtener a los agentes los cuales hay que reasignar
            List<JSON2Apex> agentesJson = JSON2Apex.parse(agentesStr);
            for (Integer i = 0; i < agentesJson.size(); i++) {
                agentes.add(agentesJson[i].id);
            }
            Id gerenteId =  '0051N000004eofDQAQ';
            //el metodo obtiene todas las oportunidades que tienen asignados y llega por una lista, despues un query los obtiene y los almacena
            List<Opportunity> agentsOpportunities = [select id, OwnerId From Opportunity Where Owner.id IN :agentes];
            					System.debug('Antes de cambiar el dueño '+ agentsOpportunities);
            //despues se cambia el dueño de las oportunidades para que sea el gerente y asi todas regresen a este
            for(Opportunity opp: agentsOpportunities){
                opp.ownerId = gerenteId;
            }
            					System.debug('Despues de cambiar el dueño '+ agentsOpportunities);
            //Despues de los cambios a los objetos necesarios se guardan los cambios en la base de datos
            //update agentsOpportunities;
            return true;
        }catch(exception e){
            // de igual manera si en algun punto del programa existe algun error, se regresa el objeto vacio para informar el error por medio del regreso de un objeto nulo
            System.debug('Error:'+ e.getMessage());
            return false;
        }
    }

    //Metodo que asigna las oportunidades del Gerente a sus Agentes
    //Este metodo recibe dos parametros que son, una lista de id's de los agentes, y el peso el cual se les asignara en cuanto a oportunidades
    @RemoteAction
	public static void updateOpportunidadesAgentes(String JsonString){
        //Se hace un parse de texto a Json para obtener a los agentes los cuales hay que reasignar
        List<JSON2Apex> updateInfoJson = JSON2Apex.parse(JsonString);
        //Se crean dos listas que contendran la informacion necesaria para poder procesar los updates
        List<Integer> oportunidadesPorAgente = new List<Integer>();
        List<Id> idAgente = new List<Id>();
        //Se recorre la informacion contenida en el json y se agrega a las listas pero se filtran los contenidos que tienen 0 nuevos updates
        for (Integer i = 0; i < updateInfoJson.size(); i++) {
            if( Integer.valueOf(updateInfoJson[i].opp) > 0){
                idAgente.add(updateInfoJson[i].id);
                oportunidadesPorAgente.add(Integer.valueOf(updateInfoJson[i].opp));
            }
        }
        //String gerenteId = UserInfo.getUserId();
        System.debug(oportunidadesPorAgente);
        String gerenteId = '0051N000004eofDQAQ';
        List<Opportunity> oportunidadesCambiantes = [select id, OwnerId From Opportunity Where Owner.id = :gerenteId];
        Integer estancia = 0;
        Integer limite = 0;
        for(Opportunity opp: oportunidadesCambiantes){
            opp.OwnerId = idAgente[estancia];
            if(limite == (Integer.valueOf(oportunidadesPorAgente[estancia]) - 1 )){
                estancia++;
                limite = 0;
            }else{
                limite++;
            }
        }
        //update oportunidadesCambiantes;
    }

    //Metodo que obtiene las oportunidades del gerente
    @RemoteAction
	public static String getOppGerente(){
        //este metodo recibe el nombre del campus para buscar al Gerente de este
        try{
            // se obtiene el gerente de la tabla Campus Gerente que es un objeto que lista a los campus y sus gerentes unicamente
            Id idGerente =  '0051N000004eofDQAQ';
            //Id idGerente = UserInfo.getUserId();
            // despues se obtiene el numero de opportunidades que este gerente posee
        	List<SObject> gerenteOpps = [select Count(id) From Opportunity Where Owner.id = :idGerente];
            // Se regresa el numero obtenido de la consulta anterior
        	return String.valueOf(gerenteOpps[0].get('expr0'));
        }catch(exception e){
            // de igual manera si en algun punto del programa existe algun error, se regresa el objeto vacio para informar el error por medio del regreso de un objeto nulo
            System.debug('Error:'+ e.getMessage());
            return null;
        }
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Metodo que obtiene el nombre del gerente y su campus
    @RemoteAction
	public static List<map<String,String>> getNombreCampusGerente(){
        //este metodo recibe el nombre del campus para buscar al Gerente de este
        try{
            Id idGerente =  '0051N000004eofDQAQ';
            List<Campus_Gerente__c> campusGerente = [Select Name, Gerente__r.Name, Gerente__c from Campus_Gerente__c Where Gerente__c = :idGerente];
            List<map<String,String>> CampusGerenteStr = New List<map<String,String>>();
            Map<String, String> mapeo = new Map<String, String>();
            mapeo.put('GerenteName', String.valueOf(CampusGerente[0].Gerente__r.Name));
            mapeo.put('Campus', String.valueOf(CampusGerente[0].Name));
            CampusGerenteStr.add(mapeo);
            return CampusGerenteStr;
        }catch(exception e){
            // de igual manera si en algun punto del programa existe algun error, se regresa el objeto vacio para informar el error por medio del regreso de un objeto nulo
            System.debug('Error:'+ e.getMessage());
            return null;
        }
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    //
    //Función que ayuda a regresar los Agentes por el  gerente y su campus
    @RemoteAction
	public static List<map<String,String>> getAgentes(String campusName){
        try{
            Id gerenteId = UserInfo.getUserId();
            String nombreDeCampus = [select name from Campus_Gerente__c where name = :campusName].name;
            List<UserTerritory2Association> agentes = [SELECT UserId, User.Name, User.IsActive FROM UserTerritory2Association Where Territory2.Name = :campusName And User.Funci_n__c like '%Educativo%'];
            //System.debug(agentes[0].User.isActive);
            //Despues se crea el objeto que se regresara en forma de un arreglo con un mapeo del objeto para obtener los usuarios como se necesitan tener
            List<map<String,String>> resultados = new List<map<String,String>>();
            //se crea una variable que tendra el mapeo de las propiedades de los usuarios
            map<String,String> mapeo = new Map<String, String>();

            for (UserTerritory2Association usr: agentes) {
                //Se inicializa el objeto mapeo como una nueva instancia cada vez para vaciar su contenido y crear una instancia que apunte a un espacio de memoria diferente
                mapeo = new Map<String, String>();
                //se ingresan los valores dentro del mapa con sus respectivas llaves
                mapeo.put('id', String.valueOf(usr.UserId));
                mapeo.put('name', String.valueOf(usr.User.Name));
                mapeo.put('status', String.valueOf(usr.User.IsActive));
                //se obtiene el numero de oportunidades asignadas a cada agente en cada iteracion para saber cuantas oportunidades tiene este
                List<SObject> ConteoOportunidades = [Select Count(id) From Opportunity Where OwnerId = :usr.UserId];
                // al igual que las demas variables se regresa el conteo de sus oportunidades con su llave
                mapeo.put('opp', String.valueOf(ConteoOportunidades[0].get('expr0')));
                //se agrega el mapeo del objeto usuario a la lista que contiene a los demas usuarios mapeados
                resultados.add(mapeo);
            }
            //se regresa el arreglo de mapeos  de los usuarios para trabajar con ellos desde el front end
            return resultados;
        }catch(exception e){
            // al igual que en los demas metodos se usa try y catch para evitar errores de runtime e identificarlos
            System.debug('Error:'+ e.getMessage());
            return null;
        }
	}
}
