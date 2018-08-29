        var app = angular.module('tower', []);
        console.log('entrando al inicio de la app javier');


        app.controller("llenaTabla", function($scope) {

        //Variable de objeto de campos seleccionados
        $scope.seleccionados = [];
        $scope.tipoActivo = "STRING";
        $scope.spinner = false;
        $scope.tipoCampania = "0";
        $scope.query;
        $scope.nombreCampania;
        $scope.fechaInicio;
        $scope.fechaFin;
        $scope.campaniaSeleccionada;
        $scope.callCenterSeleccionado = '0';
        $scope.campanias = [];
        $scope.listaOportunidades = [];
        $scope.mapaValores;
        $scope.prioridadLetra = '-Seleccione-';
        $scope.prioridadNumero = '-Seleccione-';
        $scope.score2;
        $scope.listaCamposAgregados = [];
        $scope.permiteBuscar = false;
        $scope.verTablaOpps = false;

        var Master = {};
 
        Master.loadingModal = function (show) {
                      $("#loadingModal").modal(show);
                  }; 

        //funcion al iniciar pagina
        $scope.init = function () {
            Master.loadingModal('show');
            $scope.obtenerCampos();

            //Llamado al metodo para llenar los catalogos (catalogos o campos tipo reference o picklist)
            Ctrl_Torre_de_Control.obtenerListadoDeValores(function(result, event){
                if (event.status) {
                    //guardar resultados en una variable
                    var mapaResultados = result;
                    console.log('entrando a respuesta obtenerListadoDeValores');
                    console.log(result);
                    
                    $scope.mapaValores = result;
                    $scope.$apply();
                }
            });
            setTimeout(function () {
                Master.loadingModal('hide');
            }, 1000);         
        }
        
        //metodo para regrescar la lista de campos
        $scope.obtenerCampos = function(){            
            var campos = [];            

            //M�todo que obtiene la lista de campos iniciales.
            Visualforce.remoting.Manager.invokeAction(
               "Ctrl_Torre_de_Control.obtenerMapaOperadores", $scope.listaCamposAgregados,
                    function(result, event) {                                 
                        if(result) {
                            var mapaResultados = result;

                            //se inicializa la lista de campos
                            campos.push({ n:"0", name:"--Seleccione--" });
                            //se recorre el resultado del m�todo de apex y se recorre los resultados
                            for(var key in mapaResultados){
                                //a la lista de campos se agrega cada elemento de la respuesta
                                campos.push({
                                    n:key,//nombre API
                                    name:mapaResultados[key].label,//etiqueta
                                    tipo:mapaResultados[key].tipo//tipo de campos
                                });
                            }
                            //se asigna la lista de campos iniciales
                            $scope.campos = campos;

                            //se pone un valor por default
                            $scope.miCampoSeleccionado = { n:"0", name:"--Seleccione--" };
                            //aplica los cambios a la pagina.
                            $scope.$apply();
                        }
                    },
               {escape: false,timeout: 240000} // No escaping, please
            );
        }

        $scope.init();
        //Agrega filtro a la lista
        $scope.agregarFiltro = function(){
                                    console.log("mi valor seleccionado:");
                                    console.log($scope.miValorSeleccionado);

                                    if($scope.miCampoSeleccionado.name == '--Seleccione--'){
                                        $scope.alertaError('Debe seleccionar un campo antes de agregar filtro.');
                                    }else if($scope.miOperadorSeleccionado.name == '--Seleccione--'){
                                        $scope.alertaError('Debe seleccionar un Operador antes de agregar filtro.');
                                    }else if($scope.miValorSeleccionado.length == 0 || $scope.miValorSeleccionado.name == ''){
                                        $scope.alertaError('Debe seleccionar un Valor antes de agregar filtro.');
                                    }else{

                                        console.log('obteniendo index del array de campos');
                                        console.log($scope.miCampoSeleccionado);
                                        $scope.listaCamposAgregados.push($scope.miCampoSeleccionado.n);
                                        //si valor seleccionado es multipicklist y hay mas de uno seleccionado
                                        if($scope.miValorSeleccionado.length >= 1){
                                            //variable auxiliar
                                            var aux = "";
                                            //se recorre el array de los valores del multipicklist
                                            for(var i = 0; i < $scope.miValorSeleccionado.length; i++){
                                                //si es el primer elemento
                                                if(aux == ""){
                                                    aux+= "'" + $scope.miValorSeleccionado[i].name + "'";
                                                }else{//si hay ya un elemento se concatena con el siguiente
                                                    aux+= "," + "'" + $scope.miValorSeleccionado[i].name + "'";
                                                }
                                                
                                            }
                                            //se asigna el valor para agregar al filtro
                                            $scope.miValorSeleccionado = { name:aux }
                                        }

                                        //filtro que se agregara al arreglo de filtros
                                        var filtro = {
                                            campo:$scope.miCampoSeleccionado,//valor del campo
                                            operador:$scope.miOperadorSeleccionado,//valor del operador
                                            valor:$scope.miValorSeleccionado,//valores seleccionados
                                            editar:true//variable que dicta si se puede editar el filtro o no
                                        }
                                        //se agrega el filtro a la lista
                                        $scope.seleccionados.push(filtro);

                                        //reiniciar picklist cuando se quita un campo que ya se agrego como filtro
                                        $scope.obtenerCampos();
                                        $scope.miCampoChange();
                                        $scope.valores = [];
                                        $scope.tipoActivo = 'String';
                                        $scope.validasiPuedeBuscar();
                                    }                                    
                                }
        $scope.seleccionarValor = function(e){
                                    console.log(e);
                                    //dependiendo del tipo de campo se obtiene el valor del input para agregarlo al filtro
                                    if($scope.tipoActivo == "REFERENCE" || $scope.tipoActivo == "PICKLIST"){
                                        $scope.miValorSeleccionado = e;                                    
                                    }else if($scope.tipoActivo == "STRING"){
                                        $scope.miValorSeleccionado = { name:e };
                                    }else if($scope.tipoActivo == "DATETIME" || $scope.tipoActivo == "DATE"){
                                        console.log("FECHAA");
                                        console.log(e);
                                        $scope.miValorSeleccionado = { name:e };
                                    }else if($scope.tipoActivo == "BOOLEAN"){
                                        $scope.miValorSeleccionado = e;
                                    }else if($scope.tipoActivo == "DOUBLE"){
                                        $scope.miValorSeleccionado = { name:e };
                                    }
                                    
                                }
        //funcion para eliminar filtro y agregarlo a la lista de nuevo
        $scope.eliminarFiltro = function(index,filtroSeleccionado){
            console.log("entrando a eliminar filtro");
            console.log(filtroSeleccionado.campo.n);
            $scope.seleccionados.splice(index, 1);
            console.log("campos seleccionados lista");
            console.log($scope.listaCamposAgregados.indexOf(filtroSeleccionado.campo.n));
            console.log($scope.listaCamposAgregados);
            $scope.listaCamposAgregados.splice($scope.listaCamposAgregados.indexOf(filtroSeleccionado.campo.n), 1);
            $scope.obtenerCampos();

        }
        //Agrega filtro a la lista
        $scope.miCampoChange = function(){
                                console.log(":::valor de campos");
                                console.log($scope.campos);
                                //for que recorre el mapa de operados - valores para validar que operadores se deben mostrar
                                for(var key in $scope.operadoresMap){
                                    //si el tipo coincide con el activo
                                    if($scope.operadoresMap[key].tipo == $scope.miCampoSeleccionado.tipo){
                                        //se asigna como tipo activo el tipo que coincidio (String,Reference, etc.)
                                        $scope.tipoActivo = $scope.operadoresMap[key].tipo;
                                        //se asigna la lista de operadores dependiendo del tipo que esta activo
                                        $scope.operadores = $scope.operadoresMap[key].valores;                                        
                                    }                                    
                                }

                                console.log("tipo actual: ");
                                console.log($scope.tipoActivo);
                                console.log($scope.miCampoSeleccionado);

                                //se inicializan variables de nuevo
                                $scope.miOperadorSeleccionado = { name:"--Seleccione--" }; 
                                //$scope.miValorSeleccionado = { name:"--Seleccione--" };
                                $scope.miValorSeleccionadoBool = { name:"--Seleccione--" };
                                $scope.valores = [];

                                for(var i = 0; i < $scope.mapaValores[$scope.miCampoSeleccionado.n].length; i++){
                                    console.log($scope.mapaValores[$scope.miCampoSeleccionado.n]);
                                    $scope.valores.push({ name : $scope.mapaValores[$scope.miCampoSeleccionado.n][i] });
                                }
                                
                            }

        //Funcion de ejecucion de query y count()
        $scope.opo = function(){
                        //Mapa de claves linea de negocio
                        var mapaClaves = new Map();

                        //variables utilizadas para llenar el grafico de campus de tipo circulo
                        var mapaCampus = new Map();
                        var lListaCampus = [];
                        var lListaNumero = [];

                        //variables utilizadas para llenar el grafico de prioridades para primer grafico
                        var mapaPrioridades = new Map();
                        var lListaPrioridades = [];
                        var lListaValorPrioridades = [];

                        //variables utilizadas para llenar el grafico de lineas de negocio para segundo grafico
                        var mapaLN = new Map();
                        var lListaLN = [];
                        var lListaLNValores = [];

                        //inicio de logica para buscar las oporutnidades
                        console.log('BUSCAR:');
                        console.log(JSON.stringify($scope.seleccionados));


                        if($scope.seleccionados.length == 0){
                            $scope.alertaVibra('Antes de buscar agrega al menos 1 filtro...');
                            $scope.verTablaOpps = false;
                        }else{
                            Master.loadingModal('show');
                            //mandando todos los filtros
                            Visualforce.remoting.Manager.invokeAction(
                               "Ctrl_Torre_de_Control.hacerSuperQuery", JSON.stringify($scope.seleccionados),
                                    function(result, event) {                                    
                                        if(result.lListaOportunidades) {                                        
                                            var limite = 10;
                                            if(result.lListaOportunidades.length < 10){
                                                limite = result.lListaOportunidades.length;
                                            }

                                            console.log(result.lListaOportunidades);
                                            $scope.listaOportunidades = result.lListaOportunidades;
                                            console.log("tama�o de lista de opps:::");
                                            console.log($scope.listaOportunidades.length + ' ' +limite);
                                            console.log("::::::::::::::::");
                                            console.log("valor de la lista de oportunidades");
                                            console.log($scope.listaOportunidades);
                                            console.log("::::::::::::::::");
                                            $('#toportunidad').html('');
                                            if( result.lListaOportunidades.length > 0){ 
                                                $scope.verTablaOpps = true;

                                                //for para llenar los graficos con todos los registros resultantes
                                                for(i = 0; i < result.lListaOportunidades.length; i++){
                                                    console.log("recorriendo for para graficos " + i);
                                                    //Llenando el mapa para llenar grafico de campus
                                                    if(mapaCampus.get(result.lListaOportunidades[i].Campus__r.Name) == null){
                                                        mapaCampus.set(result.lListaOportunidades[i].Campus__r.Name, 1);
                                                    }else{
                                                        mapaCampus.set(result.lListaOportunidades[i].Campus__r.Name, mapaCampus.get(result.lListaOportunidades[i].Campus__r.Name) + 1);
                                                    }

                                                    //llenado del mapa para prioridades primer grafico
                                                    if(mapaPrioridades.get(result.lListaOportunidades[i].Prioiridad_de_Oportunidad_8x8__c) == null){
                                                        mapaPrioridades.set(result.lListaOportunidades[i].Prioiridad_de_Oportunidad_8x8__c, 1);
                                                    }else{
                                                        mapaPrioridades.set(result.lListaOportunidades[i].Prioiridad_de_Oportunidad_8x8__c, mapaPrioridades.get(result.lListaOportunidades[i].Prioiridad_de_Oportunidad_8x8__c) + 1);
                                                    }

                                                    //Llenando el mapa para llenar grafico de Linea de negocio
                                                    if(mapaLN.get(result.lListaOportunidades[i].Nivel__c) == null){
                                                        mapaLN.set(result.lListaOportunidades[i].Nivel__c, 1);
                                                    }else{
                                                        mapaLN.set(result.lListaOportunidades[i].Nivel__c, mapaLN.get(result.lListaOportunidades[i].Nivel__c) + 1);
                                                    }
                                                }

                                                //for que llena las listas para alimentar el grafico de campus
                                                for (var [key, value] of mapaCampus) {
                                                    lListaCampus.push(key);
                                                    lListaNumero.push(value);
                                                }

                                                //for que llena las listas para alimentar el grafico de prioridades
                                                for (var [key, value] of mapaPrioridades) {
                                                    lListaPrioridades.push(key);
                                                    lListaValorPrioridades.push(value);
                                                }

                                                //for que llena las listas para alimentar el grafico de linea de negocio
                                                for (var [key, value] of mapaLN) {
                                                    lListaLN.push(key);
                                                    lListaLNValores.push(value);
                                                }

                                                console.log("valor de mapa prioridades");
                                                console.log(mapaPrioridades);

                                                //for para llenar el preview
                                                for(i = 0; i < limite; i++){

                                                    $('#toportunidad').append(
                                                        '<tr>'+
                                                        '<td>'+
                                                        (result.lListaOportunidades[i].Id == undefined ? '' :result.lListaOportunidades[i].Id)+
                                                        '</td>'+
                                                        '<td>'+
                                                        (result.lListaOportunidades[i].Name == undefined ? '' :result.lListaOportunidades[i].Name)+
                                                        '</td>'+
                                                        '<td>'+
                                                        (result.lListaOportunidades[i].Nivel__c == undefined ? '' :result.lListaOportunidades[i].Nivel__c)+
                                                        '</td>'+
                                                        '<td>'+
                                                        (result.lListaOportunidades[i].Campus__r.Name == undefined ? '' :result.lListaOportunidades[i].Campus__r.Name)+
                                                        '</td>'+
                                                        '<td>'+                                                    
                                                        (result.lListaOportunidades[i].Team_8x8__c == undefined ? '' :result.lListaOportunidades[i].Team_8x8__c)+
                                                        '</td>'+
                                                        '<td>'+                                                    
                                                        (result.lListaOportunidades[i].tipo_de_team_8x8__c == undefined ? '' :result.lListaOportunidades[i].tipo_de_team_8x8__c)+
                                                        '</td>'+
                                                        '<td>'+                                                    
                                                        (result.lListaOportunidades[i].Prioiridad_de_Oportunidad_8x8__c == undefined ? '' :result.lListaOportunidades[i].Prioiridad_de_Oportunidad_8x8__c)+
                                                        '</td>'+
                                                        '<td>'+                                                    
                                                        (result.lListaOportunidades[i].Score_1_8x8__c == undefined ? '' :result.lListaOportunidades[i].Score_1_8x8__c)+
                                                        '</td>'+
                                                        '<td>'+                                                    
                                                        (result.lListaOportunidades[i].Score_2_8x8__c == undefined ? '' :result.lListaOportunidades[i].Score_2_8x8__c)+
                                                        '</td>'+
                                                        '<td>'+                                                    
                                                        (result.lListaOportunidades[i].Intentos_Campa_a_8x8__c == undefined ? '' :result.lListaOportunidades[i].Intentos_Campa_a_8x8__c)+
                                                        '</td>'+
                                                        '<td>'+                                                    
                                                        (result.lListaOportunidades[i].Contador_de_toques__c == undefined ? '' :result.lListaOportunidades[i].Contador_de_toques__c)+
                                                        '</td>'+
                                                        '<td>'+                                                    
                                                        (result.lListaOportunidades[i].Origen__c == undefined ? '' :result.lListaOportunidades[i].Origen__c)+
                                                        '</td>'+
                                                        '<td>'+                                                    
                                                        (result.lListaOportunidades[i].Origen_Actual_8x8__c == undefined ? '' :result.lListaOportunidades[i].Origen_Actual_8x8__c)+
                                                        '</td>'+
                                                        '<td>'+                                                    
                                                        (result.lListaOportunidades[i].Canal_Actual_8x8__c == undefined ? '' :result.lListaOportunidades[i].Canal_Actual_8x8__c)+
                                                        '</td>'+
                                                        '<td>'+                                                    
                                                        (result.lListaOportunidades[i].Tipo_de_Base__c == undefined ? '' :result.lListaOportunidades[i].Tipo_de_Base__c)+
                                                        '</td>'+
                                                        '<td>'+                                                    
                                                        (result.lListaOportunidades[i].Nivel_de_Inter_s__c == undefined ? '' :result.lListaOportunidades[i].Nivel_de_Inter_s__c)+
                                                        '</td>'+
                                                        '<td>'+                                                    
                                                        (result.lListaOportunidades[i].Campa_a_CEC_Actual__c == undefined ? '' :result.lListaOportunidades[i].Campa_a_CEC_Actual__c)+
                                                        '</td>'+
                                                        '<td>'+                                                    
                                                        (result.lListaOportunidades[i].SubCampa_a_8x8__c == undefined ? '' :result.lListaOportunidades[i].SubCampa_a_8x8__c)+
                                                        '</td>'+
                                                        '<td>'+                                                    
                                                        (result.lListaOportunidades[i].Ultimo_Toque_Call_Center__c == undefined ? '' :result.lListaOportunidades[i].Ultimo_Toque_Call_Center__c)+
                                                        '</td>'+
                                                        '</tr>'
                                                        );
                                                        $scope.$apply();
                                                }                                            
                                            }else{
                                                $scope.verTablaOpps = false;
                                            }

                                            //Llenando grafico 1
                                            new Chartist.Line('.ct-chart', {
                                                labels: lListaPrioridades,
                                                series: [
                                                    lListaValorPrioridades
                                                ]
                                            }, {
                                                low: 0,
                                                showArea: true
                                            });
                                            //fin llenado grafico 1

                                            //Llenando grafico 2
                                            new Chartist.Bar('.ct-chart2', {
                                                labels: lListaLN,
                                                series: lListaLNValores
                                            }, {
                                                distributeSeries: true
                                            });
                                            //fin de llenado de grafico 2

                                            //Llenando graafico 3 ( campus )
                                            var data = {
                                                labels: lListaCampus,
                                                series: lListaNumero
                                            };

                                            var options = {
                                                labelInterpolationFnc: function(value) {
                                                    return value[0]
                                                }
                                            };

                                            var responsiveOptions = [
                                                ['screen and (min-width: 640px)', {
                                                    chartPadding: 50,
                                                    labelOffset: 50,
                                                    labelDirection: 'explode',
                                                    labelInterpolationFnc: function(value) {
                                                        return value;
                                                    }
                                                }],
                                                ['screen and (min-width: 1024px)', {
                                                    labelOffset: 40,
                                                    chartPadding: 20
                                                }]
                                            ];

                                            new Chartist.Pie('.ct-chart3', data, options, responsiveOptions);
                                            //fin llenado grafico 3

                                            //evaluando resultados de los mapas para los graficos
                                            console.log("valor del mapa ya en for campus");
                                            console.log(mapaCampus);


                                            $('#Query').text(result.query);
                                            $scope.query = result.query;

                                            //logica para separar numeros miles con commas
                                            var numeroCommas = '';
                                            var parts = result.lListaOportunidades.length.toString().split(".");
                                            parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",");
                                            parts.join(".");

                                            $('#totalReg').text(parts.join("."));

                                            setTimeout(function () {
                                                $scope.$apply();
                                                Master.loadingModal('hide');
                                            }, 1000);

                                            // something more to do?
                                        } else {
                                            console.log("There was an error");
                                            setTimeout(function () {
                                                $scope.$apply();
                                                Master.loadingModal('hide');
                                            }, 1000);                                      
                                        } 
                                    },
                               {escape: false} // No escaping, please
                           );  
                        }                     

                                              
                    }

        //funcion para validar si se puede buscar y no hay filtros sin guardar
        $scope.validasiPuedeBuscar = function(){
            
            $scope.permiteBuscar = true;
            console.log("valor de la variable $scope.seleccionados");
            console.log($scope.seleccionados);

            for(var i = 0; i < $scope.seleccionados.length; i++){
                if($scope.seleccionados[i].editar == false){
                    console.log("entrando al if de busqueda de banderas");
                    console.log($scope.seleccionados[i].editar);
                    $scope.permiteBuscar = false;
                }
            }

            console.log("valor de permite buscar");
            console.log($scope.permiteBuscar);
        }

        //hacer filtro editable
        $scope.makeEditable = function(sel){
                                console.log(sel);
                                sel.editar = false;
                                console.log(sel);
                                console.log("valor de seleccionados editar");
                                console.log($scope.seleccionados);
                                $scope.validasiPuedeBuscar();
                            }

        //guardar cambios editable
        $scope.saveEditable = function(sel){
                                console.log(sel);
                                sel.editar = true;
                                console.log(sel);
                                console.log("valor de seleccionados editar");
                                console.log($scope.seleccionados);
                                $scope.validasiPuedeBuscar();
                            }
        //funcion para alerta error
        $scope.alertaError = function(mensaje){
                                swal({
                                  type: 'error',
                                  title: 'Oops...',
                                  text: mensaje,
                                  confirmButtonColor: '#00ab42'
                                })
                            }
        //funcion para alerta error
        $scope.alertaInfo = function(mensaje){
                                swal({
                                  type: 'info',
                                  title: 'Guardado...',
                                  text: mensaje,
                                  confirmButtonColor: '#00ab42'
                                })
                            }
        //funcion aplicar
        $scope.aplicar = function(){
                            if($scope.seleccionados.length == 0){
                                $scope.alertaVibra('Antes de aplicar agrega al menos 1 filtro...');
                            }else{
                                $scope.validarEnvio();
                            }
                        }
        //funcion de alerta vibratoria
        $scope.alertaVibra = function(texto){
                                swal({
                                  title: 'Hey!... &#191;Y los filtros?',
                                  text: texto,
                                  animation: false,
                                  customClass: 'animated zoomInDown',
                                  confirmButtonColor: '#00ab42'
                                })
                            }
        //funcion para alerta confirmacion 
        $scope.alertaConf = function(mensaje){
                                const swalWithBootstrapButtons = swal.mixin({
                                  confirmButtonClass: 'btn btn-success',
                                  cancelButtonClass: 'btn btn-danger',
                                  buttonsStyling: false,
                                })

                                swalWithBootstrapButtons({
                                  title: '&#191;Estas seguro que quieres aplicar la solicitud?',
                                  text: "Ya no habr\xE1 vuelta atras...",
                                  type: 'warning',
                                  showCancelButton: true,
                                  confirmButtonText: 'Si!, Aplicar!',
                                  cancelButtonText: 'No, un momento...!',
                                  reverseButtons: true
                                }).then((result) => {
                                  if (result.value) {                                    
                                    $scope.alertaConf2();
                                  } else if (
                                    // Read more about handling dismissals
                                    result.dismiss === swal.DismissReason.cancel
                                  ) {
                                    swalWithBootstrapButtons(
                                      'Cancelado',
                                      'La solicitud se ha cancelado',
                                      'error'
                                    )
                                  }
                                })
                            }
        //segunda alerta de confirmacion
        $scope.alertaConf2 = function(mensaje){
                                const swalWithBootstrapButtons = swal.mixin({
                                  confirmButtonClass: 'btn btn-success',
                                  cancelButtonClass: 'btn btn-danger',
                                  buttonsStyling: false,
                                })

                                swalWithBootstrapButtons({
                                  title: 'Espera... &#191;Est\xE1s completamente seguro que quieres continuar?',
                                  text: "Piensalo bien...",
                                  type: 'warning',
                                  showCancelButton: true,
                                  confirmButtonText: 'Si!, sin miedo al exito!',
                                  cancelButtonText: 'No, ya me arrepenti!',
                                  reverseButtons: true
                                }).then((result) => {
                                  if (result.value) {
                                    swalWithBootstrapButtons(
                                      'Aplicado!',
                                      'La solicitud se esta procesando',
                                      'success'
                                    )
                                    $scope.crearCampania();
                                  } else if (
                                    // Read more about handling dismissals
                                    result.dismiss === swal.DismissReason.cancel
                                  ) {
                                    swalWithBootstrapButtons(
                                      'Cancelado',
                                      'La solicitud se ha cancelado',
                                      'error'
                                    )
                                  }
                                })
                            }
        //funcion para validar si si se quiere crear la campa�a
        $scope.validarEnvio = function(){
            console.log($scope.campaniaSeleccionada);
            if($scope.nombreCampania == undefined){
                //$scope.alertaError('Debe llenar el campo Nombre de la sub-campa�a CEC');
                (async function getNombreSubCampaniaCEC () {
                const {value: nombreSubCampaniaCEC} = await swal({
                  title: 'Debe llenar el campo \'Nombre de la sub-campa&#241;a CEC\'',
                      input: 'text',
                      inputPlaceholder: 'Puede asignar un nombre desde esta ventana',
                      type: 'error',
                      confirmButtonColor: '#00ab42'
                })

                if (nombreSubCampaniaCEC) {
                    $scope.nombreCampania = nombreSubCampaniaCEC;
                    $scope.alertaInfo('Se ha asignado \'' + nombreSubCampaniaCEC + '\' como nombre.');
                }
                $scope.$apply();
                })()
            }else if($scope.fechaInicio == undefined){
                $scope.alertaError('Debe llenar el campo Fecha de Inicio');
            }else if($scope.fechaFin == undefined){
                $scope.alertaError('Debe llenar el campo Fecha de Fin');
            }else if($scope.callCenterSeleccionado == 0){
                $scope.alertaError('Debe llenar el campo Tipo de Team');
            }else if($scope.campaniaSeleccionada == '-Seleccione-'){
                $scope.alertaError('Debe llenar el campo Team');
            }else if($scope.prioridadLetra == '-Seleccione-'){
                $scope.alertaError('Debe seleccionar una letra del campo prioridad');
            }else if($scope.prioridadNumero == '-Seleccione-'){
                $scope.alertaError('Debe seleccionar un numero del campo prioridad');
            }else if($scope.score2 == undefined){
                $scope.alertaError('Debe llenar el campo score 2');
            }else if($scope.tipoCampania == 0){
                $scope.alertaError('Debe llenar Tipo de campa�a');
            }else{
                $scope.alertaConf();
            }            
        }
        //guardar cambios editable
        $scope.crearCampania = function(){                                
                                console.log("campa�a seleccionada :D");
                                console.log($scope.campaniaSeleccionada);
                                Master.loadingModal('show');
                                console.log("entrando a crear campa�a");
                                console.log($scope.tipoCampania);
                                console.log("fecha de inicio");
                                console.log($scope.fechaInicio);
                                console.log("prioridad letra y numero");
                                console.log($scope.prioridadLetra);
                                console.log($scope.prioridadNumero);
                                var prioridad = '';
                                priodidad = $scope.prioridadLetra+$scope.prioridadNumero;

                                //remote action que crea la campa�a
                                Visualforce.remoting.Manager.invokeAction(
                                   "Ctrl_Torre_de_Control.crearCampania", $scope.query,$scope.tipoCampania,$scope.nombreCampania,
                                    $scope.fechaInicio,$scope.fechaFin,$scope.campaniaSeleccionada,$scope.listaOportunidades,
                                    priodidad,$scope.score2,$scope.callCenterSeleccionado,$scope.campaniaSeleccionada,
                                    $scope.nombreCampania,
                                        function(result, event) {                                    
                                            if(result) {
                                                // something more to do?
                                                console.log("resultado de crear campania");                                                
                                                console.log(result);
                                                $('#IdCampania').text(result);
                                                setTimeout(function () {
                                                    Master.loadingModal('hide');
                                                }, 1000);
                                            } else {
                                                console.log("There was an error");
                                                setTimeout(function () {
                                                    Master.loadingModal('hide');
                                                }, 1000);                                      
                                            } 
                                        },
                                   {escape: false,timeout: 240000} // No escaping, please
                               );
                            } 

        //buscar campa�as dependiendo del pertenece a:
        $scope.seleccionaCallCenter = function(){
                                        Master.loadingModal('show');
                                        console.log("call center seleccionado");
                                        console.log($scope.callCenterSeleccionado);

                                        //remote action que crea la campa�a
                                        Visualforce.remoting.Manager.invokeAction(
                                           "Ctrl_Torre_de_Control.obtieneCampanias",$scope.callCenterSeleccionado,
                                                function(result, event) {                                    
                                                    if(result) {
                                                        $scope.campaniaSeleccionada = '-Seleccione-';
                                                        // something more to do?
                                                        console.log("resultado de seleccionar compa�ia");
                                                        $scope.campanias = result;
                                                        console.log(result);
                                                        console.log("resultado de campa�as array");
                                                        console.log($scope.campanias);
                                                        $scope.$apply();

                                                        setTimeout(function () {
                                                            Master.loadingModal('hide');
                                                        }, 1000);
                                                    } else {
                                                        $scope.campanias = [];
                                                        console.log("There was an error");
                                                        setTimeout(function () {
                                                            Master.loadingModal('hide');
                                                        }, 1000);                                      
                                                    } 
                                                },
                                           {escape: false} // No escaping, please
                                       );
                                    }        
        //LLenado de select de Campos
        //-------------------------------------------------------------------------------
        $scope.campos = [ { n:"0", name:"--Seleccione--",tipo:"" }];

        $scope.miCampoSeleccionado = { n:"0", name:"--Seleccione--",tipo:""};        
        //-------------------------------------------------------------------------------        

        //LLenado de select de Campos
        //-------------------------------------------------------------------------------
        $scope.operadores = [
                            {name:"--Seleccione--"}                          
                          ];

        $scope.miOperadorSeleccionado = { name:"--Seleccione--" };        
        //-------------------------------------------------------------------------------        

        //LLenado de select de Valores
        //-------------------------------------------------------------------------------
        $scope.valores = [];

        $scope.valoresBool = [
                                {name:"--Seleccione--"},
                                {name:"TRUE"},
                                {name:"FALSE"}                             
                              ];

        $scope.miValorSeleccionado = [];
        $scope.miValorSeleccionadoBool = { name:"--Seleccione--" };
        $scope.miValorSeleccionadoDouble;
        //-------------------------------------------------------------------------------

        //LLenado de select de Valores
        //-------------------------------------------------------------------------------
        $scope.operadoresMap = [
                                {
                                    tipo:"STRING",
                                    valores:[
                                        {name:"--Seleccione--"},
                                        {name:"Igual a"},
                                        {name:"Inicia con"},
                                        {name:"Contiene"},
                                        {name:"Termina con"}
                                    ]
                                },
                                {
                                    tipo:"PICKLIST",
                                    valores:[
                                        {name:"--Seleccione--"},
                                        {name:"Igual a"},
                                        {name:"No Igual a"}
                                    ]
                                },
                                {
                                    tipo:"DOUBLE",
                                    valores:[
                                        {name:"--Seleccione--"},
                                        {name:"Igual a"},
                                        {name:"Entre"},
                                        {name:"Menor o igual que"},
                                        {name:"Mayor o igual que"}
                                    ]
                                },

                                {
                                    tipo:"DATETIME",
                                    valores:[
                                        {name:"--Seleccione--"},
                                        {name:"Igual a"},
                                        {name:"Entre"},
                                        {name:"Menor o igual que"},
                                        {name:"Mayor o igual que"}
                                    ]
                                },
                                {
                                    tipo:"DATE",
                                    valores:[
                                        {name:"--Seleccione--"},
                                        {name:"Igual a"},
                                        {name:"Entre"},
                                        {name:"Menor o igual que"},
                                        {name:"Mayor o igual que"}
                                    ]
                                },
                                {
                                    tipo:"REFERENCE",
                                    valores:[
                                        {name:"--Seleccione--"},
                                        {name:"Igual a"},
                                    ]
                                }
                              ];
        //-------------------------------------------------------------------------------   
});