public with sharing class Ctrl_Torre_de_Control{

    //Método para obtener lista de campos en la configuración personalizada Campos_Torre_Control__c y asi poder llenar el 
    //picklist de campos en la página de torre de control
    @RemoteAction
    public static Map<String,DatosCampos_Wrapper> obtenerMapaOperadores(List<String> pListaCamposAgregados){

        //Variable que se retornara como resultado y que contendra la lista de campos
        Map<String,DatosCampos_Wrapper> mapaResultdo = new Map<String,DatosCampos_Wrapper>();

        //Obtencion de datos desde la configuración personalizada
        List<Campos_Torre_Control__c> mcs = [Select id,API__c,Tipo__c,Etiqueta__c,Orden__c from Campos_Torre_Control__c
                                                where API__c NOT IN: pListaCamposAgregados
                                                order by Orden__c asc];

        //se recorren los registros de la configuración personalizada
        for(Campos_Torre_Control__c ctc: mcs){
            //se agrega al mapa el campo con sus atributos.
            mapaResultdo.put(ctc.API__c, new DatosCampos_Wrapper(ctc.API__c,
                                                                ctc.Tipo__c,
                                                                ctc.Etiqueta__c));
        }

        return mapaResultdo;
    }

    //Método donde se armara el super query para la busqueda de oportunidades
    @RemoteAction
    public static DatosRetorno_Wrapper hacerSuperQuery(String pListafiltros){        
        //variable que agrupa los resultados del método
        DatosRetorno_Wrapper result = new DatosRetorno_Wrapper();
        //oportunidades encontradas
        List<Opportunity> lListaOportunidades = new List<Opportunity>();
        //obteniendo id del perfil para validar en query
        String lIdPerfiles = [Select id from Profile where Name = 'Asesor Call Center UVM'].Id;
        //variable donde se estara armando el query
        String q = '';
        //inicializacion del query
        q = 'Select Id ,Nivel__c,Name,Campus__r.Name,Team_8x8__c,tipo_de_team_8x8__c,Prioiridad_de_Oportunidad_8x8__c, '+
        'Score_1_8x8__c,Score_2_8x8__c,Intentos_Campa_a_8x8__c,Contador_de_toques__c,Origen_Actual_8x8__c,Canal_Actual_8x8__c,'+
        'Tipo_de_Base__c,Nivel_de_Inter_s__c,Campa_a_CEC_Actual__c,SubCampa_a_8x8__c,Ultimo_Toque_Call_Center__c ' + 
        'from Opportunity where Campa_a_CEC_Actual__r.id = null AND Miembro_de_Campa_a_CEC__r.id = null '+
        'AND Owner.ProfileId = \''+lIdPerfiles+'\'';
        //variable donde se guardaran cada uno de los filtros
        List<TorreControlFiltros> datosFiltros = new List<TorreControlFiltros>();
        //deserializacion de los filtros en un objeto de salesforce para mejor manejo
        datosFiltros = TorreControlFiltros.parse(pListafiltros);

        //valida si hay filtros en la lista
        if(!datosFiltros.isEmpty()){
        
            //recorrido de cada uno de los filtros
            for(TorreControlFiltros tc: datosFiltros){

                //armado de query con filtros
                q += ' and ' + getOperadorEquivalente(tc.campo.n,tc.operador.name,tc.valor.name,tc.campo.tipo);
            }
        }
        system.debug(':::QUERY::: ' + q);
        //se obtienen las oportunidades basadas en el query
        lListaOportunidades = database.query(q);
        
        //guardado de lista de oportunidades y el string del query en el agrupador wrapper
        result.lListaOportunidades = lListaOportunidades;
        result.query = q;

        return result;
    }    

    //Método para obtener el listado de ciertos campos que aparecen como picklist en valor, como el catalogo de campus
    @RemoteAction
    public static Map<String,List<String>> obtenerListadoDeValores(){
        //variable para return con todos los catalogos
        Map<String,List<String>> mapaResultdo = new Map<String,List<String>>();
        system.debug('Entrando a obtenerListadoDeValores');
        //variable resultado
        List<String> lListaCampus = new List<String>();//variable para almacenar campos
        List<String> lListaCiclos = new List<String>();
        List<String> lListaRegiones = new List<String>();
        List<String> lListaOrigenes = new List<String>();
        List<String> lListaTiposBase = new List<String>();
        List<String> lListaVerticales = new List<String>();
        List<String> lListaNivel = new List<String>();
        List<String> lListaPrioridades = new List<String>();
        List<String> lListaAlianzas = new List<String>();
        List<String> lListaSector = new List<String>();
        List<String> lListaPermiteAcceso = new List<String>();
        List<String> lListaPresentaExamen = new List<String>();
        List<String> lListaEstatus = new List<String>();
        List<String> lListaInsPresExamen = new List<String>();
        List<String> lListaRevalidaEquiv = new List<String>();
        //query a los campus - id__c es indexado y el costo del query es menor a 0
        for(Account nombreCampus: [select id,Name from account where id__c != null and recordtype.developername = 'Campus_UVM' and Name!='Corporativo UVM']){
            lListaCampus.add(nombreCampus.Name);
        }

        //Obtener valores de periodo__c
        Schema.DescribeFieldResult fieldResult = Opportunity.Periodo__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            lListaCiclos.add(pickListVal.getLabel());
        }

        //Obtener valores de revalidacion de equivalencias
        Schema.DescribeFieldResult fieldResultRevalidaEquiv = Opportunity.Revalidaci_n_Equivalencias_HB__c.getDescribe();
        List<Schema.PicklistEntry> pleRevalidaEquiv = fieldResultRevalidaEquiv.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : pleRevalidaEquiv){
            lListaRevalidaEquiv.add(pickListVal.getLabel());
        }

        //Obtener valores de institucion presenta examen
        Schema.DescribeFieldResult fieldResultInsPresentaExam = Opportunity.Institucion_Presenta_Examen__c.getDescribe();
        List<Schema.PicklistEntry> pleInsPresentaExam = fieldResultInsPresentaExam.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : pleInsPresentaExam){
            lListaInsPresExamen.add(pickListVal.getLabel());
        }

        //Obtener valores de Estatus
        Schema.DescribeFieldResult fieldResultEstatus = Opportunity.Estatus__c.getDescribe();
        List<Schema.PicklistEntry> pleEstatus = fieldResultEstatus.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : pleEstatus){
            lListaEstatus.add(pickListVal.getLabel());
        }

        //Obtener valores de presenta examen en escuala publica
        Schema.DescribeFieldResult fieldResultPresentaExamen = Opportunity.Presentar_Ex_men_en_Escuela_P_blica__c.getDescribe();
        List<Schema.PicklistEntry> plePresentaExamen = fieldResultPresentaExamen.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : plePresentaExamen){
            lListaPresentaExamen.add(pickListVal.getLabel());
        }

        //Obtener valores de region
        Schema.DescribeFieldResult fieldResultRegion = Account.Regi_n__c.getDescribe();
        List<Schema.PicklistEntry> plePeriodo = fieldResultRegion.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : plePeriodo){
            lListaRegiones.add(pickListVal.getLabel());
        }

        //Obtener valores de sector
        Schema.DescribeFieldResult fieldResultSector = Account.Sector__c.getDescribe();
        List<Schema.PicklistEntry> pleSector = fieldResultSector.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : pleSector){
            lListaSector.add(pickListVal.getLabel());
        }

        //Obtener valores de origen
        Schema.DescribeFieldResult fieldResultOrigen = Opportunity.Origen__c.getDescribe();
        List<Schema.PicklistEntry> pleOrigen = fieldResultOrigen.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : pleOrigen){
            lListaOrigenes.add(pickListVal.getLabel());
        }

        //Obtener valores de tipo de base
        Schema.DescribeFieldResult fieldResultTipobase = Opportunity.Tipo_de_Base__c.getDescribe();
        List<Schema.PicklistEntry> pleTipoBase = fieldResultTipobase.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : pleTipoBase){
            lListaTiposBase.add(pickListVal.getLabel());
        }

        //Obtener valores de Nivel
        Schema.DescribeFieldResult fieldResultNivel = Opportunity.Nivel_de_Inter_s__c.getDescribe();
        List<Schema.PicklistEntry> pleNivel = fieldResultNivel.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : pleNivel){
            lListaNivel.add(pickListVal.getLabel());
        }

        //Obtener valores de vertical
        Schema.DescribeFieldResult fieldResultVertical = Programa_Salesforce__c.Vertical__c.getDescribe();
        List<Schema.PicklistEntry> pleVertical = fieldResultVertical.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : pleVertical){
            lListaVerticales.add(pickListVal.getLabel());
        }

        //Obtener valores de prioridad
        Schema.DescribeFieldResult fieldResultPrioridad = Escuela_de_Campus__c.Prioridad__c.getDescribe();
        List<Schema.PicklistEntry> plePrioridad = fieldResultPrioridad.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : plePrioridad){
            lListaPrioridades.add(pickListVal.getLabel());
        }

        //Obtener valores de escuala con alianza
        Schema.DescribeFieldResult fieldResultAlianzas = Escuela_de_Campus__c.Con_Alianza_Educativa__c.getDescribe();
        List<Schema.PicklistEntry> pleAlianzas = fieldResultAlianzas.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : pleAlianzas){
            lListaAlianzas.add(pickListVal.getLabel());
        }

        //Obtener valores de escuala permite acceso
        Schema.DescribeFieldResult fieldResultPermiteAcceso = Escuela_de_Campus__c.Con_Alianza_Educativa__c.getDescribe();
        List<Schema.PicklistEntry> plePermiteAcceso = fieldResultPermiteAcceso.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : plePermiteAcceso){
            lListaPermiteAcceso.add(pickListVal.getLabel());
        }

        mapaResultdo.put('Periodo__c', lListaCiclos);
        mapaResultdo.put('Campus__r.Name', lListaCampus);
        mapaResultdo.put('Campus__r.Regi_n__c', lListaRegiones);
        mapaResultdo.put('Origen__c', lListaOrigenes);
        mapaResultdo.put('Tipo_de_Base__c', lListaTiposBase);
        mapaResultdo.put('Nivel_de_Inter_s__c', lListaNivel);        
        mapaResultdo.put('Programa_de_Inter_s__r.Vertical__c', lListaVerticales);
        mapaResultdo.put('Escuela_de_Campus__r.Prioridad__c', lListaPrioridades);
        mapaResultdo.put('Escuela_de_Campus__r.Con_Alianza_Educativa__c', lListaAlianzas);
        mapaResultdo.put('Escuela_de_Campus__r.Escuela__r.Sector__c', lListaSector);
        mapaResultdo.put('Escuela_de_Campus__r.Permite_Acceso__c', lListaPermiteAcceso);
        mapaResultdo.put('Presentar_Ex_men_en_Escuela_P_blica__c', lListaPresentaExamen);
        mapaResultdo.put('Estatus__c', lListaEstatus);
        mapaResultdo.put('Institucion_Presenta_Examen__c', lListaInsPresExamen);
        mapaResultdo.put('Revalidaci_n_Equivalencias_HB__c', lListaRevalidaEquiv);

        return mapaResultdo;
    }

    //Método para transformar los valores de texto de los operadores en simbolos para el query
    public static String getOperadorEquivalente(String pCampo, String pOperador, String pValor, String pTipo){
        //Mapa para guardar los operadores dependiendo del texto enviado por la pantalla torre de control.
        Map<String,String> lMapaOperadores = new Map<String,String>();
        //variable de retorno
        String filtroArmado = '';

        //obtener expresiones de custom setting Expresiones_Torre_Control__c para crear el filtro
        Expresiones_Torre_Control__c mcs = Expresiones_Torre_Control__c.getValues(pTipo+'-'+pOperador);

        //creando filtro a base de la expresion y reemplazando valores y campos
        filtroArmado = mcs.Expresion__c;
        filtroArmado = filtroArmado.replaceAll('CAMPO',pCampo);
        filtroArmado = filtroArmado.replaceAll('VALOR',pValor);

        return filtroArmado;
    }

    //Método para crear la campaña
    @RemoteAction
    public static String crearCampania(String pQuery,String pTipoCampania,String pNombreCampania,
                                        String pFechaInicio, String pFechaFin, String pNombreCallCenter,
                                        List<Opportunity> pListaOpps,String pPrioridad,Integer pScore2,
                                        String pTipoTeam,String pTeam,String pNombreSubCampania)
    {
        system.debug('lista de oportunidades: ' + pListaOpps);
        //creando nueva campaña
        Campa_a_CEC__c nuevaCampania = new Campa_a_CEC__c();
        //buscando campaña seleccionada en torre de control en base al nombre
        Campa_a_Fija_CC__c campaniaSel = [Select id,name, Pertenece_a__c 
                                            from Campa_a_Fija_CC__c where name =: pNombreCallCenter LIMIT 1];
        //validando a quien pertenece la campaña en base al nombre
        if(campaniaSel.Pertenece_a__c.containsIgnoreCase('Brittel')){            
            nuevaCampania.Campa_a_Fija_Brittel__c = campaniaSel.Id;
        }        
        //mapeo de los campos
        nuevaCampania.Name = pNombreCampania;
        nuevaCampania.Tipo_de_Campa_a__c = pTipoCampania;
        nuevaCampania.Fecha_de_Inicio__c = Date.valueOf(pFechaInicio);
        nuevaCampania.Fecha_Final__c = Date.valueOf(pFechaFin);
        nuevaCampania.Estatus__c = 'Activa';
        nuevaCampania.Prioridad__c = pPrioridad;
        nuevaCampania.Query__c = pQuery;
        
        //insersion de camaña
        insert nuevaCampania;

        //se crean los miembros de campaña
        //ID jobID = System.enqueueJob(new CrearMiembrosCampania_Queueable(pListaOpps,nuevaCampania.Id,campaniaSel.Pertenece_a__c));
        Id batchInstanceId = Database.executeBatch(new CrearMiembrosCampania_Batch( pQuery,campaniaSel.Pertenece_a__c,nuevaCampania.Id,pPrioridad,pScore2,pTipoTeam,pTeam,pNombreSubCampania), 100);

        //como resultado retornamos el id de la campaña
        return nuevaCampania.Id;
    }

    /*Método para obtener campañas en base a quien pertenece (Brittel, 8x8)
    Se regresara un mapa con todos los valores*/
    @RemoteAction
    public static List<String> obtieneCampanias(String pPertenece){
        //variable de resultado
        List<String> resultado = new List<String>();
        //agrega valor default
        resultado.add('-Seleccione-');

        //busqueda de campañas
        for(Campa_a_Fija_CC__c cc : [Select id,name, Pertenece_a__c from Campa_a_Fija_CC__c where Pertenece_a__c =: pPertenece])
        {
            //se llena el mapa dependiendo de a quien pertenece
            resultado.add(cc.Name );
        }

        //regresa resultado
        return resultado;
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
}