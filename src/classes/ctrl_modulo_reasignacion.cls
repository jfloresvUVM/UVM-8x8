//////////////////////////////////////////////////////////////////////////////////////
//                         Juan Manuel Alcantara Pineda                             //
//                      Controlador Modulo Reasingacion                             //
//////////////////////////////////////////////////////////////////////////////////////

public with sharing class ctrl_modulo_reasignacion {
//Variable global que obtiene el id del Gerente.	
	public static Id gerenteId = UserInfo.getUserId();
	//Query Previa comentada, se cambio por la actial (Query definida para traer diferentes oportunidades dependiendo la visibilidad).
	//  public static String q_opp_string = 'select Id, Owner.Name from Opportunity where Owner.Name not in ( \'Asesor Call Center UVM\',\'Call Center\', \'Asesor Educativo Online\' )';
	public static String q_opp_string = 'select Id,ID_Salesforce__c, Owner.Name,Periodo__c, Ano_ciclo__c, Contacto__r.Name,Estatus__c, Tipificaci_n__c, Programa_de_Inter_s__r.name from Opportunity where Oportunidad_pertenece_a__c not in ( \'Asesor Call Center UVM\',\'Call Center\', \'Asesor Educativo Online\' )';

	/////////Metodo para obternet las Oportunidades y Mostrarlas en una tabla///////////	
	@RemoteAction
	public static List<Opportunity> get_tableOpps(String pExt,String query){

		//Se declaran lista para obtener las oportunidades
		List <Opportunity> oportunidadesCambiantes = new List <Opportunity>();
		List<Opportunity> table_opps =  new List<Opportunity>();
		//Se obtiene el Id del Campus previamente obtenido en la funcion de (OBTENER VISIBILIDAD)
		String lcampus_ext = pExt;
		String queryOpps = q_opp_string +' and Campus__c in ('+lcampus_ext+')';
		//Si el query viene lleno, se agrega condiciones de filtrado.
		if(query!= null || query!= ''){
			queryOpps = queryOpps + query;
		}
		//Se declara una nueva lista de oportunidades.
		List<Opportunity> opp = new List<Opportunity>();
		//Se ejecuta el query y se obtienen las oportunidades.
		//Limite de 2000
		queryOpps = queryOpps + ' Limit 2000';
		oportunidadesCambiantes = database.query( queryOpps );
		//Regreso las oportunidades
		return oportunidadesCambiantes;

	}
	/////////Fin del Metodo para obternet las Oportunidades y Mostrarlas en una tabla///////////	

	//////// Metodo para obtener las oportunidades, y los datos del gerente /////////////////////////
	@RemoteAction
	public static Map<String,String> get_visibilidadCampus(){

		//Se declaran las Listas y Mapas para guardar los resultados
		Map <String,String> lresults_campo = new Map<String,String>();
		List <String> lresults_territory = new List<String>();
		//Se ejecuta un query para obtenter los Mapas del Campus.
		List<UserTerritory2Association> lista_campus = [	SELECT Id, UserId, User.Name, Territory2.Name, User.Nivel_Asignado__c, User.Funci_n__c, User.Profile.Name , Territory2.ID_Externo__c  FROM UserTerritory2Association
		where UserId = :gerenteId];

		System.debug('::::lista_campus'+lista_campus);
		
		//Se Recorre la lista para asociar los campos requeridos al resultado final
		for(UserTerritory2Association ut : lista_campus){

			//Se agregan los campos a un Mapa
			lresults_campo.put('username',ut.User.Name);
			lresults_campo.put('territory_name',ut.Territory2.Name);
			lresults_campo.put('profile_name',ut.User.Profile.Name);
			//Se agrega el terrytorio a una lista de Resultados para su posterior uso
			String lterritory_q = '\''+ut.territory2.ID_Externo__c+'\'';
			lresults_territory.add(lterritory_q);

		}
		//Se encadenan la posible seleccion de MULTIPLES territorios.
		String lterritory_ext = '';
		lterritory_ext += String.join(lresults_territory, ',');
		lresults_campo.put('territory_ext',lterritory_ext);


		// Se declaran nuevas Listas de campus
		List <Account> campus = new List <Account>();
		List <String> lresults_campusIds = new List<String>();
		//Query String para obternet el id del campus en base al territorio del agente.
		String q_campus = 'select Id, Name, ID__c from Account where RecordType.Name = \'Campus UVM\' and ID__c in ('+lterritory_ext+')';
		System.debug('::::q_campus'+q_campus);
        campus = database.query( q_campus );

		System.debug('>>>Campus:'+campus);

		for(Account a : campus){
			//Se recorre la cuenta para obternet los campos necesarios para el arreglo final
			String lcampus_q = '\''+a.Id+'\'';
			lresults_campusIds.add(lcampus_q);
		}
		//Se encadena la posible seleccion de MULTIPLES campus
		String lcampus_ext = '';
		lcampus_ext += String.join(lresults_campusIds, ',');
		lresults_campo.put('campus_ext',lcampus_ext);


		//Se declaran nuevas listas para obtener el conteo de Opportunidades.
		List <Opportunity> oportunidadesCambiantes = new List <Opportunity>();
		List <Opportunity> opp = new List <Opportunity>();
		//Se agrega el id del campus obtenido previamente.
		String q_opps = q_opp_string + ' and Campus__c in ('+lcampus_ext+') Limit 2000';
		System.debug('>>>>QueryOpps: '+q_opps);
		//Se ejecuta el query y se guarda en la lista.
		oportunidadesCambiantes = database.query( q_opps );
		System.debug('>>>>OppsCambiantes' + oportunidadesCambiantes);
		//Se obtiene el COUNT o el tamaño de las oportunidades para tener la cantidad.
		lresults_campo.put('oppCount',String.valueOf(oportunidadesCambiantes.size()));
		System.debug('>>>lresults' + lresults_campo);
		//Se regresa la lista con Valores de GERENTE,CAMPO Y CONTEO DE OPPS.
		return lresults_campo;

	}
	//////// FIN del Metodo para obtener las oportunidades, y los datos del gerente /////////////////////////


	//////// Metodo para obtener las Agentes  /////////////////////////

	@RemoteAction
	public static List<Map<String,String>> obtenerAgentes(String p_campus){
		//Se declran listas del tipo Terrytory para Obtener los Agentes por Territorio
		List <UserTerritory2Association> territory_agents = new List<UserTerritory2Association>();
		List <map<String,String>> lresults = new List<map<String,String>>();
		//Se ejecuta el query con el cmapo id obtenido anteriormente.
		String q_agents = 'SELECT Id, UserId, User.Name FROM UserTerritory2Association where Territory2.ID_Externo__c in ('+p_campus+')';
		System.debug( '>>>QueryAgentes_' + q_agents );
		territory_agents = database.query( q_agents );
		//Se recorre la lista de los agentes.
		for(UserTerritory2Association u : territory_agents){
			//Se ponen los valores en un mapa.
			Map <String,String> agents = new Map <String,String>();
			agents.put('id',u.UserId);
			agents.put('name',u.User.Name);
			lresults.add(agents);
		}

		System.debug('>>>Results Obtener Agentes: '+lresults);
		//Se regresa la lista de resultados.
		return lresults;

	}
	//////// FIN del Metodo para obtener las Agentes  /////////////////////////


	/////// Metodo para REasingar las Opportunidades /////////////////////////
	@RemoteAction
	public static List<String> updateGerenteOpps(String agente_id, String Json_opps){

		//Se declaran las listas de oportunidades
		List<Opportunity> opp = new List<Opportunity>();
		List<String> status = new List<String>();
		List<JSON2Apex> updateInfoJson = JSON2Apex.parse(Json_opps);
		//Se crean dos listas que contendran la informacion necesaria para poder procesar los updates
		List<Id> idOpp = new List<Id>();
		//Se recorre la informacion contenida en el json y se agrega a las listas pero se filtran los contenidos que tienen 0 nuevos updates
		for (Integer i = 0; i < updateInfoJson.size(); i++) {
		
			idOpp.add(updateInfoJson[i].id);
					
		}

		System.debug(':::IdOp: '+idOpp);
		//Se obtienen las oportunidades que se encuenttran en la lista de ids
		for(Opportunity s : [SELECT id,ownerId from Opportunity where id in :idOpp]){ opp.add(s); }

		System.debug('OppsAfter: '+opp);
		//Se cenapsula el metodo en yn TRY para obtener Excepciones o errorres.
		try{
			//Se cambia el owner de cada lista
			for(Opportunity o: opp){ o.ownerId = agente_id; }
			System.debug(':::OppChanged '+opp);

			//Se actualiza la lsita de oportuniades
			//update opp;
			//status.add('true');

		}catch(exception e){
				//Si exixte una excepcion de Error se regresa con estatus false.
				System.debug('Error:'+ e.getMessage());

				status.add('false');
				status.add(e.getMessage());
		}
		//Se regresa la lista con los estatus.
		return status;

	}

	/////// Metodo para REasingar las Opportunidades /////////////////////////


	/////////////////MEtodo remote para filtros///////////////////////////////7

	@RemoteAction
	public static List<String> obtenerGerenteOppFiltradas(String pListafiltros,String pExt){

			//variable donde se guardaran cada uno de los filtros
			List<TorreControlFiltros> datosFiltros = new List<TorreControlFiltros>();
			List <String> setReturnValues = new List<String>();
			List<Opportunity> ListaOportunidades = new List <Opportunity>();
			//Se usa codigo de Filtros en Torre de Control.
			datosFiltros = TorreControlFiltros.parse(pListafiltros);
			System.debug(':::DatosFiltors: '+datosFiltros);
			//variables String que alojan los datos.
			String query_append='';
			String lcampus_ext = pExt;
			String q_opps = q_opp_string + ' and Campus__c in ('+lcampus_ext+')';
			Integer count_opps = 0;

			System.debug('>>>Query'+q_opps);

			//valida si hay filtros en la lista
			if(!datosFiltros.isEmpty()){

				//recorrido de cada uno de los filtros
				for(TorreControlFiltros tc: datosFiltros){

					//armado de query con filtros
					query_append += ' and ' + getOperadorEquivalente(tc.campo.n,tc.operador.name,tc.valor.name,tc.campo.tipo);

				}
			}
			system.debug(':::QUERY APPEND::: ' + query_append);

			//Se agregan a la lista
			setReturnValues.add(query_append);
			//Se comprieba si los filtros estan llenados.
			if(String.isBlank(query_append) == false){

					System.debug(':::Existen datos query_append: '+query_append);
					q_opps = q_opps+query_append;
					System.debug(':::Query mas query_append: '+q_opps);
			}
			//Se ejecuta el query a la lista de oportunidades.
			ListaOportunidades = database.query(q_opps);
			//Se agrega el conteo a la lista
			setReturnValues.add(String.valueOf(ListaOportunidades.size()));
			System.debug('::::ReturnValues: '+setReturnValues);
			//se regresa la lista
			return setReturnValues;

	}

	///////////////// FIN Metodo remote para filtros///////////////////////////////7


	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


	@RemoteAction
	public static Map<String,DatosCampos_Wrapper> obtenerMapaOperadores(){

		//Variable que se retornara como resultado y que contendra la lista de campos
		Map<String,DatosCampos_Wrapper> mapaResultdo = new Map<String,DatosCampos_Wrapper>();

		//Obtencion de datos desde la configuración personalizada
		List<campos_modulo_assignacion__c> mcs = [Select id,API__c,Tipo__c,Etiqueta__c,Orden__c from campos_modulo_assignacion__c];

		//se recorren los registros de la configuración personalizada
		for(campos_modulo_assignacion__c ctc: mcs){
				//se agrega al mapa el campo con sus atributos.
				mapaResultdo.put(ctc.API__c, new DatosCampos_Wrapper(ctc.API__c,ctc.Tipo__c,ctc.Etiqueta__c));
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
			List<String> lListaVerticales = new List<String>();
			List<String> lListaProgramas = new List<String>();
			List<String> lListaTiposBase = new List<String>();
			List<String> lListaCampus = new List<String>();
			List<String> lListaAlianzas = new List<String>();
			List<String> lListaPrioridades = new List<String>();
			List<String> lListaSector = new List<String>();
			Generados_Ciclo__c lCiclos = Generados_Ciclo__c.getInstance();


			//Obtener valores de periodo__c
			Schema.DescribeFieldResult fieldResultCanal = Opportunity.Canal__c.getDescribe();
			List<Schema.PicklistEntry> pleCanal = fieldResultCanal.getPicklistValues();
			for( Schema.PicklistEntry pickListVal : pleCanal){
					lListaCanal.add(pickListVal.getLabel());
			}

			// //Obtener valores de periodo__c
			// Schema.DescribeFieldResult fieldResult = Opportunity.Periodo__c.getDescribe();
			// List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
			// for( Schema.PicklistEntry pickListVal : ple){
			// 		lListaCiclos.add(pickListVal.getLabel());
			// }

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

			//Obtener valores de vertical
			Schema.DescribeFieldResult fieldResultVertical = Programa_Salesforce__c.Vertical__c.getDescribe();
			List<Schema.PicklistEntry> pleVertical = fieldResultVertical.getPicklistValues();
			for( Schema.PicklistEntry pickListVal : pleVertical){
					lListaVerticales.add(pickListVal.getLabel());
			}

			//query para llenar lista de programas (programas salesforce)
			for(AggregateResult fPrograma: [select Name from programa_salesforce__c group by name]){
					lListaProgramas.add( (String) fPrograma.get('Name'));
			}

			//Obtener valores de tipo de base
			Schema.DescribeFieldResult fieldResultTipobase = Opportunity.Tipo_de_Base__c.getDescribe();
			List<Schema.PicklistEntry> pleTipoBase = fieldResultTipobase.getPicklistValues();
			for( Schema.PicklistEntry pickListVal : pleTipoBase){
					lListaTiposBase.add(pickListVal.getLabel());
			}
			//query a los campus - id__c es indexado y el costo del query es menor a 0
			for(Account nombreCampus: [select id,Name from account where id__c != null and recordtype.developername = 'Campus_UVM' and Name!='Corporativo UVM']){
					lListaCampus.add(nombreCampus.Name);
			}

			//llenando campo ciclo
			Integer lAnioActual = system.today().year();
			Integer lAnioFinal = (system.today().year()+1);
			for(Integer i = Integer.ValueOf(lCiclos.A_o_Inicio__c); i <= Integer.ValueOf(lCiclos.A_o_Fin__c); i++){
					for(Integer j = 1; j <= 3; j++){
							String fAnioCiclo = i + '' +j;
							lListaCiclos.add(fAnioCiclo);
					}
			}

			//Obtener valores de escuala con alianza
			Schema.DescribeFieldResult fieldResultAlianzas = Escuela_de_Campus__c.Con_Alianza_Educativa__c.getDescribe();
			List<Schema.PicklistEntry> pleAlianzas = fieldResultAlianzas.getPicklistValues();
			for( Schema.PicklistEntry pickListVal : pleAlianzas){
					lListaAlianzas.add(pickListVal.getLabel());
			}

			//Obtener valores de prioridad
			Schema.DescribeFieldResult fieldResultPrioridad = Escuela_de_Campus__c.Prioridad__c.getDescribe();
			List<Schema.PicklistEntry> plePrioridad = fieldResultPrioridad.getPicklistValues();
			for( Schema.PicklistEntry pickListVal : plePrioridad){
					lListaPrioridades.add(pickListVal.getLabel());
			}

			//Obtener valores de sector
			Schema.DescribeFieldResult fieldResultSector = Account.Sector__c.getDescribe();
			List<Schema.PicklistEntry> pleSector = fieldResultSector.getPicklistValues();
			for( Schema.PicklistEntry pickListVal : pleSector){
					lListaSector.add(pickListVal.getLabel());
			}


			mapaResultdo.put('Periodo__c', lListaCiclos);
			mapaResultdo.put('Ciclo_Anio__c', lListaCiclos);
			mapaResultdo.put('Origen__c', lListaOrigenes);
			mapaResultdo.put('Estatus__c', lListaEstatus);
			mapaResultdo.put('Nivel__c', lListaNivel);
			mapaResultdo.put('Canal__c', lListaCanal);
			mapaResultdo.put('Programa_de_Inter_s__r.Vertical__c', lListaVerticales);
			mapaResultdo.put('Programa_de_Inter_s__r.Name', lListaProgramas);
			mapaResultdo.put('Tipo_de_Base__c', lListaTiposBase);
			mapaResultdo.put('Campus__r.Name', lListaCampus);
			mapaResultdo.put('Escuela_de_Campus__r.Con_Alianza_Educativa__c', lListaAlianzas);
			mapaResultdo.put('Escuela_de_Campus__r.Prioridad__c', lListaPrioridades);
			mapaResultdo.put('Escuela_de_Campus__r.Escuela__r.Sector__c', lListaSector);

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