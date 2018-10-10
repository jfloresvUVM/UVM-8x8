///////////////////////////////////////////////getStatusAgentes///////////////////////////////////////
//							Luis Manuel Pascoe Bautista								//
//						Controlador Reasignar oportunidades							//
//////////////////////////////////////////////////////////////////////////////////////

public with sharing class ctrl_landing_reasignar_oportunidades {

    //LISTA que Obtiene a los Agentes a los cuales hay que reasignar sus oportunidades al gerente asignado a ellos

    public static  List<Opportunity> ListaOportunidades = new List<Opportunity>();

    @RemoteAction
    public static List<String> updateOportunidadesGerente(String agentesStr){
      List<String> lresults = new List<String>();

        try{
            //Objeto que tendra todos los Ids de los usuarios a cuales hay que quitarles las oportunidades
            List<Id> agentes = New List<Id>();
            //Se hace un parse de texto a Json para obtener a los agentes los cuales hay que reasignar
            List<JSON2Apex> agentesJson = JSON2Apex.parse(agentesStr);
            for (Integer i = 0; i < agentesJson.size(); i++) {
                agentes.add(agentesJson[i].id);
            }
            Id gerenteId =  UserInfo.getUserId();
            //el metodo obtiene todas las oportunidades que tienen asignados y llega por una lista, despues un query los obtiene y los almacena
            List<Opportunity> agentsOpportunities = [select id, OwnerId From Opportunity Where Owner.id IN :agentes];
            //despues se cambia el dueño de las oportunidades para que sea el gerente y asi todas regresen a este
            for(Opportunity opp: agentsOpportunities){
                opp.ownerId = gerenteId;
            }
            //Despues de los cambios a los objetos necesarios se guardan los cambios en la base de datos
            update agentsOpportunities;
            lresults.add('true');
            return lresults;
        }catch(exception e){
            // de igual manera si en algun punto del programa existe algun error, se regresa el objeto vacio para informar el error por medio del regreso de un objeto nulo
            System.debug('Error:'+ e.getMessage());
            lresults.add('false');
            lresults.add(e.getMessage());
            return lresults;
        }
    }

    //Metodo que asigna las oportunidades del Gerente a sus Agentes
    //Este metodo recibe dos parametros que son, una lista de id's de los agentes, y el peso el cual se les asignara en cuanto a oportunidades
    @RemoteAction
    public static List<String> updateOpportunidadesAgentes2(String JsonString, Boolean Filtradas,String Append_query){
        List<String> lresults = new List <String>();

        try{
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
            Id gerenteId = UserInfo.getUserId();
            //String gerenteId = '0051N000004eofDQAQ';
            List<Opportunity> oportunidadesCambiantes = new List<Opportunity>();
            Integer estancia = 0;
            Integer limite = 0;
            System.debug('cantidad de agentes'+idAgente.size());
            String q = 'SELECT id,OwnerId FROM Opportunity where OwnerId =\''+gerenteId+'\'';

            if (Filtradas == true){
              q = q+Append_query;
            }
            oportunidadesCambiantes = database.query(q);
            //NO Existe algun filtro En la lista
            for(Opportunity opp: oportunidadesCambiantes){
                opp.OwnerId = idAgente[estancia];
                if(limite == (Integer.valueOf(oportunidadesPorAgente[estancia]) - 1 )){
                    System.debug('estancias'+ estancia);
                    estancia++;
                    limite = 0;
                }else{
                    limite++;
                }
            }

            System.debug(':::OppsCambiantes:'+oportunidadesCambiantes);

              update oportunidadesCambiantes;
              lresults.add('true');
              return lresults;

        }catch(exception e){
            // de igual manera si en algun punto del programa existe algun error, se regresa el objeto vacio para informar el error por medio del regreso de un objeto nulo
            System.debug(':::Error:'+ e.getMessage());
            lresults.add('false');
            lresults.add(e.getMessage());
            return lresults;
        }
    }

    //Metodo que obtiene las oportunidades del gerente
    @RemoteAction
    public static String getOppGerente(){
        //este metodo recibe el nombre del campus para buscar al Gerente de este
        try{
            // se obtiene el gerente de la tabla Campus Gerente que es un objeto que lista a los campus y sus gerentes unicamente
            Id idGerente =  UserInfo.getUserId();
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
            Id idGerente =  UserInfo.getUserId();
            List<Campus_Gerente__c> campusGerente = [Select Name, Gerente__r.Name, Gerente__c from Campus_Gerente__c Where Gerente__c = :idGerente];
            List<map<String,String>> CampusGerenteStr = New List<map<String,String>>();
            Map<String, String> mapeo = new Map<String, String>();
            mapeo.put('GerenteName', String.valueOf(CampusGerente[0].Gerente__r.Name));
            mapeo.put('Campus', String.valueOf(CampusGerente[0].Name));
            mapeo.put('id', String.valueOf(idGerente));
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
            ///!!!!!!!!!!!!!!!!!!!!!!!!importante, cambiar la parte de arriba para que se pueda hacer dinamico pero ya con los users
            List<UserTerritory2Association> agentes = [SELECT Id, UserId, User.Name, User.Nivel_Asignado__c, User.Funci_n__c, User.Profile.Name , User.IsActive FROM UserTerritory2Association where Territory2.name =:campusName and User.Profile.Name = 'Asesor Educativo UVM'];
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

    // Nueva Funcion para obtener agentes con sus Estatus
    @RemoteAction
    public static List<String> getStatusAgentes(String id_Agente){

      List<Opportunity> opp = [Select id,estatus__c From Opportunity Where OwnerId =: id_Agente];

      List<String> status = new List<String>();

      for(Opportunity s : opp){
        status.add(s.estatus__c);
      }

      System.debug('>>>>Status List:'+status);
      return status;
    }

    //////////


    /////////////////REmote para filtros

    @RemoteAction
    public static List<String> getAgentesFiltros(String pListafiltros){

        //variable donde se guardaran cada uno de los filtros
        List<TorreControlFiltros> datosFiltros = new List<TorreControlFiltros>();

        List <String> setReturnValues = new List<String>();

        datosFiltros = TorreControlFiltros.parse(pListafiltros);
        System.debug(':::DatosFiltors: '+datosFiltros);

        String query_append='';
        String id = String.valueOf(UserInfo.getUserId());
        String q = 'SELECT id,OwnerId FROM Opportunity where OwnerId =\''+id+'\'';
        Integer count_opps = 0;

        //valida si hay filtros en la lista
        if(!datosFiltros.isEmpty()){

            //recorrido de cada uno de los filtros
            for(TorreControlFiltros tc: datosFiltros){

                //armado de query con filtros
                query_append += ' and ' + getOperadorEquivalente(tc.campo.n,tc.operador.name,tc.valor.name,tc.campo.tipo);
            }
        }
        system.debug(':::QUERY APPEND::: ' + query_append);

        setReturnValues.add(query_append);

        if(String.isBlank(query_append) == false){
            System.debug(':::Existen datos query_append: '+query_append);
            q = q+query_append;
            System.debug(':::Query mas query_append: '+q);
        }

        ListaOportunidades = database.query(q);
        for (Opportunity opp: ListaOportunidades){
            count_opps = count_opps+1;
            //ListaFiltradaOportunidades.add(opp);
            //System.debug('Agregado a FilterOpp'+ListaFiltradaOportunidades);


        }
        setReturnValues.add(String.valueOf(count_opps));
        System.debug('::::ReturnValues: '+setReturnValues);
        return setReturnValues;

    }



    //Método para obtener lista de campos en la configuración personalizada Campos Asignacion y asi poder llenar el
    //picklist de campos en la página de asignacion
    @RemoteAction
    public static Map<String,DatosCampos_Wrapper> obtenerMapaOperadores(){

        //Variable que se retornara como resultado y que contendra la lista de campos
        Map<String,DatosCampos_Wrapper> mapaResultdo = new Map<String,DatosCampos_Wrapper>();

        //Obtencion de datos desde la configuración personalizada
        List<campos_landing_assignacion__c> mcs = [Select id,API__c,Tipo__c,Etiqueta__c,Orden__c from campos_landing_assignacion__c];

        //se recorren los registros de la configuración personalizada
        for(campos_landing_assignacion__c ctc: mcs){
            //se agrega al mapa el campo con sus atributos.
            mapaResultdo.put(ctc.API__c, new DatosCampos_Wrapper(ctc.API__c,
                                                                 ctc.Tipo__c,
                                                                 ctc.Etiqueta__c));
        }
        System.debug('>>>Mapa Resultado'+mapaResultdo);

        return mapaResultdo;
    }


    //Método para obtener los operadores basados en que tipo de campos es, esto esta almacenado en una configuracion personalizada
    //llamada operadores torre control
    @RemoteAction
    public static List<MapaOperadores> pruebaOperadores(){
        //variable de resultado
        List<MapaOperadores> resultado = new List<MapaOperadores>();

        //Se obtienen los registros de la configuracion personalizada
        for(OperadoresTorreControl__c conf : [Select id,Name,Operadores__c from OperadoresTorreControl__c]){
            //se inicializa variable para el resultado
            MapaOperadores m1 = new MapaOperadores();
            // se asigna el name
            m1.tipo = conf.Name;
            //for para obtener los operadores basados en el tipo de campo
            for(String fKey: conf.Operadores__c.split(',')){
                MapaValores v1 = new MapaValores();
                v1.name = fKey;
                //se agrega a la lista
                m1.valores.add(v1);
            }
            // se agrega la variable a la lista de resultados
            resultado.add(m1);
        }

        //regresa resultado
        return resultado;
    }


    //Método para obtener el listado de ciertos campos que aparecen como picklist en valor, como el catalogo de campus
    @RemoteAction
    public static Map<String,List<String>> obtenerListadoDeValores(){
        //variable para return con todos los catalogos
        Map<String,List<String>> mapaResultdo = new Map<String,List<String>>();
        system.debug('Entrando a obtenerListadoDeValores');
        //variable resultado
        List<String> lListaCiclos = new List<String>();
        List<String> lListaOrigenes = new List<String>();
        List<String> lListaNivel = new List<String>();
        List<String> lListaCanal = new List<String>();
        List<String> lListaEstatus = new List<String>();
        List<String> lListaAno = new List<String>();

        //Obtener valores de periodo__c
        Schema.DescribeFieldResult fieldResultCanal = Opportunity.Canal__c.getDescribe();
        List<Schema.PicklistEntry> pleCanal = fieldResultCanal.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : pleCanal){
            lListaCanal.add(pickListVal.getLabel());
        }

        //Obtener valores de periodo__c
        Schema.DescribeFieldResult fieldResult = Opportunity.Periodo__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            lListaCiclos.add(pickListVal.getLabel());
        }

        //Obtener valores de Ano_ciclo__c
        Schema.DescribeFieldResult fieldResultAno = Opportunity.Ano_ciclo__c.getDescribe();
        List<Schema.PicklistEntry> pleAno = fieldResultAno.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : pleAno){
            lListaAno.add(pickListVal.getLabel());
        }

        //Obtener valores de origen
        Schema.DescribeFieldResult fieldResultOrigen = Opportunity.Origen__c.getDescribe();
        List<Schema.PicklistEntry> pleOrigen = fieldResultOrigen.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : pleOrigen){
            lListaOrigenes.add(pickListVal.getLabel());
        }
        //Obtener valores de Nivel
        Schema.DescribeFieldResult fieldResultNivel = Opportunity.Nivel_de_Inter_s__c.getDescribe();
        List<Schema.PicklistEntry> pleNivel = fieldResultNivel.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : pleNivel){
            lListaNivel.add(pickListVal.getLabel());
        }

        //Obtener valores de Estatus
        Schema.DescribeFieldResult fieldResultEstatus = Opportunity.Estatus__c.getDescribe();
        List<Schema.PicklistEntry> pleEstatus = fieldResultEstatus.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : pleEstatus){
            lListaEstatus.add(pickListVal.getLabel());
        }


        mapaResultdo.put('Periodo__c', lListaCiclos);
        mapaResultdo.put('Ano_ciclo__c', lListaAno);
        mapaResultdo.put('Origen__c', lListaOrigenes);
        mapaResultdo.put('Estatus__c', lListaEstatus);
        mapaResultdo.put('Nivel__c', lListaNivel);
        mapaResultdo.put('Canal__c', lListaCanal);


        return mapaResultdo;
    }


    //Método para transformar los valores de texto de los operadores en simbolos para el query
    public static String getOperadorEquivalente(String pCampo, String pOperador, String pValor, String pTipo){
        //Mapa para guardar los operadores dependiendo del texto enviado por la pantalla torre de control.
        System.debug('>>>OperadoresEquivalentes'+pCampo+pOperador+pValor+pTipo);
        Map<String,String> lMapaOperadores = new Map<String,String>();
        //variable de retorno
        String filtroArmado = '';

        //obtener expresiones de custom setting Expresiones_Torre_Control__c para crear el filtro
        Expresiones_Torre_Control__c mcs = Expresiones_Torre_Control__c.getValues(pTipo+'-'+pOperador);
        System.debug('mcs Expresiones_Torre_Control__c'+ mcs);
        //creando filtro a base de la expresion y reemplazando valores y campos
        filtroArmado = mcs.Expresion__c;
        filtroArmado = filtroArmado.replaceAll('CAMPO',pCampo);
        filtroArmado = filtroArmado.replaceAll('VALOR',pValor);
        System.debug('>>>>>Filtro Armado:'+filtroArmado);

        return filtroArmado;
    }





    //Clase para agrupar campo con tipo y etiqueta.
    public class DatosCampos_Wrapper{
        public String campo;
        public string tipo;
        public String label;

        public DatosCampos_Wrapper(String pCampo, String pTipo, String pLabel){
            this.campo = pCampo;
            this.tipo =  pTipo;
            this.label = pLabel;
        }
    }

    //Clase para agrupar los resultados al buscar oportunidades.
    public class DatosRetorno_Wrapper{
        public List<Opportunity> lListaOportunidades;
        public String query;

        public DatosRetorno_Wrapper(){
            lListaOportunidades = new List<Opportunity>();
        }
    }

    //clase para agrupar los operadores con tipos
    public class MapaOperadores{
        public String tipo;
        public List<MapaValores> valores = new List<MapaValores>();
    }

    //clase para agrupar los operadores con tipos
    public class MapaValores{
        public String name;
    }

}