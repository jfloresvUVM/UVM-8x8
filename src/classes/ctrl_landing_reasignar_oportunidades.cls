public with sharing class ctrl_landing_reasignar_oportunidades {



    @RemoteAction
	public static String getPercentGerente(String campusName){
        Id idGerente= [select gerente__r.UserRoleId from Campus_Gerente__c where name = :campusName].gerente__r.UserRoleId;
        List<SObject> gerenteOpps = [select Count(id) From Opportunity Where Owner.id = :idGerente];
        return String.valueOf(gerenteOpps[0].get('expr0'));
    }

    @RemoteAction
	public static List<map<String,String>> getAsesores(String campusName){
        try{
            Id gerenteRoleId= [select gerente__r.UserRoleId from Campus_Gerente__c where name = :campusName].gerente__r.UserRoleId;
            Id idRolesAsesor = [SELECT id FROM UserRole WHERE ParentRoleId = :gerenteRoleId].id;
            List<User> Asesores = [SELECT id, name, IsActive FROM User WHERE UserRoleId = :idRolesAsesor];
            List<map<String,String>> resultados = new List<map<String,String>>();
            map<String,String> mapeo = new Map<String, String>();
            for (User usr: Asesores) {
                mapeo = new Map<String, String>();
                mapeo.put('id', String.valueOf(usr.id));
                mapeo.put('name', String.valueOf(usr.name));
                mapeo.put('status', String.valueOf(usr.IsActive));
                List<SObject> ConteoOportunidades = [Select Count(id) From Opportunity Where OwnerId = :usr.Id];
                mapeo.put('opp', String.valueOf(ConteoOportunidades[0].get('expr0')));
                resultados.add(mapeo);
            }
                return resultados;
        }catch(exception e){
            System.debug('Error:'+ e.getMessage());
            return null;
        }
	}
}
