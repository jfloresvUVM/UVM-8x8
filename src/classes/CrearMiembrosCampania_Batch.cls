global class CrearMiembrosCampania_Batch implements Database.Batchable<sObject>{

	global String gQuery;
	global String gIdCampaniaCEC;
	global String gPertenece;
	global String gPrioridad;
	global Integer gScore2;
    global String gTipoTeam;
    global String gTeam;
    global String gNombreSubCampania;

	public CrearMiembrosCampania_Batch(String pQueryOverload,String pPertenece, String pIdCampaniaCEC,String pPrioridad,Integer pScore2,
                                        String pTipoTeam,String pTeam,String pNombreSUbCampania)
    {
		if(pQueryOverload!=null){
            gQuery = pQueryOverload;
        }
        this.gPertenece = pPertenece;
        this.gIdCampaniaCEC = pIdCampaniaCEC;
        this.gPrioridad = pPrioridad;
        this.gScore2 = pScore2;
        this.gTipoTeam = pTipoTeam;
        this.gTeam = pTeam;
        this.gNombreSubCampania = pNombreSUbCampania;
	}

	global Database.Querylocator start (Database.BatchableContext BC){
        system.debug('::: start - gQuery: ' + gQuery);
        return Database.getQueryLocator(gQuery);
    }

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

    global void finish(Database.BatchableContext BC) {
    	
    } 
}