/*---------------------------------------------------------------------------------------------------------

Autor: Javier Flores - 15-08-2018
Descripción: Clase de tipo batch para crear los miembros de campaña por lotes que son enviados por la torre de control

Datos adicionales: Los lotes se procesan actualmente de 100 en 100

Modificado: Javier Flores - 30-08-2018

Test Class: Torre_De_Control_Test
---------------------------------------------------------------------------------------------------------*/
global class CrearMiembrosCampania_Batch implements Database.Batchable<sObject>{
    //variables globales de la clase
	global String gQuery;
	global String gIdCampaniaCEC;
	global String gPertenece;
	global String gPrioridad;
	global Integer gScore2;
    global String gTipoTeam;
    global String gTeam;
    global String gNombreSubCampania;

    //Constructor de la clase
	public CrearMiembrosCampania_Batch(String pQueryOverload,String pPertenece, String pIdCampaniaCEC,String pPrioridad,Integer pScore2,
                                        String pTipoTeam,String pTeam,String pNombreSUbCampania)
    {
        //se valida si trae un query desde el llamado del batch para asignarlo y ejecutarlo
		if(pQueryOverload!=null){
            gQuery = pQueryOverload;
        }
        //mapeo de variables al crear el batch
        this.gPertenece = pPertenece;
        this.gIdCampaniaCEC = pIdCampaniaCEC;
        this.gPrioridad = pPrioridad;
        this.gScore2 = pScore2;
        this.gTipoTeam = pTipoTeam;
        this.gTeam = pTeam;
        this.gNombreSubCampania = pNombreSUbCampania;
	}

    //Método donde se ejecuta el query
	global Database.Querylocator start (Database.BatchableContext BC){
        system.debug('::: start - gQuery: ' + gQuery);
        return Database.getQueryLocator(gQuery);
    }

    //Método donde se ejecuta la logica con los registros encontrados por el batch
    global void execute(Database.BatchableContext BC,List<Opportunity> scope) {
        system.debug('::: execute - scope: ' + scope);
        //lista de miembros de campaña a insertar
        List<Miembro_de_Campa_a_CEC__c> lMiembroCampania = new List<Miembro_de_Campa_a_CEC__c>();

        //se recorren las oportunidades para crear los miembros de campanña
        for(Opportunity op: scope){
            Miembro_de_Campa_a_CEC__c mc = new Miembro_de_Campa_a_CEC__c();
            mc.Oportunidad__c = op.Id;
            mc.Campa_a_CEC__c = gIdCampaniaCEC;
            mc.Pertenece_a__c = gPertenece;
            mc.Fecha_Hora_de_Envio__c = system.now();
            mc.Prioridad__c = gPrioridad;
            mc.Score_2__c = gScore2;
            mc.Tipo_de_Team__c = gTipoTeam;
            mc.Team__c = gTeam;
            mc.Nombre_Sub_Campaia__c = gNombreSubCampania;
            mc.Estatus__c = 'En proceso';

            //se agregan los miembros de campaña a la lista
            lMiembroCampania.add(mc);
        }

        //se valida si la lista de miembros contiene elementos
        if(!lMiembroCampania.isEmpty()){
            //se insertan los miembros de campaña
            insert lMiembroCampania;
        }                
    }

    //Método finish que se ejecuta cuando se procesaron todos los registros
    global void finish(Database.BatchableContext BC) {
    	
    } 
}