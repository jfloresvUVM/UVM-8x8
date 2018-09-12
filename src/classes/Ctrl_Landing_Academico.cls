/*

** Autor: Eduardo Pérez. - 25-07-2018
** Descripción: 
** Ctrl_Landing_Acadmeico
** Controlador para => Landing_Programas_Academicos.page

*/

public with sharing class Ctrl_Landing_Academico {
	 // Método para obtener lista de Campus.
	 @RemoteAction
	 public static List<String> obtenerCampus() {
	 	// Crear una lista para almacenar campus con programas activos.
	 	List<String> nombre_campus = new List<String>();
	 	try {
			 	// Iteramos Query con programas activos para cada campus
				for (AggregateResult ar:[SELECT Campus__c, Campus__r.Name FROM Programa_del_Campus__c WHERE Programa_Activo__c = true  GROUP BY Campus__c, Campus__r.Name]) {
					// Parsemaos AggregateResult a tipo string => campus
		      String campus = String.valueOf(ar.get('Name'));
					// Asignación de campus a varible => nombre_campus
		      nombre_campus.add(campus);
		    }	
	 		} catch (Exception e) {
    		System.debug('Landing_Programas_Academicos => obtenerCampus() error: ' + e.getMessage());	
	 		}
		// Handler para errores.
	 	if(nombre_campus.isEmpty() || nombre_campus == null) {
	 		System.debug('Landing_Programas_Academicos => obtenerContenedores() error: Lista nombre_campus está vacía.');
	 	} 
	 	// Regresamos => nombre_campus lleno.
    return nombre_campus;
	} // fin => obtenerCampusUvm().


	// Método para obtener lista de Contenedores por Nivles.
	@RemoteAction
	public static List<Map<String, String>> obtenerContenedores(String nivel) {
		// Traemos el id desde Configuración personalizada, dentro del objeto Proyecto 8x8 en el registro => id_niveles_solucion_cc
		Proyecto_8x8__c idNivelSolucion = Proyecto_8x8__c.getInstance();
		// Crear una lista para almacenar contenedores por niveles.
		List<Solution> detallesContenedor = [SELECT Solution.SolutionName, SolutionNote, Detalles__c FROM Solution 
														 						 WHERE Id IN  (SELECT CategoryData.RelatedSobjectId FROM CategoryData WHERE CategoryData.CategoryNodeID = :idNivelSolucion.id_niveles_solucion__c)
														 						 AND Nivel__c = :nivel];
		// Crear un mapa de lista para almacenar contenedores dentro del ciclo.
		Map<String, String> contenedorNiveles;
		// Crear una lista de mapas para almacenar detalles de contenedor.
		List<Map<String, String>> listaDetalles = new List<Map<String, String>>();
		try {
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

		} catch (Exception e) {
    	System.debug('Landing_Programas_Academicos => obtenerContenedores() error: ' + e.getMessage());	
		}
		// Handler para errores.
	 	if(listaDetalles.isEmpty() || listaDetalles == null) {
	 		System.debug('Landing_Programas_Academicos => obtenerContenedores() error: Lista Detalles está vacía.');
	 	} 
		// Regresamos => listaDetalles lleno.
		return listaDetalles;
	} // fin => obtenerContenedores().


	// Método para obtener lista de Niveles por campus.
	@RemoteAction
	public static List<String> obtenerNivelesCampus(String campus) {
	 	// Crear una lista para almacenar niveles de cada campus.
	 	List<String> tipo_niveles = new List<String>();
	 	try {
		 	// Iteramos Query con niveles activos por cada campus.
			for (AggregateResult ar:[SELECT Programa__r.Family FROM Programa_del_Campus__c WHERE Programa_Activo__c = true AND Campus__r.Name = :campus GROUP BY Programa__r.Family]) {
				// Parsemaos AggregateResult a tipo string => niveles 
	      String niveles = String.valueOf(ar.get('Family'));
				// Asignación de niveles a varible => tipo_niveles.
	      tipo_niveles.add(niveles);
	    }	
	 	} catch (Exception e ) {
    	System.debug('Landing_Programas_Academicos => obtenerNivelesCampus() error: ' + e.getMessage());
	 	}
	 	// Handler para errores.
	 	if(tipo_niveles.isEmpty() || tipo_niveles == null) {
	 		System.debug('Landing_Programas_Academicos => obtenerNivelesCampus() error: Lista tipos niveles está vacía.');
	 	} 
	 	// Regresamos => nombre_campus lleno.
    return tipo_niveles;
	}


	// Método para obtener lista de Verticales por campus y nivel.
	@RemoteAction
	public static List<String> obtenerVerticalNivel(String campus, String nivel) {
		// Crear un lista para almacenar verticales de cada nivel.
		List<String> tipo_vertical = new List<String>();
		try {
			// Iteramos Query con Verticales activas para cada nivel.
			for (AggregateResult ar:[SELECT Programa__r.Vertical__c FROM Programa_del_Campus__c 
															 WHERE Programa_Activo__c = true AND Campus__r.Name = :campus AND  Programa__r.Family = :nivel
															 GROUP BY Programa__r.Vertical__c]) {
				String verticales = String.valueOf(ar.get('Vertical__c'));
				// Llenamos lista con verticales.
				tipo_vertical.add(verticales);
			}
		} catch (Exception e) {
    	System.debug('Landing_Programas_Academicos => obtenerVerticalNivel() error: ' + e.getMessage());
		}
		// Handler  para errores.
		if (tipo_vertical.isEmpty() || tipo_vertical == null) {
	 		System.debug('Landing_Programas_Academicos => obtenerVerticalNivel() error: Lista tipos vertical está vacía.');
		}
		//Regresamos => tipo_vertical lleno.
		return tipo_vertical;
	}


	// Método para obtener programas dependiendo el campus el nivel y la vertical obtenidos.
	@RemoteAction
	public static List<Map<String, String>> obtenerProgramasAcademicos(String campus, String nivel, String vertical) {
		// Query para obtener programas academicos.
		List<Programa_del_Campus__c> programas_academicos = [SELECT Id, Programa__r.Name,  Programa__r.ID_Banner__c, Programa__c, Id_Externo__c, Programa__r.Family,  Programa__r.Programa_Salesforce__c
																												 FROM Programa_del_Campus__c
																												 WHERE Programa_Activo__c = true
																												 AND Campus__r.Name = :campus
																												 AND Programa__r.Family = :nivel
																												 AND Programa__r.Vertical__c = :vertical
																												 AND Programa__r.IsActive = true ];
		// Crear un mapa de lista para almacenar programas dentro del ciclo.
		Map<String, String> programas;
		// Crear una lista de mapas para almacenar programas_academicos.
		List<Map<String, String>> listaProgramas = new List<Map<String, String>>();
		try {
			// Iteración de => programas_academicos.
			for (Programa_del_campus__c a: programas_academicos) {
				// Instancia de mapa de lista para almacenar los registros.
				programas = new Map<String, String>();
				programas.put('Nombre', a.Programa__r.Name );
				programas.put('Id', a.Programa__r.Programa_Salesforce__c);
				// Llenamos lista de prorgamas.
				listaProgramas.add(programas);
			}
		} catch (Exception e) {
    	System.debug('Landing_Programas_Academicos => obtenerProgramasAcademicos() error: ' + e.getMessage());
		}
		// Handler  para errores.
		if (listaProgramas.isEmpty() || listaProgramas == null) {
	 		System.debug('Landing_Programas_Academicos => obtenerProgramasAcademicos() error: Lista Programas está vacía.');
		}
		// Regreamos => listaProgramas lleno.
		return listaProgramas;
	} // fin => obtenerProgramasAcademicos().
	

	// Método para obtener las soluciones recogiendo el idPrograma en el objeto => Programa_Salesforce__c
	@RemoteAction
	public static  List<Map<String, String>> obtenerSoluciones(String idPrograma) {
		// Query para obtener soluciones.
		List<Solution> solucionesPrograma = [SELECT SolutionName, Programa_Salesforce__c, Detalles__c  
																				 FROM Solution 
																				 WHERE Programa_Salesforce__c  =  :idPrograma ];
		// Crear un mapa de lista para almacenar soluciones dentro del ciclo.
		Map<String, String> soluciones;
		// Crear una lista de mapas para almacenar soluciones.
		List<Map<String, String>> listaSoluciones = new List<Map<String, String>>();
		try {
			// Iteración de => solucionesPrograma.
			for (Solution a: solucionesPrograma) {
				// Instancia de mapa de lista para almacenar los registros.
				soluciones = new Map<String, String>();
				// Asignación de programas a varible => a
				soluciones.put('Solucion', a.SolutionName);
				soluciones.put('Detalles', a.Detalles__c);
				soluciones.put('Id', a.Programa_Salesforce__c);
				// Llenamos lista de soluciones
				listaSoluciones.add(soluciones);
			}
		} catch (Exception e) {
    	System.debug('Landing_Programas_Academicos => obtenerSoluciones() error: ' + e.getMessage());
		}
		// Handler  para errores.
		if (listaSoluciones.isEmpty() || listaSoluciones == null) {
	 		System.debug('Landing_Programas_Academicos => obtenerSoluciones() error: Lista Soluciones está vacía.');
		}
		// Regreamos => listaSoluciones lleno. 
		return listaSoluciones;
	} // fin => obtenerSoluciones().

}