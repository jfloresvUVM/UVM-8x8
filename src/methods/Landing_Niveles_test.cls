/*

** Autor: Eduardo Pérez. - 11-08-2018
** Descripción: 
** Test Methods para controlador => Ctrl_Landing_Niveles.cls
** Resultado de Test Methods: 100%.

*/

@isTest
private with sharing class Landing_Niveles_test {
	// Creamos un método que utiliza la clase Test_Utils para insertar nuevos campus.
	@testSetup static void setUp()  {
		// las variables necesarias para hacer funcionar nuestros test
    Account nuevoCampus = Test_Utils.creaCampus('Lomas Verdes');
    Programa_Salesforce__c programaSalesforce = Test_Utils.creaProgramaSalesforce('Bachillerato Cuatrimestre', 'Preparatoria');
    Product2 programa = Test_Utils.creaPrograma('Bachillerato Cuatrimestre',programaSalesforce.id,'Preparatoria','Cuatrimestral','BC');
    Programa_del_Campus__c programaCampus = test_utils.creaProgramaCampus('01-Preparatoria-120', programa.Id, nuevocampus.iD, 'Cuatrimestral');
	}
	// Test de prueba para metodo => obtenerNiveles().
	@isTest static void testObtenerNiveles() {
		List<String> niveles = Ctrl_Landing_Niveles.obtenerNiveles();
	}
	// Test de prueba para metodo => obtenerVerticalesNivel().
	@isTest static void testObtnerVerticalesNivel() {
		List<String> verticales = Ctrl_Landing_Niveles.obtenerVerticalesNivel('Preparatoria');
	}
	// Test de prueba para metodo => obtenerProgramas().
	@isTest static void testObtenerProgramas() {
		List<String> verticales = Ctrl_Landing_Niveles.obtenerProgramas('Preparatoria', 'Preparatoria');
	}
	// Test de prueba para metodo obtenerCampus().
	@isTest static void testObtenerCampus() {
		List<String> campus = Ctrl_Landing_Niveles.obtenerCampus('Preparatoria', 'Bachillerato Cuatrimestre');
	}
}