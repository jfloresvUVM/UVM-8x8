public with sharing class Ctrl_Landing_Academico {
	 
	 // Método para obtener lista de Campus.
	 @RemoteAction
	 public static List<String> obtenerCampus() {
	 	// Crear una lista para almacenar campus con programas activos.
	 	List<String> nombre_campus = new List<String>();

	 	// Iteramos Query con programas activos para cada campus
		for (AggregateResult ar:[SELECT Campus__c, Campus__r.Name FROM Programa_del_Campus__c WHERE Programa_Activo__c = true  GROUP BY Campus__c, Campus__r.Name]) {
					// Parsemaos AggregateResult a tipo string => campus
          String campus = String.valueOf(ar.get('Name'));
					// Asignación de campus a varible => nombre_campus
          nombre_campus.add(campus);
    }	
	 	// Regresamos => nombre_campus lleno.
    return nombre_campus;
	} // fin => obtenerCampusUvm().


	// Método para obtener lista de Contenedores por Nivles.
	@RemoteAction
	public static List<Map<String, String>> obtenerContenedores(String nivel) {
	// Crear una lista para almacenar contenedores por niveles.
	List<Solution> detallesContenedor = [SELECT Solution.SolutionName, SolutionNote, Detalles__c FROM Solution 
													 						 WHERE Id IN  (SELECT CategoryData.RelatedSobjectId FROM CategoryData WHERE CategoryData.CategoryNodeID = '02n2F0000004HPJQA2')
													 						 AND Nivel__c = :nivel];

	Map<String, String> contenedorNiveles = new Map<String, String>();

	List<Map<String, String>> listaDetalles = new List<Map<String, String>>();

	// Iteración de => detallesContenedor.
	for (Solution a: detallesContenedor) {
		contenedorNiveles = new Map<String, String>();

		// Asignación de detallesContenedor a varible => a contenedorNiveles
		contenedorNiveles.put('Solucion', a.SolutionName);
		contenedorNiveles.put('Detalles', a.Detalles__c);
		contenedorNiveles.put('Note', a.SolutionNote);
		// Llenamos lista de mpaas con los registros necearios.
		listaDetalles.add(contenedorNiveles);
	}
	// Regresamos => listaDetalles lleno.
	return listaDetalles;
	} // fin => obtenerContenedores().


	// Método para obtener lista de Niveles por campus.
	@RemoteAction
	public static List<String> obtenerNivelesCampus(String campus) {
	 	// Crear una lista para almacenar niveles de cada campus.
	 	List<String> tipo_niveles = new List<String>();

	 	// Iteramos Query con niveles activos por cada campus.
		for (AggregateResult ar:[SELECT Programa__r.Family FROM Programa_del_Campus__c Where Programa_Activo__c = true AND Campus__r.Name = :campus GROUP BY Programa__r.Family]) {
					// Parsemaos AggregateResult a tipo string => niveles 
          String niveles = String.valueOf(ar.get('Family'));
					// Asignación de niveles a varible => tipo_niveles.
          tipo_niveles.add(niveles);
    }	
	 	// Regresamos => nombre_campus lleno.
    return tipo_niveles;

	}

	// Método para obtener lista de Verticales por campus y nivel.
	@RemoteAction
	public static List<String> obtenerVerticalNivel(String campus, String nivel) {
		// Crear un lista para almacenar verticales de cada nivel.
		List<String> tipo_vertical = new List<String>();

		// Iteramos Query con Verticales activas para cada nivel.
		for (AggregateResult ar:[SELECT Programa__r.Vertical__c FROM Programa_del_Campus__c 
														WHERE Programa_Activo__c = true AND Campus__r.Name = :campus AND  Programa__r.Family = :nivel
														GROUP BY Programa__r.Vertical__c]) {

			String verticales = String.valueOf(ar.get('Vertical__c'));
			// Llenamos lista con verticales.
			tipo_vertical.add(verticales);
		}
		//Regresamos => tipo_vertical lleno.
		return tipo_vertical;
	}

	// Método para obtener programas dependiendo el campus el nivel y la vertical obtenidos.
	@RemoteAction
	public static  List<Map<String, String>> obtenerProgramasAcademicos(String campus, String nivel, String vertical) {
		// Query para obtener programas academicos.
		//List<Programa_del_campus__c> programas_academicos = [SELECT Busqueda_programa__c, Programa__c, Name FROM Programa_del_campus__c ORDER BY Name LIMIT 40];
		List<Programa_del_Campus__c> programas_academicos = [SELECT Id, Programa__r.Name,  Programa__r.ID_Banner__c,  Programa__c, Id_Externo__c, 
																																Programa__r.Family,  Programa__r.Programa_Salesforce__c
																												 FROM Programa_del_Campus__c
																												 WHERE Programa_Activo__c = true
																												 AND Campus__r.Name = :campus
																												 AND Programa__r.Family = :nivel
																												 AND Programa__r.Vertical__c = :vertical
																												 AND Programa__r.IsActive = true ];

		// Crear una lista de mapas para almacenar programas dentro del ciclo
		Map<String, String> programas = new Map<String, String>();

		// Crear una lista de mapas para almacenar programas_academicos.
		List<Map<String, String>> listaProgramas = new List<Map<String, String>>();

		// Iteración de => programas_academicos.
		for (Programa_del_campus__c a: programas_academicos) {

			programas = new Map<String, String>();
			
			programas.put('Nombre', a.Programa__r.Name );
			programas.put('Id', a.Programa__r.Programa_Salesforce__c);

			listaProgramas.add(programas);

		}
		// Regreamos => listaProgramas lleno.
		return listaProgramas;
	} // fin => obtenerProgramasAcademicos().

	@RemoteAction
	public static  List<Map<String, String>> obtenerSoluciones(String idPrograma) {
		// Query para obtener programas academicos.
		//List<Programa_del_campus__c> programas_academicos = [SELECT Busqueda_programa__c, Programa__c, Name FROM Programa_del_campus__c ORDER BY Name LIMIT 40];
		List<Solution> solucionesPrograma = [SELECT SolutionName, Programa_Salesforce__c, Detalles__c  
																					 FROM Solution 
																					 WHERE Programa_Salesforce__c  =  :idPrograma ];

		// Crear una lista para almacenar programas_academicos.
		Map<String, String> soluciones = new Map<String, String>();


		List<Map<String, String>> listaSoluciones = new List<Map<String, String>>();

		// Iteración de => programas_academicos.
		for (Solution a: solucionesPrograma) {

			soluciones = new Map<String, String>();
			
			// Asignación de programas a varible => a
			soluciones.put('Solucion', a.SolutionName);
			soluciones.put('Detalles', a.Detalles__c);
			soluciones.put('Id', a.Programa_Salesforce__c);


			listaSoluciones.add(soluciones);

		}
		// Regreamos => nombre_programa lleno.
		//System.debug(nombre_programa); 
		//return nombre_programa;
		return listaSoluciones;
	} // fin => obtenerProgramasAcademicos().

}
