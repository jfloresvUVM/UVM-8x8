/*

** Autor: Eduardo Pérez. - 11-08-2018
** Descripción: 
** Ctrl_Landing_Niveles
** Controlador para => Landing_Niveles.page

*/

public with sharing class Ctrl_Landing_Niveles {
	// Método para obtener lista de Niveles.
 @RemoteAction
 public static List<String> obtenerNiveles() {
 	// Crear una lista para almacenar niveles activos.
	 	List<String> niveles = new List<String>();

	 	// Iteramos Query con niveles activos.
		for (AggregateResult ar:[SELECT Programa__r.Family FROM Programa_del_Campus__c Where Programa_Activo__c = true Group by Programa__r.Family]) {
					// Parsemaos AggregateResult a tipo string => nivel.
          String nivel = String.valueOf(ar.get('Family'));
					// Asignación de nivel a varible => niveles.
          niveles.add(nivel);
    }	
	 	// Regresamos => niveles lleno.
    return niveles;
	} // fin => obtenerNiveles().

	// Método para obtener lista de Verticles recibiendo el Nivel seleccionado.
	@RemoteAction
	public static List<String> obtenerVerticalesNivel(String nivel) {
	 	// Crear una lista para almacenar niveles de cada campus.
	 	List<String> verticales = new List<String>();

	 	// Iteramos Query con niveles activos por cada campus.
		for (AggregateResult ar:[SELECT Programa__r.Vertical__c FROM Programa_del_Campus__c Where Programa_Activo__c = true AND Programa__r.Family = :nivel
														 GROUP BY Programa__r.Vertical__c]) {
					// Parsemaos AggregateResult a tipo string => vertical.
          String vertical = String.valueOf(ar.get('Vertical__c'));
					// Asignación de niveles a varible => verticales.
          verticales.add(vertical);
    }	
	 	// Regresamos => verticales llena.
    return verticales;
	} // fin => obtenerVerticalesNivel().

	// Método para obtener lista de Programas recibiendo
	// como parametro nivel y vertical
	@RemoteAction
	public static List<String> obtenerProgramas(String nivel, String vertical) {
		// Crear un lista para almacenar programas.
		List<String> programas = new List<String>();

		// Iteramos Query con programas activos.
		for (AggregateResult ar:[SELECT Name FROM Product2 WHERE IsActive = true AND Family = :nivel AND Vertical__c = :vertical
														 AND Id IN (select Programa__c from Programa_del_Campus__c where Programa_Activo__c = true) 
														 GROUP BY Name]) {
			// Parsemaos AggregateResult a tipo string => programa
			String programa = String.valueOf(ar.get('Name'));
			// Llenamos lista de programas.
			programas.add(programa);
		}
		return programas;
	}// fin => obtenerProgramas().

	// Método para obtener Campus recibiendo el nivel y el programa.
	@RemoteAction
	public static List<String> obtenerCampus(String nivel, String programa) {
		// Crear una lista para almacenar campus
		List<String> lista_campus = new List<String>();

		// Iteramos Query de campus con programas activos.
		for (AggregateResult ar: [SELECT Campus__c , Campus__r.Name FROM Programa_del_Campus__c	WHERE Programa_Activo__c = true	AND Programa_Web__c = true
															AND Programa__r.Family = :nivel
															AND  Programa__r.Name = :programa
															GROUP BY Campus__c,  Campus__r.Name
															ORDER BY Campus__r.Name])  {
			// Parsemaos AggregateResult a tipo string => campus
			String campus = String.valueOf(ar.get('Name'));
			// Llenamos lista de campus.
			lista_campus.add(campus);
		}
		System.debug('LISTA DE CAMPUS' + lista_campus);
		// Regresamos => lista_campus llena.
		return lista_campus;
	}// fin => obtenerCampus().
}