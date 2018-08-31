public without sharing class Ctrl_Landing_Campus {
    
    @RemoteAction
    public static List<String> obtenerCampusUvm(){
        
        //Obtencion de datos de los campus UVM
        List<Account> c_uvm = [SELECT id,Name FROM Account WHERE type = 'Campus UVM' ORDER BY Name ASC];
        
        //Creacion de una Lista para guardar los campus
        List<String> nombre_campus = new List<String>();
        
        //Asignacion de campus UVM a una nueva lista
        for (Account a: c_uvm ){
           	//Asigncacion del Nombre a la lista.
			nombre_campus.add(a.Name);            
       }
        
		System.debug(nombre_campus);
        
        //regreso de lista al metodo.
        return nombre_campus;
        
    } //end obtenerCampusUVM
    
    @RemoteAction
    public static List<String> obtenerSoluciones( String categoria, String campus){
        
        //Creacion de una Nueva Lista que guardara las Soluciones
        List<String> eventos_campus = new List<String>();
        
        //Busqueda de Soluciones mediante la categoria y Campus como parametro.
        List<Solution> s_list = [SELECT SolutionName,Detalles__c,Ubacion_Campus__c,Campus__r.name FROM Solution 
                                 WHERE Id IN 
                                 (SELECT CategoryData.RelatedSobjectId FROM CategoryData WHERE CategoryData.CategoryNodeID =: categoria)
                                 AND Campus__r.name = : campus];
        
        //Asignacion de Valores a lista
        for (Solution s: s_list){
            
            //Se agrega el Nombre y y el Detalle.
            eventos_campus.add(s.SolutionName); 
            eventos_campus.add(s.Detalles__c);

            if (categoria =='02n2F0000004HKYQA2'){

               
                try{

                    Location loc = s.Ubacion_Campus__c;
                    Double lat = loc.latitude;
                Double lon = loc.longitude;
                eventos_campus.add (string.valueof(lat));
                eventos_campus.add (string.valueof(lon));

                }catch(Exception e){
                    System.debug('>>>>Exception Solutions'+e);
                eventos_campus.add ('missing');

                }
               


                
                 
            }
           

            //eventos_campus.add(lat);
            //eventos_campus.add(lon);


        }
        
        System.debug(eventos_campus);
        
        //Regreso de la Lista al metodo.
        return eventos_campus;
        
    } // end obtenerSoluciones
    
    @RemoteAction
    public static Map<String,CategoryNode> obtenerMenu (String campus){
        
        //Se declara un Mapa que almacenara el menu final, dependiendo las opciones disponibles.
         Map<String, CategoryNode> active_menu = new Map <String,CategoryNode>();
        
		//Obtencion de todos los nodos de Categoria con su ID y Nombre (Master Label)        
		Map<ID, CategoryNode> cn = new Map<ID, CategoryNode>([SELECT Id, MasterLabel FROM CategoryNode]);
        
        System.debug('>>>Map CategoryNode'+cn);
        
        //Declaracion de una Lista para Buscar las Soluciones por Campus*
        List <Solution> sol = new List <Solution>([SELECT id FROM Solution where Campus__r.name =: campus]);
        
        System.debug('>>>Solution List'+sol);
        
        //Creacion de lista nueva para id's
        List <String> id_solutions = new List <String>();
        
        //Recorrido de soluciones para almacenar el id de las Soluciones "unicamente"
        for (Solution s: sol){ id_solutions.add (s.id); }
         System.debug('>>>id Soluciones'+id_solutions);
        
        //Recorrudo de los id en soluciones
        for (String s: id_solutions){
            
			//Por cada id de Soluciones Busca el Nodo de Categoria             
            for (CategoryData catData :[SELECT CategoryNodeId FROM CategoryData where RelatedSobjectId =: s]){
                
                System.debug('>>>for category node ID'+catData.CategoryNodeId);
                
                // Si la categoria se encuentra se Agrega elemento a nueva lista
                if(cn.containsKey(catData.CategoryNodeId)){
                    
                    System.debug('>>>Contiene la categoria:'+cn.get(catData.CategoryNodeId));
                    
                    //Se agrega el valor String del nodo y el Valor de Master Label
                 	active_menu.put( String.valueOf(catData.CategoryNodeId) , cn.get(catData.CategoryNodeId));
                    
                }else {
                    
                    //****Metodo Else se puede eliminar, se agrego para DEBUG 
					//****Muestra el comportamiento de todas las categorias, menos las categorias eliminadas
                    System.debug('>>> No Contiene la categoria:'+cn.get(catData.CategoryNodeId));
                    cn.remove (catData.CategoryNodeId); 
                }
                
            }
            
        }

        if (id_solutions.size() == 0){

            //active_menu.put('0','missing');
        }

       
        System.debug('>>>>>Active Menu After Remove CN'+cn);
        System.debug('>>>>>Active Menu After Remove MAP'+active_menu);
        

 		//Retorno de Mapa del nuevo menu.
		return active_menu;
        
    } //end obtenerMenu
        


 @RemoteAction
public static List<String> testRemote (String variable){

List <String> test_list = new List<String>();

test_list.add(variable);

return test_list;

 }


}