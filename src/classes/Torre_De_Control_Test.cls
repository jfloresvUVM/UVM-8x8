/*---------------------------------------------------------------------------------------------------------

Autor: Javier Flores - 29-08-2018
Descripción: Clase test para probar funcionalidad de torre de control

Modificado: Javier Flores - 30-08-2018

---------------------------------------------------------------------------------------------------------*/
@isTest
public class Torre_De_Control_Test {
    
    //Método para insertar los datos necesarios para el test
    @testSetup static void setup(){
        //insertando campaña fija
        Campa_a_Fija_CC__c cf2 = new Campa_a_Fija_CC__c();
        cf2.Pertenece_a__c='Brittel';
        cf2.Name ='Brittel';
        insert cf2;
        
        //insertando registros en la configuracion personalizada de campos
        Campos_Torre_Control__c tc = new Campos_Torre_Control__c();
        tc.Name = 'Campus';
        tc.API__c = 'Campus__r.Name';
        tc.Tipo__c = 'PICKLIST';
        tc.Etiqueta__c = 'Campus';
        tc.Orden__c = 1;
        insert tc;
        
        //insertando expresiones en conf personalizada
        Expresiones_Torre_Control__c etc = new Expresiones_Torre_Control__c();
        etc.Name = 'PICKLIST-Igual a';
        etc.Expresion__c = 'CAMPO IN ( VALOR )';
        insert etc;
        
        //Creando nuevo campus
        Account nuevoCampus = Test_Utils.creaCampus('Roma');
        //creando escuela de procedencia
        Account escuelaProcedencia = Test_Utils.creaEscuela('EscuelaProcedencia');
        //creando programa salesforce
        Programa_Salesforce__c programaSalesforce = Test_Utils.creaProgramaSalesforce('Bachillerato Cuatrimestre', 'Preparatoria');
		//creando programa
        Product2 programa = Test_Utils.creaPrograma('Bachillerato Cuatrimestre',programaSalesforce.id,'Preparatoria','Cuatrimestral','BC');
		//creando programa de campus
        Programa_del_Campus__c programaCampus = test_utils.creaProgramaCampus('01-Preparatoria-120', programa.Id, nuevocampus.iD, 'Cuatrimestral');
		//creando configuracion de ciclo
        Configuracion_Ciclo__c ciclo =  test_utils.creaConfCiclo('2018', 'Preparatoria', '2', 'Cuatrimestral');
		//creando escuela de campus
        Escuela_de_Campus__c escuelaCampus = test_utils.creaEscuelaCampus(nuevoCampus.id, escuelaProcedencia.id);
        //creando contacto
        Contact nuevoContacto = Test_Utils.creaContacto('Eduardo', 'Javier',nuevoCampus.id,programaCampus.id,escuelaProcedencia.id);        
    }
    
    //Test method para probar funcionalidad
    static testmethod void busquedaTorreControl_Success(){
        //query de prueba para crear campaña
        String queryTest = 'Select Id ,Nivel__c,Name,Campus__r.Name,Team_8x8__c,tipo_de_team_8x8__c,Prioiridad_de_Oportunidad_8x8__c, '+
        'Score_1_8x8__c,Score_2_8x8__c,Intentos_Campa_a_8x8__c,Contador_de_toques__c,Origen_Actual_8x8__c,Canal_Actual_8x8__c,'+
        'Tipo_de_Base__c,Nivel_de_Inter_s__c,Campa_a_CEC_Actual__c,SubCampa_a_8x8__c,Ultimo_Toque_Call_Center__c ' + 
        'from Opportunity';

        //lista de oportunidades para enviar a torre de control
        List<Opportunity> lOpps = new List<Opportunity>();
        //obteniendo oportunidad para validar que las inserciones esten correctas
        Opportunity opp = [Select id from Opportunity LIMIT 1];
        //llenando lista de filtros para excluir de torre de control
        List<String> lListaCampos = new List<String>{'periodo__c'};
        //declaracion de variable para guardar y validar en system asserts
        Ctrl_Torre_de_Control.DatosRetorno_Wrapper drw = new Ctrl_Torre_de_Control.DatosRetorno_Wrapper();
        //se agrega la opp creada a la lista de pruebas
        lOpps.add(opp);
        
        Test.startTest();
        Ctrl_Torre_de_Control.obtenerMapaOperadores(lListaCampos);
        Ctrl_Torre_de_Control.obtenerListadoDeValores();
        drw = Ctrl_Torre_de_Control.hacerSuperQuery('[{"campo":{"n":"Periodo__c","name":"Ciclo","tipo":"PICKLIST"},"operador":{"name":"Igual a"},"valor":{"name":"\'2\'"},"editar":true,"$$hashKey":"object:8"}]');
        Ctrl_Torre_de_Control.crearCampania(queryTest,'Batch','Test',system.today()+'',system.today()+'','Brittel',lOpps,'A0',21,'Brittel','Brittel','test');
        Ctrl_Torre_de_Control.obtieneCampanias('Brittel');
        Test.stopTest();
        
        //validaciones finales
        System.assert(opp.id != null);
        System.assert(drw.query != '');
    }
}