/*

** Autor: Eduardo Pérez. - 11-08-2018
** Descripción: 
** Test Methods para controlador => Ctrl_Landing_Academico.cls
** Resultado de Test Methods: 100%.

*/

@isTest
private class Landing_Programas_Acadmicos_Test {
    @testSetup static void setUp()  {
        Account nuevoCampus = Test_Utils.creaCampus('Lomas Verdes');
        Programa_Salesforce__c programaSalesforce = Test_Utils.creaProgramaSalesforce('Bachillerato Cuatrimestre', 'Preparatoria');
        Product2 programa = Test_Utils.creaPrograma('Bachillerato Cuatrimestre',programaSalesforce.id,'Preparatoria','Cuatrimestral','BC');
        Programa_del_Campus__c programaCampus = test_utils.creaProgramaCampus('01-Preparatoria-120', programa.Id, nuevocampus.iD, 'Cuatrimestral');
        Solution nuevaSolucion = test_utils.crearSoluciones(nuevoCampus.id, programaSalesforce.id);
        CategoryNode nodo = [select id from CategoryNode limit 1];
        
        Test_Utils.crearCategoryData(nodo.id, nuevaSolucion.id);        
        List<CategoryData> detallesContenedor = [SELECT Id, CategoryNodeId FROM CategoryData];
        Proyecto_8x8__c idNivelSolucion = new  Proyecto_8x8__c();
        for(CategoryData a: detallesContenedor) {
            idNivelSolucion.id_niveles_solucion__c = a.CategoryNodeId;
        }
        insert idNivelSolucion;
    }
    
    // Test para => obtenerCampus()
    @isTest static void testObtenerCampus() {
        list<String> testCampus = Ctrl_Landing_Academico.obtenerCampus();
    }	
    
    @isTest static void testObtenerNivelesCampus()  {
        List<String> testNiveles = Ctrl_Landing_Academico.obtenerNivelesCampus('Lomas Verdes');
    }
    
    @isTest static void testObtenerVerticales() {
        List<String> testVerticales = Ctrl_Landing_Academico.obtenerVerticalNivel('Lomas Verdes', 'Preparatoria'); 
    }
    
    @isTest static void testObtenerProgramas() {
        List<Map<String, String>> testProgramas = Ctrl_Landing_Academico.obtenerProgramasAcademicos('Lomas Verdes', 'Preparatoria', 'Preparatoria');
    }
    
    @isTest static void testObtenerSoluciones() {
        List<Programa_Salesforce__c> programas =  [SELECT id, Name FROM Programa_Salesforce__c];
        List<String> lista_programas = new List<String>();
        for(Programa_Salesforce__c a:programas) {
            List<Map<String, String>> testProgramas = Ctrl_Landing_Academico.obtenerSoluciones(a.id);
        }
    }
    @isTest static void testObtenerContenedores() {
        List<Map<String, String>> contenedores = Ctrl_Landing_Academico.ObtenerContenedores('Preparatoria');
    }
}