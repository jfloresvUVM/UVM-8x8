public with sharing class Ctrl_Landing_Academico {
		@RemoteAction
		public static List<String> obtenerProgramasAcademicos(){
			// Query para obtener programas academicos.
			//List<Programa_del_campus__c> programas_academicos = [SELECT Busqueda_programa__c, Programa__c, Name FROM Programa_del_campus__c ORDER BY Name LIMIT 40];
			List<Programa_del_Campus__c> programas_academicos = [SELECT Busqueda_programa__c FROM Programa_del_Campus__c ORDER BY Name ASC LIMIT 40];

			// Crear una lista para almacenar programas_academicos.
			List<String> nombre_programa = new List<String>();

			// Iteración de => programas_academicos.
			for (Programa_del_campus__c a: programas_academicos) {
				// Asignación de programas a varible => a
				nombre_programa.add(a.Busqueda_programa__c);
			}
			// Manadamos => nombre_programa lleno.
			return nombre_programa;
		} // fin => obtenerProgramasAcademicos().
		 
		@RemoteAction
		public static List<AggregateResult> obtenerCampus(){
			// Query para obtener Campus
			List<AggregateResult> campus_uvm = [SELECT Campus__c ,Campus__r.Name FROM Programa_del_Campus__c WHERE Programa_Activo__c = true  GROUP BY Campus__c, Campus__r.Name];

			// Crear una lista para alamacenar campus
			List<String> nombre_campus = new List<String>();

			// Iteración de => campus_uvm
			for (AggregateResult a: campus_uvm){
				// Asignación de campus a variable => a
				nombre_campus.add(a.Campus__r.Name);
			}
			// Mondamos nombre_campus lleno.
			return nombre_campus;
		} // fin => obtenerCampusUvm().

	//@RemoteAction
	//public static List<String> obtenerNivelesPorCampus() {
	//	List<Programa_del_Campus__c> niveles_campus = [SELECT Programa__r.Family FROM Programa_del_Campus__c  WHERE Programa_Activo__c = true and Campus__c = '0012F00000JeyC1QAJ' GROUP BY Programa__r.Family];
    
 //   List<String> tipo_nivel = new List<String>();

 //   for (Programa_del_Campus__c a: niveles_campus) {
 //   	tipo_nivel.add(a.Programa__r.Family);
 //   }
 //   return tipo_nivel;

	//}
}