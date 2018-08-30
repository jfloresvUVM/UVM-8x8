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
			// Regreamos => nombre_programa lleno.
			return nombre_programa;
		} // fin => obtenerProgramasAcademicos().
	 
	 @RemoteAction
	 public static List<String> obtenerCampus() {
	 	// Crear una lista para almacenar campus con programas activos.
	 	List<String> nombre_campus = new List<String>();

	 	// Iteramos Query de programas activos para cada campus
		for(AggregateResult ar:[SELECT Campus__c, Campus__r.Name FROM Programa_del_Campus__c WHERE Programa_Activo__c = true  GROUP BY Campus__c, Campus__r.Name]){
					// Parsemaos AggregateResult a tipo string => campus
          String campus = String.valueOf(ar.get('Name'));
					// Asignación de campus a varible => nombre_campus
          nombre_campus.add(campus);
    }	
	 	// Regresamos => nombre_campus lleno.
    return nombre_campus;
	} // fin => obtenerCampusUvm().

	@RemoteAction
	public static List<String> obtenerNivelesCampus(String parametro_campus) {
	 	// Crear una lista para almacenar campus con programas activos.
	 	List<String> tipo_niveles = new List<String>();

	 	// Iteramos Query de programas activos para cada campus
		for(AggregateResult er:[SELECT Programa__r.Family FROM Programa_del_Campus__c Where Programa_Activo__c = true AND Campus__r.Name = :parametro_campus GROUP BY Programa__r.Family]){
					// Parsemaos AggregateResult a tipo string => campus
          String niveles = String.valueOf(er.get('Family'));
					// Asignación de campus a varible => nombre_campus
          tipo_niveles.add(niveles);
    }	
	 	// Regresamos => nombre_campus lleno.
    return tipo_niveles;

	}
}

