@isTest

public class Test_Modulo_Reasignacion {

  @testSetup static void setup(){

    campos_landing_assignacion__c la = new campos_landing_assignacion__c();
        la.Name = 'Campus';
        la.API__c = 'Campus__r.Name';
        la.Tipo__c = 'PICKLIST';
        la.Etiqueta__c = 'Campus';
        la.Orden__c = 1;
        insert la;
        
        //insertando expresiones en conf personalizada
        Expresiones_Torre_Control__c etc = new Expresiones_Torre_Control__c();
        etc.Name = 'PICKLIST-Igual a';
        etc.Expresion__c = 'CAMPO IN ( VALOR )';
        insert etc;

        //insertando configuracion personalizada de operadores
        OperadoresTorreControl__c operadores = new OperadoresTorreControl__c();
        operadores.Name = 'STRING';
        operadores.Operadores__c = '--Seleccione--,Igual a,Inicia con,Contiene,Termina con';
        insert operadores;

        //insertando conf personalizada para ciclos
        Generados_Ciclo__c ciclos = new Generados_Ciclo__c();
        ciclos.A_o_Fin__c = system.today().year() + 2;
        ciclos.A_o_Inicio__c = system.today().year();
        insert ciclos;

        Account campus = Test_Utils.creaCampus('Roma');
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
        Configuracion_Ciclo__c ciclo =  test_utils.creaConfCiclo('2018', 'Preparatoria', '2', 'Cuatrimestral', nuevocampus.id);
      //creando escuela de campus
        Escuela_de_Campus__c escuelaCampus = test_utils.creaEscuelaCampus(nuevoCampus.id, escuelaProcedencia.id);
        //creando contacto
        Contact nuevoContacto = Test_Utils.creaContacto('Eduardo', 'Javier',nuevoCampus.id,programaCampus.id,escuelaProcedencia.id);
        //Creando oportunidades

  }

 static testMethod void test_modulo_reasingar(){


      // User admin =  [SELECT id from user where profile.name = 'System Administrator' limit 1];
       User admin = Test_Utils.createUserAdmin();
       User u = Test_Utils.createUserGerentedeOperacionesUVM();

       System.runAs(admin){ insertTestTerritory();}

       Test.startTest();
       //lista de oportunidades para enviar a torre de control
       List<Opportunity> lOpps = new List<Opportunity>();
       //obteniendo oportunidad para validar que las inserciones esten correctas
       Opportunity opp = [Select id from Opportunity LIMIT 1];
       //llenando lista de filtros para excluir de torre de control
       List<String> lListaCampos = new List<String>{'periodo__c'};
       //declaracion de variable para guardar y validar en system asserts
       ctrl_modulo_reasignacion.DatosRetorno_Wrapper drw = new ctrl_modulo_reasignacion.DatosRetorno_Wrapper();
       //se agrega la opp creada a la lista de pruebas
       ctrl_modulo_reasignacion.DatosCampos_Wrapper drc = new ctrl_modulo_reasignacion.DatosCampos_Wrapper('Periodo__c','Ciclo','PICKLIST');
       
       Account campus = [SELECT id FROM Account WHERE Name ='Roma' LIMIT 1];

      //  Ctrl_Torre_de_Control.obtenerMapaOperadores(lListaCampos);

       String campus_id =  '\''+String.valueOf(campus.Id)+'\'';
       String user_id = '\''+String.valueOf(u.Id)+'\'';


       lOpps.add(opp);
       ctrl_modulo_reasignacion.obtenerMapaOperadores();
       ctrl_modulo_reasignacion.obtenerListadoDeValores();
       ctrl_modulo_reasignacion.pruebaOperadores();

       System.runAs(u){

      ctrl_modulo_reasignacion.obtenerAgentes('\'02\'');
      ctrl_modulo_reasignacion.getOperadorEquivalente('Periodo__c','Igual a','\'2\'','PICKLIST');
      ctrl_modulo_reasignacion.updateGerenteOpps(user_id,'[{"id":"0062F000005tBjwQAE"},{"id":"0062F000005tBGGQA2"}]');
      ctrl_modulo_reasignacion.get_tableOpps(campus_id,' and Periodo__c = \'2\'');
      ctrl_modulo_reasignacion.obtenerGerenteOppFiltradas('[{"campo":{"n":"Estatus__c","name":"Estatus","tipo":"PICKLIST"},"operador":{"name":"Igual a"},"valor":{"name":"\'Nuevo\'"},"editar":false}]',campus_id);
      ctrl_modulo_reasignacion.get_visibilidadCampus();

       

       }

      Test.stopTest();

    }


    @future
    public static void insertTestTerritory(){

    User u =  [SELECT id from user where profile.name = 'Gerente de Operaciones UVM' limit 1];

    List<Territory2Type> tt = [SELECT id, DeveloperName from Territory2Type  LIMIT 1];

    Territory2Model tm = [select Id,DeveloperName,Name from Territory2Model limit 1 ];

    Territory2 t1 = [SELECT id FROM Territory2 where Name = 'Zona Metropolitana Sur'];

    Territory2 t2 = new Territory2();
    t2.DeveloperName = 'Roma';
    t2.Territory2ModelId=tm.Id;
    t2.Name='Roma';
    t2.ID_Externo__c = '02';
    t2.Territory2TypeId=tt[0].Id;
    insert t2;

    UserTerritory2Association ta = new UserTerritory2Association();
    ta.UserId = u.Id;
    ta.Territory2Id =t2.Id;
    ta.RoleInTerritory2	='Territory2Manual';
    insert ta;





    }


}